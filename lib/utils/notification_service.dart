import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:restaurant/app/help_support_screen/help_support_screen.dart';
import 'package:restaurant/controller/home_controller.dart';
import 'package:restaurant/firebase_options.dart';
import 'package:restaurant/service/audio_player_service.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/preferences.dart';

/// Channel with bundled 20s order_bell (Android ignores sound changes on old channels).
const String kOrderAlertChannelId = 'tangzo_order_alerts_20s';

bool _isOrderRingtoneMessage(RemoteMessage message) {
  final type = (message.data['type']?.toString() ?? '').toLowerCase();
  if (message.data['play_ringtone']?.toString() == 'true') return true;
  if (type.contains('order_placed') ||
      type.contains('new_order') ||
      type.contains('schedule_order') ||
      type.contains('dinein_placed') ||
      type.contains('new_delivery_order')) {
    return true;
  }
  return false;
}

@pragma('vm:entry-point')
Future<void> firebaseMessageBackgroundHandle(RemoteMessage message) async {
  log("BackGround Message :: ${message.messageId}");
  // When FCM includes a notification payload, iOS/Android already display it
  // (iOS plays apns sound order_bell.caf). Only show a local notification for
  // data-only messages so we do not break / duplicate system delivery.
  if (message.notification != null) return;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
    final plugin = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    await plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: DarwinInitializationSettings(),
      ),
    );
    await _ensureOrderAlertChannel(plugin);
    final title = message.data['title']?.toString() ?? 'Tangzo';
    final body = message.data['body']?.toString() ?? 'New order update';
    await plugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          kOrderAlertChannelId,
          'Tangzo Order Alerts',
          channelDescription: 'High-priority order alerts with 20s sound',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          sound: const RawResourceAndroidNotificationSound('order_bell'),
          category: AndroidNotificationCategory.alarm,
          visibility: NotificationVisibility.public,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'order_bell.caf',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: jsonEncode(message.data),
    );
  } catch (e) {
    log('Background notification error: $e');
  }
}

Future<void> _ensureOrderAlertChannel(FlutterLocalNotificationsPlugin plugin) async {
  final channel = AndroidNotificationChannel(
    kOrderAlertChannelId,
    'Tangzo Order Alerts',
    description: 'High-priority order alerts with 20s sound',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    sound: const RawResourceAndroidNotificationSound('order_bell'),
  );
  await plugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

class NotificationService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initInfo() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    var request = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );

    if (request.authorizationStatus == AuthorizationStatus.authorized ||
        request.authorizationStatus == AuthorizationStatus.provisional) {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');
      var iosInitializationSettings = const DarwinInitializationSettings();
      final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: iosInitializationSettings,
      );
      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null) {
            final data = jsonDecode(response.payload!);
            final String type = data['type'] ?? '';
            handleMessageClick(type: type, isBgApp: false);
          }
        },
      );
      await _ensureOrderAlertChannel(flutterLocalNotificationsPlugin);
      setupInteractedMessage();
    }
  }

  Future<void> handleMessageClick({required String type, required bool isBgApp}) async {
    final String uid = FireStoreUtils.getCurrentUid();
    // Customer-restaurant chat is disabled. Only admin help chat is opened.
    if (type == 'admin_chat' && uid.isNotEmpty) {
      await Preferences.setBoolean(Preferences.isClickOnNotification, true);
      if (isBgApp == false) {
        Get.offAll(HelpSupportScreen(isNavigateViaNotification: true));
      }
    }
  }

  Future<void> setupInteractedMessage() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log("::::::::::::onMessage:::::::::::::::::");
      if (_isOrderRingtoneMessage(message)) {
        await AudioPlayerService.playSound(true);
        // Ensure New-orders board paints even if the live stream UI stalled.
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().refreshOrdersNow(playSoundIfNew: false);
        }
      }
      if (message.notification != null) {
        log(message.notification.toString());
        display(message);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      if (message != null) {
        final String type = message.data['type'] ?? '';
        handleMessageClick(type: type, isBgApp: false);
      }
    });
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      log("::::::::::::getInitialMessage:::::::::::::::::");
      if (message != null) {
        final String type = message.data['type'] ?? '';
        handleMessageClick(type: type, isBgApp: true);
      }
    });
    log("::::::::::::Permission authorized:::::::::::::::::");
    await _subscribeRestaurantTopicSafely();
  }

  /// iOS throws [apns-token-not-set] if subscribe runs before APNS is ready.
  Future<void> _subscribeRestaurantTopicSafely() async {
    try {
      if (Platform.isIOS) {
        String? apns;
        for (var i = 0; i < 10; i++) {
          apns = await FirebaseMessaging.instance.getAPNSToken();
          if (apns != null && apns.isNotEmpty) break;
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
        if (apns == null || apns.isEmpty) {
          log('APNS token not ready yet — skip topic subscribe for now');
          return;
        }
      }
      await FirebaseMessaging.instance.subscribeToTopic("restaurant");
      log('Subscribed to topic restaurant');
    } catch (e) {
      log('subscribeToTopic(restaurant) failed: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      return "";
    }
  }

  void display(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.notification!.body.toString()}');
    try {
      await _ensureOrderAlertChannel(flutterLocalNotificationsPlugin);
      final AndroidNotificationDetails notificationDetails = AndroidNotificationDetails(
        kOrderAlertChannelId,
        'Tangzo Order Alerts',
        channelDescription: 'High-priority order alerts with 20s sound',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        sound: const RawResourceAndroidNotificationSound('order_bell'),
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        ticker: 'ticker',
      );
      const DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'order_bell.caf',
        interruptionLevel: InterruptionLevel.timeSensitive,
      );
      final NotificationDetails notificationDetailsBoth = NotificationDetails(
        android: notificationDetails,
        iOS: darwinNotificationDetails,
      );
      await flutterLocalNotificationsPlugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: message.notification!.title,
        body: message.notification!.body,
        notificationDetails: notificationDetailsBoth,
        payload: jsonEncode(message.data),
      );
    } on Exception catch (e) {
      log(e.toString());
    }
  }
}
