import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:restaurant/app/chat_screens/ChatVideoContainer.dart';
import 'package:restaurant/constant/collection_name.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/firebase_options.dart';
import 'package:restaurant/models/AttributesModel.dart';
import 'package:restaurant/models/admin_commission.dart';
import 'package:restaurant/models/advertisement_model.dart';
import 'package:restaurant/models/conversation_model.dart';
import 'package:restaurant/models/driver_cashback_model.dart';
import 'package:restaurant/models/driver_cashback_redeem_model.dart';
import 'package:restaurant/models/dine_in_booking_model.dart';
import 'package:restaurant/models/document_model.dart';
import 'package:restaurant/models/driver_document_model.dart';
import 'package:restaurant/models/email_template_model.dart';
import 'package:restaurant/models/coupon_model.dart';
import 'package:restaurant/models/employee_role_model.dart';
import 'package:restaurant/models/inbox_model.dart';
import 'package:restaurant/models/mail_setting.dart';
import 'package:restaurant/models/notification_model.dart';
import 'package:restaurant/models/on_boarding_model.dart';
import 'package:restaurant/models/order_model.dart';
import 'package:restaurant/models/payment_model/cashfree_model.dart';
import 'package:restaurant/models/payment_model/cod_setting_model.dart';
import 'package:restaurant/models/payment_model/flutter_wave_model.dart';
import 'package:restaurant/models/payment_model/foloosi_model.dart';
import 'package:restaurant/models/payment_model/instamojo_model.dart';
import 'package:restaurant/models/payment_model/mercado_pago_model.dart';
import 'package:restaurant/models/payment_model/mid_trans.dart';
import 'package:restaurant/models/payment_model/mtnmomo_model.dart';
import 'package:restaurant/models/payment_model/orange_money.dart';
import 'package:restaurant/models/payment_model/pay_fast_model.dart';
import 'package:restaurant/models/payment_model/pay_stack_model.dart';
import 'package:restaurant/models/payment_model/paymongo_model.dart';
import 'package:restaurant/models/payment_model/paypal_model.dart';
import 'package:restaurant/models/payment_model/paytm_model.dart';
import 'package:restaurant/models/payment_model/phonepe_model.dart';
import 'package:restaurant/models/payment_model/razorpay_model.dart';
import 'package:restaurant/models/payment_model/stripe_model.dart';
import 'package:restaurant/models/payment_model/wallet_setting_model.dart';
import 'package:restaurant/models/payment_model/xendit.dart';
import 'package:restaurant/models/product_model.dart';
import 'package:restaurant/models/rating_model.dart';
import 'package:restaurant/models/referral_model.dart';
import 'package:restaurant/models/review_attribute_model.dart';
import 'package:restaurant/models/story_model.dart';
import 'package:restaurant/models/subscription_history.dart';
import 'package:restaurant/models/subscription_plan_model.dart';
import 'package:restaurant/models/tax_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/models/vendor_category_model.dart';
import 'package:restaurant/models/vendor_model.dart';
import 'package:restaurant/models/wallet_transaction_model.dart';
import 'package:restaurant/models/withdraw_method_model.dart';
import 'package:restaurant/models/withdrawal_model.dart';
import 'package:restaurant/models/zone_model.dart';
import 'package:restaurant/service/audio_player_service.dart';
import 'package:restaurant/services/menu_cache_repository.dart';
import 'package:restaurant/services/settings_api.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/utils/preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

enum FirebaseEnv { defaultDb, staging }

/// Change this to switch between default / staging
const FirebaseEnv currentEnv = FirebaseEnv.defaultDb;

class FireStoreUtils {
  FireStoreUtils._privateConstructor();

  static final FireStoreUtils instance = FireStoreUtils._privateConstructor();

  static late FirebaseFirestore fireStore;

  /// Initialize Firestore with a FirebaseApp and optional databaseId
  void init(FirebaseApp app, {String? databaseId}) {
    fireStore = FirebaseFirestore.instanceFor(app: app, databaseId: databaseId);
  }

  static String getCurrentUid() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  static Future<bool> isLogin() async {
    bool isLogin = false;
    if (FirebaseAuth.instance.currentUser != null) {
      isLogin = await userExistOrNot(FirebaseAuth.instance.currentUser!.uid);
    } else {
      isLogin = false;
    }
    return isLogin;
  }

  static Future<bool> isMaintenanceMode() async {
    bool isMaintenance = false;
    await fireStore.collection(CollectionName.settings).doc('maintenance_mode_settings').get().then((value) async {
      isMaintenance = value.data()?['restaurantApp'] == true;
    });
    return isMaintenance;
  }

  static Future<bool> userExistOrNot(String uid) async {
    bool isExist = false;

    await fireStore.collection(CollectionName.users).doc(uid).get().then(
      (value) {
        if (value.exists) {
          isExist = true;
        } else {
          isExist = false;
        }
      },
    ).catchError((error) {
      log("Failed to check user exist: $error");
      isExist = false;
    });
    return isExist;
  }

  static Future<UserModel?> getUserProfile(String uuid) async {
    UserModel? userModel;
    await fireStore.collection(CollectionName.users).doc(uuid).get().then((value) async {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
        Constant.userModel = userModel;
        if (userModel?.employeePermissionId != null) {
          Constant.employeeRoleModel = await FireStoreUtils.getEmployeeRoleById(userModel!.employeePermissionId!);
        }
      }
    });
    return userModel;
  }

  static Future<UserModel?> getUserById(String uuid) async {
    UserModel? userModel;
    log("uuid :: $uuid");
    await fireStore.collection(CollectionName.users).doc(uuid).get().then((value) {
      if (value.exists) {
        userModel = UserModel.fromJson(value.data()!);
      }
    });
    return userModel;
  }

  static Future<bool?> updateUserWallet({required String amount, required String userId}) async {
    bool isAdded = false;
    await getUserProfile(userId).then((value) async {
      if (value != null) {
        UserModel userModel = value;
        userModel.walletAmount = ((userModel.walletAmount ?? 0.0) + double.parse(amount));
        await FireStoreUtils.updateUser(userModel).then((value) {
          isAdded = value;
        });
      }
    });
    return isAdded;
  }

  static Future<bool> updateUser(UserModel userModel) async {
    bool isUpdate = false;
    // Merge so admin-only fields (e.g. top-level gst/pan) are not wiped by a full set().
    await fireStore
        .collection(CollectionName.users)
        .doc(userModel.id)
        .set(userModel.toJson(), SetOptions(merge: true))
        .whenComplete(() async {
      Constant.userModel = userModel;
      if (userModel.employeePermissionId != null) {
        Constant.employeeRoleModel = await FireStoreUtils.getEmployeeRoleById(userModel.employeePermissionId!);
      }
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  /// Avoid full-document set() on every splash when FCM token is unchanged.
  static Future<void> updateFcmTokenIfChanged({
    required String userId,
    required String? token,
  }) async {
    if (userId.isEmpty || token == null || token.isEmpty) return;
    try {
      final ref = fireStore.collection(CollectionName.users).doc(userId);
      final snap = await ref.get();
      if (!snap.exists) return;
      final current = snap.data()?['fcmToken']?.toString();
      if (current == token) return;
      await ref.update({'fcmToken': token});
      if (Constant.userModel?.id == userId) {
        Constant.userModel!.fcmToken = token;
      }
    } catch (e) {
      log('updateFcmTokenIfChanged: $e');
    }
  }

  static Future<bool> updateDriverUser(UserModel userModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.users).doc(userModel.id).set(userModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<bool> withdrawWalletAmount(WithdrawalModel userModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.payouts).doc(userModel.id).set(userModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  static Future<List<OnBoardingModel>> getOnBoardingList() async {
    List<OnBoardingModel> onBoardingModel = [];
    await fireStore.collection(CollectionName.onBoarding).where("type", isEqualTo: "restaurantApp").get().then((value) {
      for (var element in value.docs) {
        OnBoardingModel documentModel = OnBoardingModel.fromJson(element.data());
        onBoardingModel.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return onBoardingModel;
  }

  static Future<bool?> setWalletTransaction(WalletTransactionModel walletTransactionModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.wallet).doc(walletTransactionModel.id).set(walletTransactionModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<void> getSettings() async {
    try {
      var bundle = await SettingsApi.getBundle();
      if (bundle == null || bundle.docs.isEmpty) {
        bundle = await SettingsApi.raceBundle(
          firestoreLoader: _fetchRestaurantSettingsDocs,
        );
      }
      if (bundle != null && bundle.docs.isNotEmpty) {
        await _applyRestaurantSettingsDocs(bundle.docs);
        SettingsApi.markApplied(bundle);
      } else {
        await _applyRestaurantSettingsDocs(await _fetchRestaurantSettingsDocs());
      }

      // ignore: unawaited_futures
      SettingsApi.refreshInBackground(
        onFresh: (fresh) async {
          await _applyRestaurantSettingsDocs(fresh.docs);
          SettingsApi.markApplied(fresh);
        },
      );

      // Admin-commission taxes: one-shot (not continuous listener).
      await fireStore
          .collection(CollectionName.tax)
          .where('enable', isEqualTo: true)
          .where('scope', isEqualTo: 'admin_commission')
          .get()
          .then((value) {
        Constant.adminCommissionTaxList =
            value.docs.map((doc) => TaxModel.fromJson(doc.data())).toList();
      });
    } catch (e) {
      log(e.toString());
    }
  }

  static Future<Map<String, Map<String, dynamic>?>>
      _fetchRestaurantSettingsDocs() async {
    const ids = [
      'globalSettings',
      'restaurant',
      'DriverNearBy',
      'scheduleOrderNotification',
      'DineinForRestaurant',
      'AdminCommission',
      'googleMapKey',
      'story',
      'placeHolderImage',
      'Version',
      'RestaurantNearBy',
      'specialDiscountOffer',
      'emailSetting',
      'ContactUs',
      'notification_setting',
      'document_verification_settings',
      'privacyPolicy',
      'termsAndConditions',
      'openai_settings',
      'localisationSettings',
    ];
    final snaps = await Future.wait(
      ids.map((id) => fireStore.collection(CollectionName.settings).doc(id).get()),
    );
    final docs = <String, Map<String, dynamic>?>{};
    for (var i = 0; i < ids.length; i++) {
      docs[ids[i]] = snaps[i].data();
    }
    return docs;
  }

  static Future<void> _applyRestaurantSettingsDocs(
    Map<String, Map<String, dynamic>?> docs,
  ) async {
    final global = docs['globalSettings'];
    if (global != null) {
      Constant.defaultCountryCode = global['defaultCountryCode'] ?? '';
      Constant.orderRingtoneUrl = global['order_ringtone_url'] ?? '';
      Preferences.setString(Preferences.orderRingtone, Constant.orderRingtoneUrl);
      final color = global['app_restaurant_color']?.toString();
      if (color != null && color.isNotEmpty) {
        AppThemeData.secondary300 =
            Color(int.parse(color.replaceFirst("#", "0xff")));
      }
      Constant.isEnableAdsFeature = global['isEnableAdsFeature'] ?? false;
      Constant.isSelfDeliveryFeature = global['isSelfDelivery'] ?? false;
      Constant.apiSecureKey = global['apiSecureKey'] ?? "";
      Constant.apiBaseUrl = global['apiBaseUrl'] ?? "";
      Constant.taxScope = global['taxScope'] ?? "";
      if (Constant.orderRingtoneUrl.isNotEmpty) {
        await AudioPlayerService.initAudio();
      }
    }
    final restaurant = docs['restaurant'];
    if (restaurant != null) {
      Constant.isEmployeeManagement =
          restaurant['isEmployeeManagement'] ?? false;
      Constant.autoApproveRestaurant = restaurant['auto_approve_restaurant'];
      Constant.isSubscriptionModelApplied = restaurant['subscription_model'];
      Constant.packagingChargeEnable =
          restaurant['packagingChargeEnable'] ?? false;
    }
    final driverNear = docs['DriverNearBy'];
    if (driverNear != null) {
      Constant.selectedMapType = driverNear['selectedMapType'];
      Constant.singleOrderReceive = driverNear['singleOrderReceive'];
    }
    final schedule = docs['scheduleOrderNotification'];
    if (schedule != null) {
      Constant.scheduleOrderTime = schedule['notifyTime'];
      Constant.scheduleOrderTimeType = schedule['timeUnit'];
    }
    final dinein = docs['DineinForRestaurant'];
    if (dinein != null) Constant.isDineInEnable = dinein['isEnabled'];
    final adminCommission = docs['AdminCommission'];
    if (adminCommission != null) {
      Constant.adminCommission = AdminCommission.fromJson(adminCommission);
    }
    final mapKey = docs['googleMapKey'];
    if (mapKey != null) {
      Constant.mapAPIKey = mapKey['key'];
      Constant.placeHolderImage =
          mapKey['placeHolderImage']?.toString() ?? '';
    }
    final story = docs['story'];
    if (story != null) Constant.storyEnable = story['isEnabled'];
    final placeholder = docs['placeHolderImage'];
    if (placeholder != null) {
      Constant.placeholderImage = placeholder['image']?.toString() ?? '';
    }
    if (Constant.placeholderImage.isEmpty &&
        Constant.placeHolderImage.isNotEmpty) {
      Constant.placeholderImage = Constant.placeHolderImage;
    } else if (Constant.placeHolderImage.isEmpty &&
        Constant.placeholderImage.isNotEmpty) {
      Constant.placeHolderImage = Constant.placeholderImage;
    }
    final version = docs['Version'];
    if (version != null) {
      Constant.googlePlayLink = version['googlePlayLink'] ?? '';
      Constant.appStoreLink = version['appStoreLink'] ?? '';
      Constant.appVersion = version['app_version'] ?? '';
      Constant.storeUrl = version['storeUrl'] ?? '';
    }
    final nearby = docs['RestaurantNearBy'];
    if (nearby != null) Constant.distanceType = nearby['distanceType'];
    final special = docs['specialDiscountOffer'];
    if (special != null) {
      Constant.specialDiscountOfferEnable = special['isEnable'];
    }
    final email = docs['emailSetting'];
    if (email != null) Constant.mailSettings = MailSettings.fromJson(email);
    final contact = docs['ContactUs'];
    if (contact != null) Constant.adminEmail = contact['Email'];
    final notif = docs['notification_setting'];
    if (notif != null) {
      Constant.senderId = notif['projectId'];
      Constant.jsonNotificationFileURL = notif['serviceJson'];
    }
    final docVer = docs['document_verification_settings'];
    if (docVer != null) {
      Constant.isRestaurantVerification = docVer['isRestaurantVerification'];
    }
    final privacy = docs['privacyPolicy'];
    if (privacy != null) Constant.privacyPolicy = privacy['privacy_policy'];
    final terms = docs['termsAndConditions'];
    if (terms != null) {
      Constant.termsAndConditions = terms['termsAndConditions'];
    }
    final openai = docs['openai_settings'];
    if (openai != null) Constant.openAIStatus = openai['status'];
    final localisation = docs['localisationSettings'];
    if (localisation != null) {
      Constant.apiKeyOfDeepl = localisation['apiKeyOfDeepl'] ?? '';
      Constant.localisationType = localisation['localisationType'] ?? '';
    }
  }

  static Future<bool?> checkReferralCodeValidOrNot(String referralCode) async {
    bool? isExit;
    try {
      await fireStore.collection(CollectionName.referral).where("referralCode", isEqualTo: referralCode).get().then((value) {
        if (value.size > 0) {
          isExit = true;
        } else {
          isExit = false;
        }
      });
    } catch (e, s) {
      print('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isExit;
  }

  static List<TaxModel>? _taxSessionCache;
  static String? _taxSessionKey;

  static Future<List<TaxModel>?> getTaxList(double lat, double lng) async {
    final key = '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
    if (_taxSessionCache != null && _taxSessionKey == key) {
      return _taxSessionCache;
    }

    List<TaxModel> taxList = [];
    List<Placemark> placeMarks = await placemarkFromCoordinates(lat, lng);

    await fireStore.collection(CollectionName.tax).where('country', isEqualTo: placeMarks.first.country).where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        TaxModel taxModel = TaxModel.fromJson(element.data());
        taxList.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });

    _taxSessionKey = key;
    _taxSessionCache = taxList;
    return taxList;
  }

  static Future<ReferralModel?> getReferralUserByCode(String referralCode) async {
    ReferralModel? referralModel;
    try {
      await fireStore.collection(CollectionName.referral).where("referralCode", isEqualTo: referralCode).get().then((value) {
        if (value.docs.isNotEmpty) {
          referralModel = ReferralModel.fromJson(value.docs.first.data());
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return referralModel;
  }

  static Future<OrderModel?> getOrderByOrderId(String orderId) async {
    OrderModel? orderModel;
    try {
      await fireStore.collection(CollectionName.restaurantOrders).doc(orderId).get().then((value) {
        if (value.exists) {
          orderModel = OrderModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return orderModel;
  }

  static Future<String?> referralAdd(ReferralModel ratingModel) async {
    try {
      await fireStore.collection(CollectionName.referral).doc(ratingModel.id).set(ratingModel.toJson());
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return null;
  }

  static Future<List<ZoneModel>?> getZone() async {
    List<ZoneModel> airPortList = [];
    await fireStore.collection(CollectionName.zone).where('publish', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        ZoneModel ariPortModel = ZoneModel.fromJson(element.data());
        airPortList.add(ariPortModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return airPortList;
  }

  static Future<List<OrderModel>?> getAllOrder() async {
    List<OrderModel> orderList = [];
    try {
      await fireStore.collection(CollectionName.restaurantOrders).where('vendorID', isEqualTo: Constant.userModel!.vendorID).orderBy('createdAt', descending: true).get().then((value) {
        for (var element in value.docs) {
          OrderModel orderModel = OrderModel.fromJson(element.data());
          orderList.add(orderModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    } catch (e) {
      log(e.toString());
    }
    return orderList;
  }

  static Future<bool> deleteCashbackRedeem(OrderModel orderModel) async {
    bool isUpdate = false;
    try {
      final querySnapshot = await fireStore.collection(CollectionName.cashbackRedeem).where('orderId', isEqualTo: orderModel.id).where('cashbackId', isEqualTo: orderModel.cashback?.id).get();
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          await fireStore.collection(CollectionName.cashbackRedeem).doc(doc.id).delete();
        }
        isUpdate = true;
      } else {
        isUpdate = false;
      }
    } catch (e) {
      isUpdate = false;
      rethrow;
    }
    return isUpdate;
  }

  static Future<bool> deleteDriverCashbackRedeem(OrderModel orderModel) async {
    bool deleted = false;
    try {
      QuerySnapshot snap;
      if (orderModel.driverCashback?.id != null && orderModel.driverCashback!.id!.isNotEmpty) {
        snap = await fireStore
            .collection(CollectionName.driverCashbackRedeem)
            .where('orderId', isEqualTo: orderModel.id)
            .where('cashbackId', isEqualTo: orderModel.driverCashback!.id)
            .get();
      } else {
        snap = await fireStore
            .collection(CollectionName.driverCashbackRedeem)
            .where('orderId', isEqualTo: orderModel.id)
            .get();
      }
      for (final doc in snap.docs) {
        await fireStore.collection(CollectionName.driverCashbackRedeem).doc(doc.id).delete();
        deleted = true;
      }
      orderModel.driverCashback = null;
    } catch (e) {
      log('deleteDriverCashbackRedeem: $e');
    }
    return deleted;
  }

  /// Attach Tangzo-driver cashback when restaurant assigns own delivery person.
  static Future<OrderModel> attachDriverCashbackIfEligible(OrderModel order, String driverId) async {
    try {
      if (driverId.isEmpty) return order;
      if (order.driverCashback?.id != null && order.driverID == driverId) return order;

      final settings = await fireStore.collection(CollectionName.settings).doc('driverCashbackOffer').get();
      final isEnable = settings.data()?['isEnable'] == true;
      if (!isEnable) return order;

      final deliveryCharge = double.tryParse("${order.deliveryCharge ?? 0}") ?? 0.0;
      final paymentMethod = order.paymentMethod ?? '';
      final now = DateTime.now();
      final offersSnap = await fireStore.collection(CollectionName.driverCashback).get();

      DriverCashbackModel? best;
      double maxValue = 0.0;

      for (final doc in offersSnap.docs) {
        final offer = DriverCashbackModel.fromJson(doc.data());
        if (offer.isEnabled != true) continue;
        final startDate = offer.startDate;
        final endDate = offer.endDate;
        if (startDate == null || endDate == null) continue;
        final withinDate = startDate.toDate().isBefore(now) && endDate.toDate().isAfter(now);
        final meetsMin = deliveryCharge >= (offer.minimumPurchaseAmount ?? 0);
        final paymentMatch = (offer.allPayment ?? false) || (offer.paymentMethods ?? []).contains(paymentMethod);
        final driverMatch = (offer.allDrivers ?? false) || (offer.driverIds ?? []).contains(driverId);
        if (!withinDate || !meetsMin || !paymentMatch || !driverMatch) continue;

        final redeemSnap = await fireStore
            .collection(CollectionName.driverCashbackRedeem)
            .where('cashbackId', isEqualTo: offer.id)
            .where('userId', isEqualTo: driverId)
            .get();
        if (redeemSnap.docs.length >= (offer.redeemLimit ?? 0)) continue;

        double value = 0.0;
        if (offer.cashbackType == 'Percent') {
          value = ((offer.cashbackAmount ?? 0.0) / 100.0) * deliveryCharge;
        } else if (offer.cashbackType == 'Fixed') {
          value = offer.cashbackAmount ?? 0.0;
        }
        final maxDiscount = offer.maximumDiscount ?? value;
        if (value > maxDiscount) value = maxDiscount;
        if (value > maxValue) {
          maxValue = value;
          best = offer;
        }
      }

      if (best == null || best.id == null || maxValue <= 0) return order;
      best.cashbackValue = maxValue;
      order.driverCashback = best;

      final redeem = DriverCashbackRedeemModel(
        id: Constant.getUuid(),
        cashbackId: best.id,
        userId: driverId,
        orderId: order.id,
        createdAt: Timestamp.now(),
      );
      await fireStore.collection(CollectionName.driverCashbackRedeem).doc(redeem.id).set(redeem.toJson());
    } catch (e) {
      log('attachDriverCashbackIfEligible: $e');
    }
    return order;
  }

  static Future<bool> updateOrder(OrderModel orderModel) async {
    bool isUpdate = false;

    await fireStore.collection(CollectionName.restaurantOrders).doc(orderModel.id).set(orderModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    return isUpdate;
  }

  // static Future<void> restaurantVendorWalletSet(OrderModel orderModel) async {
  //   double subTotal = 0.0;
  //   double couponAmount = 0.0;
  //   double specialDiscountAmount = 0.0;
  //   double productTaxAmount = 0.0;
  //   double orderTaxAmount = 0.0;
  //   double packagingTaxAmount = 0.0;
  //   double totalTaxAmount = 0.0;
  //   double packagingCharge = 0.0;
  //
  //   /// ---------------- SUBTOTAL ----------------
  //   for (var element in orderModel.products!) {
  //     final double price = (double.parse(element.discountPrice.toString()) > 0) ? double.parse(element.discountPrice.toString()) : double.parse(element.price.toString());
  //
  //     final double qty = double.parse(element.quantity.toString());
  //     final double extras = double.parse(element.extrasPrice.toString());
  //
  //     subTotal += (price * qty) + (extras * qty);
  //   }
  //
  //   // SPECIAL DISCOUNT
  //   if (orderModel.specialDiscount?['special_discount'] != null) {
  //     specialDiscountAmount = double.tryParse(orderModel.specialDiscount!['special_discount'].toString()) ?? 0.0;
  //   }
  //
  //   couponAmount = double.tryParse(orderModel.discount.toString()) ?? 0.0;
  //   packagingCharge = double.tryParse(orderModel.vendor?.packagingCharge.toString() ?? '0') ?? 0.0;
  //
  //   final double totalDiscount = couponAmount + specialDiscountAmount;
  //
  //   /// ---------------- DISCOUNT RATIO ----------------
  //   double discountRatio = 0.0;
  //   if (subTotal > 0 && totalDiscount > 0) {
  //     discountRatio = totalDiscount / subTotal;
  //   }
  //
  //   if (orderModel.taxScope == "product") {
  //     for (var element in orderModel.products!) {
  //       final double price = (double.parse(element.discountPrice.toString()) > 0) ? double.parse(element.discountPrice.toString()) : double.parse(element.price.toString());
  //
  //       final double qty = double.parse(element.quantity.toString());
  //       final double extras = double.parse(element.extrasPrice.toString());
  //
  //       final double itemAmount = (price * qty) + (extras * qty);
  //
  //       final double discountedItemAmount = itemAmount - (itemAmount * discountRatio);
  //
  //       for (var taxElement in element.taxSetting!) {
  //         if (taxElement.type == "fix") {
  //           productTaxAmount += Constant.calculateTax(
  //                 amount: discountedItemAmount.toString(),
  //                 taxModel: taxElement,
  //               ) *
  //               qty;
  //         } else {
  //           productTaxAmount += Constant.calculateTax(
  //             amount: discountedItemAmount.toString(),
  //             taxModel: taxElement,
  //           );
  //         }
  //       }
  //     }
  //   }
  //
  //   // ORDER LEVEL TAX
  //   if (orderModel.taxScope == "order") {
  //     for (var taxElement in orderModel.taxSetting ?? []) {
  //       orderTaxAmount += Constant.calculateTax(
  //         amount: (subTotal - totalDiscount).toString(),
  //         taxModel: taxElement,
  //       );
  //     }
  //   }
  //
  //   // PACKAGING TAX
  //   if (packagingCharge > 0) {
  //     for (final tax in orderModel.packagingTax ?? []) {
  //       packagingTaxAmount += Constant.calculateTax(
  //         amount: packagingCharge.toString(),
  //         taxModel: tax,
  //       );
  //     }
  //   }
  //
  //   totalTaxAmount = productTaxAmount + orderTaxAmount + packagingTaxAmount;
  //
  //   // BASE PRICE AFTER COMMISSION
  //   double basePrice;
  //   final adminCommission = double.tryParse(orderModel.adminCommission ?? '0') ?? 0.0;
  //
  //   if (Constant.adminCommission?.isEnabled == true) {
  //     basePrice = (subTotal / (1 + (adminCommission / 100))) - couponAmount - specialDiscountAmount + double.parse(orderModel.vendor?.packagingCharge ?? '0.0');
  //   } else {
  //     basePrice = subTotal - couponAmount - specialDiscountAmount + double.parse(orderModel.vendor?.packagingCharge ?? '0.0');
  //   }
  //
  //   final vendorId = orderModel.vendor!.author;
  //
  //   // WALLET ENTRY – ORDER AMOUNT
  //   final orderWalletTxn = WalletTransactionModel(
  //     id: const Uuid().v4(),
  //     orderId: orderModel.id,
  //     userId: vendorId,
  //     amount: basePrice,
  //     date: Timestamp.now(),
  //     isTopup: true,
  //     note: "Order amount credited",
  //     paymentMethod: "wallet",
  //     paymentStatus: "success",
  //     transactionUser: "vendor",
  //   );
  //
  //   // WALLET ENTRY – TAX AMOUNT
  //   final taxWalletTxn = WalletTransactionModel(
  //     id: const Uuid().v4(),
  //     orderId: orderModel.id,
  //     userId: vendorId,
  //     amount: totalTaxAmount,
  //     date: Timestamp.now(),
  //     isTopup: true,
  //     note: "Order tax credited",
  //     paymentMethod: "tax",
  //     paymentStatus: "success",
  //     transactionUser: "vendor",
  //   );
  //
  //   final walletRef = fireStore.collection(CollectionName.wallet);
  //
  //   await Future.wait([
  //     walletRef.doc(orderWalletTxn.id).set(orderWalletTxn.toJson()),
  //     walletRef.doc(taxWalletTxn.id).set(taxWalletTxn.toJson()),
  //   ]);
  //   await updateUserWallet(
  //     amount: (basePrice + totalTaxAmount).toString(),
  //     userId: vendorId.toString(),
  //   );
  // }

  /// Net amount credited to restaurant for an order (after commission / tax / TDS).
  static Future<double> calculateVendorPayoutAmount(OrderModel orderModel) async {
    double subTotal = 0.0;
    for (var element in orderModel.products!) {
      final double price = (double.parse(element.discountPrice.toString()) > 0)
          ? double.parse(element.discountPrice.toString())
          : double.parse(element.price.toString());
      final double qty = double.parse(element.quantity.toString());
      final double extras = double.parse(element.extrasPrice.toString());
      subTotal += (price * qty) + (extras * qty);
    }

    double specialDiscountAmount = 0.0;
    if (orderModel.specialDiscount?['special_discount'] != null) {
      specialDiscountAmount = double.tryParse(orderModel.specialDiscount!['special_discount'].toString()) ?? 0.0;
    }
    final couponAmount = double.tryParse(orderModel.discount.toString()) ?? 0.0;
    final packagingCharge = double.tryParse(orderModel.vendor?.packagingCharge.toString() ?? '0') ?? 0.0;
    final netFoodSubtotal = subTotal - couponAmount - specialDiscountAmount;

    final adminCommissionRaw = double.tryParse(orderModel.adminCommission ?? '0') ?? 0.0;
    double adminCommissionAmount;
    if (orderModel.adminCommissionType == "Percent") {
      if (adminCommissionRaw > 0) {
        final basePrice = subTotal / (1 + (adminCommissionRaw / 100));
        adminCommissionAmount = subTotal - basePrice;
      } else {
        adminCommissionAmount = 0.0;
      }
    } else {
      adminCommissionAmount = adminCommissionRaw;
    }

    final commissionTaxAmount = Constant.calculateAdminCommissionTax(adminCommissionAmount);
    String gstNumber = '';
    if (orderModel.vendor?.author != null && orderModel.vendor!.author!.isNotEmpty) {
      final owner = await getUserProfile(orderModel.vendor!.author!);
      gstNumber = owner?.userBankDetails?.gstNumber.trim() ?? '';
    }
    final orderTotal = netFoodSubtotal + packagingCharge;
    final tdsAmount = Constant.calculateTdsOrTcs(orderTotal, hasGst: gstNumber.isNotEmpty);
    return orderTotal - adminCommissionAmount - commissionTaxAmount - tdsAmount;
  }

  /// Prefer the original wallet credit for this order; fall back to calculated payout.
  static Future<double> getVendorCreditedAmountForOrder(OrderModel orderModel) async {
    final vendorId = orderModel.vendor?.author;
    if (vendorId == null || vendorId.isEmpty || orderModel.id == null) {
      return 0.0;
    }

    try {
      final snap = await fireStore
          .collection(CollectionName.wallet)
          .where('order_id', isEqualTo: orderModel.id)
          .where('user_id', isEqualTo: vendorId)
          .get();

      double credited = 0.0;
      double alreadyReversed = 0.0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final note = (data['note'] ?? '').toString();
        final amount = double.tryParse('${data['amount'] ?? 0}') ?? 0.0;
        final isTopUp = data['isTopUp'] == true;
        if (note == 'Order amount credited' && isTopUp) {
          credited += amount;
        }
        if ((note == 'Order amount refunded to customer' || note == 'Order credit reversed on cancel') && isTopUp == false) {
          alreadyReversed += amount;
        }
      }
      final remaining = credited - alreadyReversed;
      if (remaining > 0) return remaining;
    } catch (e) {
      log('getVendorCreditedAmountForOrder: $e');
    }

    // No credit found (e.g. cancelled before accept) → nothing to reverse
    return 0.0;
  }

  /// Prefer original customer debit for this order; fall back to [fallbackAmount].
  static Future<double> getCustomerDebitedAmountForOrder({
    required OrderModel orderModel,
    required double fallbackAmount,
  }) async {
    final customerId = orderModel.author?.id;
    if (customerId == null || customerId.isEmpty || orderModel.id == null) {
      return fallbackAmount;
    }

    try {
      final snap = await fireStore
          .collection(CollectionName.wallet)
          .where('order_id', isEqualTo: orderModel.id)
          .where('user_id', isEqualTo: customerId)
          .get();

      double debited = 0.0;
      double alreadyRefunded = 0.0;
      for (final doc in snap.docs) {
        final data = doc.data();
        final note = (data['note'] ?? '').toString();
        final amount = double.tryParse('${data['amount'] ?? 0}') ?? 0.0;
        final isTopUp = data['isTopUp'] == true;
        if (note == 'Order Amount debited' && isTopUp == false) {
          debited += amount;
        }
        if (note == 'Order Refund success' && isTopUp == true) {
          alreadyRefunded += amount;
        }
      }
      final remaining = debited - alreadyRefunded;
      if (remaining > 0) return remaining;
      if (debited > 0) return 0.0; // already fully refunded
    } catch (e) {
      log('getCustomerDebitedAmountForOrder: $e');
    }
    return fallbackAmount;
  }

  /// Reverse restaurant credit for a cancelled/rejected order (exact credited amount).
  static Future<void> reverseVendorCreditForOrder(OrderModel orderModel) async {
    final vendorId = orderModel.vendor?.author;
    if (vendorId == null || vendorId.isEmpty) return;

    final amount = await getVendorCreditedAmountForOrder(orderModel);
    if (amount <= 0) {
      log('No vendor credit to reverse for order ${orderModel.id}');
      return;
    }

    final historyModel = WalletTransactionModel(
      amount: amount,
      id: const Uuid().v4(),
      orderId: orderModel.id,
      userId: vendorId,
      date: Timestamp.now(),
      isTopup: false,
      paymentMethod: "Wallet",
      paymentStatus: "success",
      note: "Order credit reversed on cancel",
      transactionUser: "vendor",
    );
    await fireStore.collection(CollectionName.wallet).doc(historyModel.id).set(historyModel.toJson());
    await updateUserWallet(amount: (-amount).toString(), userId: vendorId);
  }

  static Future<void> restaurantVendorWalletSet(OrderModel orderModel) async {
    final finalVendorPayout = await calculateVendorPayoutAmount(orderModel);
    final vendorId = orderModel.vendor!.author;

    // WALLET ENTRY -- FINAL NET PAYOUT ONLY.
    // No separate tax transaction is created anymore -- zero tax money
    // is ever credited to the vendor's wallet.
    final orderWalletTxn = WalletTransactionModel(
      id: const Uuid().v4(),
      orderId: orderModel.id,
      userId: vendorId,
      amount: finalVendorPayout,
      date: Timestamp.now(),
      isTopup: true,
      note: "Order amount credited",
      paymentMethod: "wallet",
      paymentStatus: "success",
      transactionUser: "vendor",
    );

    final walletRef = fireStore.collection(CollectionName.wallet);

    await walletRef.doc(orderWalletTxn.id).set(orderWalletTxn.toJson());
    await updateUserWallet(
      amount: finalVendorPayout.toString(),
      userId: vendorId.toString(),
    );
  }

  static Future<RatingModel?> getOrderReviewsByID(String orderId, String productID) async {
    RatingModel? ratingModel;

    await fireStore.collection(CollectionName.foodsReview).where('orderid', isEqualTo: orderId).where('productId', isEqualTo: productID).get().then((value) {
      print("======>");
      print(value.docs.length);
      if (value.docs.isNotEmpty) {
        ratingModel = RatingModel.fromJson(value.docs.first.data());
      }
    }).catchError((error) {
      log(error.toString());
    });
    return ratingModel;
  }

  /// Loads the restaurant catalog via memory/disk → Redis CF → Firestore.
  /// Includes unpublished. menuVersion bump is owned by onVendorProductWrite.
  static Future<List<ProductModel>?> getProduct({bool forceRefresh = false}) async {
    final vendorId = Constant.userModel?.vendorID;
    if (vendorId == null || vendorId.isEmpty) {
      return <ProductModel>[];
    }

    int? menuVersion;
    try {
      final vendorSnap =
          await fireStore.collection(CollectionName.vendors).doc(vendorId).get();
      final raw = vendorSnap.data()?['menuVersion'];
      if (raw is int) {
        menuVersion = raw;
      } else {
        menuVersion = int.tryParse(raw?.toString() ?? '');
      }
    } catch (_) {}

    return MenuCacheRepository.instance.getMenu(
      vendorId,
      menuVersion: menuVersion,
      forceRefresh: forceRefresh,
    );
  }

  static Future<List<ProductModel>?> getAdminProduct() async {
    List<ProductModel> productList = [];
    await fireStore.collection(CollectionName.adminProducts).where('publish', isEqualTo: true).orderBy('createdAt', descending: true).get().then((value) {
      for (var element in value.docs) {
        ProductModel productModel = ProductModel.fromJson(element.data());
        productList.add(productModel);
      }
    });
    return productList;
  }

  static Future<List<AdvertisementModel>?> getAdvertisement() async {
    List<AdvertisementModel> advertisementList = [];
    await fireStore.collection(CollectionName.advertisements).where('vendorId', isEqualTo: Constant.userModel!.vendorID).orderBy('createdAt', descending: true).get().then((value) {
      for (var element in value.docs) {
        AdvertisementModel advertisementModel = AdvertisementModel.fromJson(element.data());
        advertisementList.add(advertisementModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return advertisementList;
  }

  static Future<AdvertisementModel> getAdvertisementById({required String advertisementId}) async {
    AdvertisementModel advertisementdata = AdvertisementModel();
    await fireStore.collection(CollectionName.advertisements).doc(advertisementId).get().then((value) {
      AdvertisementModel advertisementModel = AdvertisementModel.fromJson(value.data() as Map<String, dynamic>);
      advertisementdata = advertisementModel;
    }).catchError((error) {
      log(error.toString());
    });
    return advertisementdata;
  }

  static Future<bool> updateProduct(ProductModel productModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.vendorProducts).doc(productModel.id).set(productModel.toJson()).whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    // menuVersion + Redis menu invalidation: Cloud Function onVendorProductWrite only
    // (avoid double-bump with client-side increment).
    return isUpdate;
  }

  static Future<bool> deleteProduct(ProductModel productModel) async {
    bool isUpdate = false;
    await fireStore.collection(CollectionName.vendorProducts).doc(productModel.id).delete().whenComplete(() {
      isUpdate = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isUpdate = false;
    });
    // menuVersion bumped by onVendorProductWrite Cloud Function only.
    return isUpdate;
  }

  /// Deprecated: menuVersion is owned by Cloud Function `onVendorProductWrite`.
  /// Kept as a no-op so any residual call sites compile without double-bumping.
  static Future<void> bumpVendorMenuVersion(String? vendorId) async {
    log('bumpVendorMenuVersion skipped (CF onVendorProductWrite is authoritative); vendorId=$vendorId');
  }

  static Future<List<WalletTransactionModel>?> getWalletTransaction() async {
    List<WalletTransactionModel> walletTransactionList = [];
    await fireStore.collection(CollectionName.wallet).where('user_id', isEqualTo: FireStoreUtils.getCurrentUid()).orderBy('date', descending: true).get().then((value) {
      for (var element in value.docs) {
        WalletTransactionModel walletTransactionModel = WalletTransactionModel.fromJson(element.data());
        walletTransactionList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionList;
  }

  static Future<List<WalletTransactionModel>?> getFilterWalletTransaction(Timestamp startTime, Timestamp endTime) async {
    List<WalletTransactionModel> walletTransactionList = [];
    await fireStore
        .collection(CollectionName.wallet)
        .where('user_id', isEqualTo: FireStoreUtils.getCurrentUid())
        .where('date', isGreaterThanOrEqualTo: startTime)
        .where('date', isLessThanOrEqualTo: endTime)
        .orderBy('date', descending: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        WalletTransactionModel walletTransactionModel = WalletTransactionModel.fromJson(element.data());
        walletTransactionList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionList;
  }

  static Future<List<WithdrawalModel>?> getWithdrawHistory() async {
    List<WithdrawalModel> walletTransactionList = [];
    await fireStore.collection(CollectionName.payouts).where('vendorID', isEqualTo: Constant.userModel!.vendorID.toString()).orderBy('paidDate', descending: true).get().then((value) {
      for (var element in value.docs) {
        WithdrawalModel walletTransactionModel = WithdrawalModel.fromJson(element.data());
        walletTransactionList.add(walletTransactionModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return walletTransactionList;
  }

  static Future getPaymentSettingsData() async {
    await fireStore.collection(CollectionName.settings).doc("payFastSettings").get().then((value) async {
      if (value.exists) {
        PayFastModel payFastModel = PayFastModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.payFastSettings, jsonEncode(payFastModel.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("MercadoPago").get().then((value) async {
      if (value.exists) {
        MercadoPagoModel mercadoPagoModel = MercadoPagoModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.mercadoPago, jsonEncode(mercadoPagoModel.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("paypalSettings").get().then((value) async {
      if (value.exists) {
        PayPalModel payPalModel = PayPalModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.paypalSettings, jsonEncode(payPalModel.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("stripeSettings").get().then((value) async {
      if (value.exists) {
        StripeModel stripeModel = StripeModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.stripeSettings, jsonEncode(stripeModel.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("flutterWave").get().then((value) async {
      if (value.exists) {
        FlutterWaveModel flutterWaveModel = FlutterWaveModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.flutterWave, jsonEncode(flutterWaveModel.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("payStack").get().then((value) async {
      if (value.exists) {
        PayStackModel payStackModel = PayStackModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.payStack, jsonEncode(payStackModel.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("PaytmSettings").get().then((value) async {
      if (value.exists) {
        PaytmModel paytmModel = PaytmModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.paytmSettings, jsonEncode(paytmModel.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("walletSettings").get().then((value) async {
      if (value.exists) {
        WalletSettingModel walletSettingModel = WalletSettingModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.walletSettings, jsonEncode(walletSettingModel.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("razorpaySettings").get().then((value) async {
      if (value.exists) {
        RazorPayModel razorPayModel = RazorPayModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.razorpaySettings, jsonEncode(razorPayModel.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("CODSettings").get().then((value) async {
      if (value.exists) {
        CodSettingModel codSettingModel = CodSettingModel.fromJson(value.data()!);
        await Preferences.setString(Preferences.codSettings, jsonEncode(codSettingModel.toJson()));
      }
    });

    await fireStore.collection(CollectionName.settings).doc("midtrans_settings").get().then((value) async {
      if (value.exists) {
        MidTrans midTrans = MidTrans.fromJson(value.data()!);
        await Preferences.setString(Preferences.midTransSettings, jsonEncode(midTrans.toJson()));
      }
    });

    await fireStore.collection(CollectionName.settings).doc("orange_money_settings").get().then((value) async {
      if (value.exists) {
        OrangeMoney orangeMoney = OrangeMoney.fromJson(value.data()!);
        await Preferences.setString(Preferences.orangeMoneySettings, jsonEncode(orangeMoney.toJson()));
      }
    });

    await fireStore.collection(CollectionName.settings).doc("xendit_settings").get().then((value) async {
      if (value.exists) {
        Xendit xendit = Xendit.fromJson(value.data()!);
        await Preferences.setString(Preferences.xenditSettings, jsonEncode(xendit.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("mtnMomo_settings").get().then((value) async {
      if (value.exists) {
        MtnMomo mtnMomo = MtnMomo.fromJson(value.data()!);
        await Preferences.setString(Preferences.mtnMomoSettings, jsonEncode(mtnMomo.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("phonepay_settings").get().then((value) async {
      if (value.exists) {
        PhonePe phonePe = PhonePe.fromJson(value.data()!);
        await Preferences.setString(Preferences.phonePaySettings, jsonEncode(phonePe.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("foloosi_settings").get().then((value) async {
      if (value.exists) {
        Foloosi foloosi = Foloosi.fromJson(value.data()!);
        await Preferences.setString(Preferences.foloosiSettings, jsonEncode(foloosi.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("cashfree_settings").get().then((value) async {
      if (value.exists) {
        Cashfree cashfree = Cashfree.fromJson(value.data()!);
        await Preferences.setString(Preferences.cashFreeSettings, jsonEncode(cashfree.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("paymongo_settings").get().then((value) async {
      if (value.exists) {
        PayMongo payMongo = PayMongo.fromJson(value.data()!);
        await Preferences.setString(Preferences.payMongoSettings, jsonEncode(payMongo.toJson()));
      }
    });
    await fireStore.collection(CollectionName.settings).doc("instamojo_settings").get().then((value) async {
      if (value.exists) {
        Instamojo instamojo = Instamojo.fromJson(value.data()!);
        await Preferences.setString(Preferences.instamojoSettings, jsonEncode(instamojo.toJson()));
      }
    });
  }

  static final Map<String, VendorModel> _vendorSessionCache = {};

  static Future<VendorModel?> getVendorById(String vendorId) async {
    if (vendorId.isEmpty) return null;
    final hit = _vendorSessionCache[vendorId];
    if (hit != null) return hit;

    VendorModel? vendorModel;
    try {
      await fireStore.collection(CollectionName.vendors).doc(vendorId).get().then((value) {
        if (value.exists) {
          vendorModel = VendorModel.fromJson(value.data()!);
          _vendorSessionCache[vendorId] = vendorModel!;
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorModel;
  }

  static Future<List<VendorCategoryModel>?> getVendorCategoryById() async {
    List<VendorCategoryModel> attributeList = [];
    await fireStore.collection(CollectionName.vendorCategories).where('publish', isEqualTo: true).get().then(
      (value) {
        for (var element in value.docs) {
          VendorCategoryModel favouriteModel = VendorCategoryModel.fromJson(element.data());
          attributeList.add(favouriteModel);
        }
      },
    );
    return attributeList;
  }

  static Future<ProductModel?> getProductById(String productId) async {
    ProductModel? vendorCategoryModel;
    try {
      await fireStore.collection(CollectionName.vendorProducts).doc(productId).get().then((value) {
        if (value.exists) {
          vendorCategoryModel = ProductModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<VendorCategoryModel?> getVendorCategoryByCategoryId(String categoryId) async {
    VendorCategoryModel? vendorCategoryModel;
    try {
      await fireStore.collection(CollectionName.vendorCategories).doc(categoryId).get().then((value) {
        if (value.exists) {
          vendorCategoryModel = VendorCategoryModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<ReviewAttributeModel?> getVendorReviewAttribute(String attributeId) async {
    ReviewAttributeModel? vendorCategoryModel;
    try {
      await fireStore.collection(CollectionName.reviewAttributes).doc(attributeId).get().then((value) {
        if (value.exists) {
          vendorCategoryModel = ReviewAttributeModel.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return vendorCategoryModel;
  }

  static Future<List<AttributesModel>?> getAttributes() async {
    List<AttributesModel> attributeList = [];
    await fireStore.collection(CollectionName.vendorAttributes).get().then(
      (value) {
        for (var element in value.docs) {
          AttributesModel favouriteModel = AttributesModel.fromJson(element.data());
          attributeList.add(favouriteModel);
        }
      },
    );
    return attributeList;
  }

  static Future<DeliveryCharge?> getDeliveryCharge() async {
    DeliveryCharge? deliveryCharge;
    try {
      await fireStore.collection(CollectionName.settings).doc("DeliveryCharge").get().then((value) {
        if (value.exists) {
          deliveryCharge = DeliveryCharge.fromJson(value.data()!);
        }
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return null;
    }
    return deliveryCharge;
  }

  static Future<List<DineInBookingModel>> getDineInBooking(bool isUpcoming) async {
    List<DineInBookingModel> list = [];

    if (isUpcoming) {
      await fireStore
          .collection(CollectionName.bookedTable)
          .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
          .where('date', isGreaterThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          DineInBookingModel taxModel = DineInBookingModel.fromJson(element.data());
          list.add(taxModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    } else {
      await fireStore
          .collection(CollectionName.bookedTable)
          .where('vendorID', isEqualTo: Constant.userModel!.vendorID)
          .where('date', isLessThan: Timestamp.now())
          .orderBy('date', descending: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        for (var element in value.docs) {
          DineInBookingModel taxModel = DineInBookingModel.fromJson(element.data());
          list.add(taxModel);
        }
      }).catchError((error) {
        log(error.toString());
      });
    }

    return list;
  }

  static Future<List<CouponModel>> getAllVendorCoupons(String vendorId) async {
    List<CouponModel> coupon = [];

    await fireStore
        .collection(CollectionName.coupons)
        .where("resturant_id", isEqualTo: vendorId)
        .where('expiresAt', isGreaterThanOrEqualTo: Timestamp.now())
        .where("isEnabled", isEqualTo: true)
        .where("isPublic", isEqualTo: true)
        .get()
        .then((value) {
      for (var element in value.docs) {
        CouponModel taxModel = CouponModel.fromJson(element.data());
        coupon.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return coupon;
  }

  static Future<bool?> setOrder(OrderModel orderModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.restaurantOrders).doc(orderModel.id).set(orderModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setCoupon(CouponModel orderModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.coupons).doc(orderModel.id).set(orderModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> deleteCoupon(CouponModel orderModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.coupons).doc(orderModel.id).delete().then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<CouponModel>> getOffer(String vendorId) async {
    List<CouponModel> list = [];

    await fireStore.collection(CollectionName.coupons).where("resturant_id", isEqualTo: vendorId).get().then((value) {
      for (var element in value.docs) {
        CouponModel taxModel = CouponModel.fromJson(element.data());
        list.add(taxModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return list;
  }

  static Future<List<DocumentModel>> getDocumentList() async {
    List<DocumentModel> documentList = [];
    await fireStore.collection(CollectionName.documents).where('type', isEqualTo: "restaurant").where('enable', isEqualTo: true).get().then((value) {
      for (var element in value.docs) {
        DocumentModel documentModel = DocumentModel.fromJson(element.data());
        documentList.add(documentModel);
      }
    }).catchError((error) {
      log(error.toString());
    });
    return documentList;
  }

  static Future<DriverDocumentModel?> getDocumentOfDriver() async {
    DriverDocumentModel? driverDocumentModel;
    await fireStore.collection(CollectionName.documentsVerify).doc(getCurrentUid()).get().then((value) async {
      if (value.exists) {
        driverDocumentModel = DriverDocumentModel.fromJson(value.data()!);
      }
    });
    return driverDocumentModel;
  }

  static Future addRestaurantInbox(InboxModel inboxModel) async {
    return await fireStore.collection("chat_restaurant").doc(inboxModel.orderId).set(inboxModel.toJson()).then((document) {
      return inboxModel;
    });
  }

  static Future addRestaurantChat(ConversationModel conversationModel) async {
    return await fireStore.collection("chat_restaurant").doc(conversationModel.orderId).collection("thread").doc(conversationModel.id).set(conversationModel.toJson()).then((document) {
      return conversationModel;
    });
  }

  static Future<bool> uploadDriverDocument(Documents documents) async {
    bool isAdded = false;
    DriverDocumentModel driverDocumentModel = DriverDocumentModel();
    List<Documents> documentsList = [];
    await fireStore.collection(CollectionName.documentsVerify).doc(getCurrentUid()).get().then((value) async {
      if (value.exists) {
        DriverDocumentModel newDriverDocumentModel = DriverDocumentModel.fromJson(value.data()!);
        documentsList = newDriverDocumentModel.documents!;
        var contain = newDriverDocumentModel.documents!.where((element) => element.documentId == documents.documentId);
        if (contain.isEmpty) {
          documentsList.add(documents);

          driverDocumentModel.id = getCurrentUid();
          driverDocumentModel.type = "restaurant";
          driverDocumentModel.documents = documentsList;
        } else {
          var index = newDriverDocumentModel.documents!.indexWhere((element) => element.documentId == documents.documentId);

          driverDocumentModel.id = getCurrentUid();
          driverDocumentModel.type = "restaurant";
          documentsList.removeAt(index);
          documentsList.insert(index, documents);
          driverDocumentModel.documents = documentsList;
          isAdded = false;
        }
      } else {
        documentsList.add(documents);
        driverDocumentModel.id = getCurrentUid();
        driverDocumentModel.type = "restaurant";
        driverDocumentModel.documents = documentsList;
      }
    });

    await fireStore.collection(CollectionName.documentsVerify).doc(getCurrentUid()).set(driverDocumentModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      isAdded = false;
      log(error.toString());
    });

    return isAdded;
  }

  static Future<DeliveryCharge?> getDelivery() async {
    DeliveryCharge? driverDocumentModel;
    await fireStore.collection(CollectionName.settings).doc("DeliveryCharge").get().then((value) async {
      if (value.exists) {
        driverDocumentModel = DeliveryCharge.fromJson(value.data()!);
      }
    });
    return driverDocumentModel;
  }

  static Future<VendorModel> firebaseCreateNewVendor(VendorModel vendor) async {
    DocumentReference documentReference = fireStore.collection(CollectionName.vendors).doc();
    vendor.id = documentReference.id;
    await documentReference.set(vendor.toJson());
    Constant.userModel?.vendorID = documentReference.id;
    vendor.fcmToken = Constant.userModel!.fcmToken;
    Constant.vendorAdminCommission = vendor.adminCommission;
    await FireStoreUtils.updateUser(Constant.userModel!);
    return vendor;
  }

  static Future<VendorModel?> updateVendor(VendorModel vendor) async {
    return await fireStore.collection(CollectionName.vendors).doc(vendor.id).set(vendor.toJson()).then((document) {
      Constant.vendorAdminCommission = vendor.adminCommission;
      return vendor;
    });
  }

  static Future<bool?> deleteUser() async {
    bool? isDelete;
    try {
      if (Constant.userModel?.vendorID != null && Constant.userModel?.vendorID?.isNotEmpty == true && Constant.userModel?.role == Constant.userRoleVendor) {
        await fireStore.collection(CollectionName.coupons).where('resturant_id', isEqualTo: Constant.userModel!.vendorID).get().then((value) async {
          for (var doc in value.docs) {
            await fireStore.collection(CollectionName.coupons).doc(doc.reference.id).delete();
          }
        });
        await fireStore.collection(CollectionName.foodsReview).where('VendorId', isEqualTo: Constant.userModel!.vendorID).get().then((value) async {
          for (var doc in value.docs) {
            await fireStore.collection(CollectionName.foodsReview).doc(doc.reference.id).delete();
          }
        });

        await fireStore.collection(CollectionName.vendorProducts).where('vendorID', isEqualTo: Constant.userModel?.vendorID).get().then((value) async {
          for (var doc in value.docs) {
            await fireStore.collection(CollectionName.favoriteItem).where('product_id', isEqualTo: doc.reference.id).get().then((value0) async {
              for (var element0 in value0.docs) {
                await fireStore.collection(CollectionName.favoriteItem).doc(element0.reference.path).delete();
              }
            });
            await fireStore.collection(CollectionName.vendorProducts).doc(doc.reference.id).delete();
          }
        });

        await fireStore.collection(CollectionName.vendors).doc(Constant.userModel?.vendorID).delete();
      }

      await fireStore.collection(CollectionName.users).doc(FireStoreUtils.getCurrentUid()).delete();

      // delete user  from firebase auth
      await deleteAuthUser(FireStoreUtils.getCurrentUid()).then((value) {
        isDelete = true;
      });
    } catch (e, s) {
      log('FireStoreUtils.firebaseCreateNewUser $e $s');
      return false;
    }
    return isDelete;
  }

  static Future<bool> deleteAuthUser(String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("❌ No user is logged in.");
        return false;
      }

      final idToken = await user.getIdToken();
      final projectId = DefaultFirebaseOptions.currentPlatform.projectId;
      final url = Uri.parse('https://us-central1-$projectId.cloudfunctions.net/deleteUser');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'data': {'uid': uid}, // 👈 matches your Cloud Function structure
        }),
      );

      print("Response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['result']?['success'] == true || decoded['success'] == true;
      } else {
        print("⚠️ Cloud Function failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Error deleting driver: $e");
      return false;
    }
  }

  static Future<Url> uploadChatImageToFireStorage(File image, BuildContext context) async {
    ShowToastDialog.showLoader("Please wait");
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('images/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(image);
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();
    var metaData = await storageRef.getMetadata();
    ShowToastDialog.closeLoader();
    return Url(mime: metaData.contentType ?? 'image', url: downloadUrl.toString());
  }

  static Future<ChatVideoContainer?> uploadChatVideoToFireStorage(BuildContext context, File video) async {
    try {
      ShowToastDialog.showLoader("Uploading video...");
      final String uniqueID = const Uuid().v4();
      final Reference videoRef = FirebaseStorage.instance.ref('videos/$uniqueID.mp4');
      final UploadTask uploadTask = videoRef.putFile(
        video,
        SettableMetadata(contentType: 'video/mp4'),
      );
      await uploadTask;
      final String videoUrl = await videoRef.getDownloadURL();
      ShowToastDialog.showLoader("Generating thumbnail...");
      File thumbnail = await VideoCompress.getFileThumbnail(
        video.path,
        quality: 75, // 0 - 100
        position: -1, // Get the first frame
      );

      final String thumbnailID = const Uuid().v4();
      final Reference thumbnailRef = FirebaseStorage.instance.ref('thumbnails/$thumbnailID.jpg');
      final UploadTask thumbnailUploadTask = thumbnailRef.putData(
        thumbnail.readAsBytesSync(),
        SettableMetadata(contentType: 'image/jpeg'),
      );
      await thumbnailUploadTask;
      final String thumbnailUrl = await thumbnailRef.getDownloadURL();
      var metaData = await thumbnailRef.getMetadata();
      ShowToastDialog.closeLoader();

      return ChatVideoContainer(videoUrl: Url(url: videoUrl.toString(), mime: metaData.contentType ?? 'video'), thumbnailUrl: thumbnailUrl);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
      return null;
    }
  }

  static Future<String> uploadImageOfStory(File image, BuildContext context, String extansion) async {
    final data = await image.readAsBytes();
    final mime = lookupMimeType('', headerBytes: data);

    Reference upload = FirebaseStorage.instance.ref().child(
          'Story/images/${image.path.split('/').last}',
        );
    UploadTask uploadTask = upload.putFile(image, SettableMetadata(contentType: mime));
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();

    return downloadUrl.toString();
  }

  static Future<File> _compressVideo(File file) async {
    MediaInfo? info = await VideoCompress.compressVideo(file.path, quality: VideoQuality.DefaultQuality, deleteOrigin: false, includeAudio: true, frameRate: 24);
    if (info != null) {
      File compressedVideo = File(info.path!);
      return compressedVideo;
    } else {
      return file;
    }
  }

  static Future<String?> uploadVideoStory(File video, BuildContext context) async {
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('Story/$uniqueID.mp4');
    File compressedVideo = await _compressVideo(video);
    SettableMetadata metadata = SettableMetadata(contentType: 'video');
    UploadTask uploadTask = upload.putFile(compressedVideo, metadata);
    var storageRef = (await uploadTask.whenComplete(() {})).ref;
    var downloadUrl = await storageRef.getDownloadURL();

    return downloadUrl.toString();
  }

  static Future<String> uploadVideoThumbnailToFireStorage(File file) async {
    var uniqueID = const Uuid().v4();
    Reference upload = FirebaseStorage.instance.ref().child('thumbnails/$uniqueID.png');
    UploadTask uploadTask = upload.putFile(file);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<StoryModel?> getStory(String vendorId) async {
    DocumentSnapshot<Map<String, dynamic>> userDocument = await fireStore.collection(CollectionName.story).doc(vendorId).get();
    if (userDocument.data() != null && userDocument.exists) {
      return StoryModel.fromJson(userDocument.data()!);
    } else {
      return null;
    }
  }

  static Future addOrUpdateStory(StoryModel storyModel) async {
    try {
      await fireStore.collection(CollectionName.story).doc(storyModel.vendorID).set(storyModel.toJson());
    } catch (e) {
      ShowToastDialog.closeLoader();
    }
  }

  static Future removeStory(String vendorId) async {
    await fireStore.collection(CollectionName.story).doc(vendorId).delete();
  }

  static Future<WithdrawMethodModel?> getWithdrawMethod({required String userId}) async {
    log("userId :: ${userId.toString()}");
    WithdrawMethodModel? withdrawMethodModel;

    await fireStore.collection(CollectionName.withdrawMethod).where("userId", isEqualTo: userId).get().then((value) async {
      if (value.docs.isNotEmpty) {
        withdrawMethodModel = WithdrawMethodModel.fromJson(value.docs.first.data());
      }
    });
    return withdrawMethodModel;
  }

  static Future<WithdrawMethodModel?> setWithdrawMethod(WithdrawMethodModel withdrawMethodModel) async {
    if (withdrawMethodModel.id == null) {
      withdrawMethodModel.id = const Uuid().v4();
      if (Constant.userModel?.role == Constant.userRoleEmployee) {
        VendorModel? vendorModel = await FireStoreUtils.getVendorById(Constant.userModel!.vendorID!);
        withdrawMethodModel.userId = vendorModel?.author ?? '';
      } else {
        withdrawMethodModel.userId = FireStoreUtils.getCurrentUid();
      }
    }
    await fireStore.collection(CollectionName.withdrawMethod).doc(withdrawMethodModel.id).set(withdrawMethodModel.toJson()).then((value) async {});
    return withdrawMethodModel;
  }

  static Future<EmailTemplateModel?> getEmailTemplates(String type) async {
    EmailTemplateModel? emailTemplateModel;
    await fireStore.collection(CollectionName.emailTemplates).where('type', isEqualTo: type).get().then((value) {
      if (value.docs.isNotEmpty) {
        emailTemplateModel = EmailTemplateModel.fromJson(value.docs.first.data());
      }
    });
    return emailTemplateModel;
  }

  static Future<void> sendPayoutMail({required String amount, required String payoutrequestid}) async {
    EmailTemplateModel? emailTemplateModel = await FireStoreUtils.getEmailTemplates(Constant.payoutRequest);

    String body = emailTemplateModel!.subject.toString();
    body = body.replaceAll("{userid}", Constant.userModel!.id.toString());

    String newString = emailTemplateModel.message.toString();
    newString = newString.replaceAll("{username}", Constant.userModel!.fullName());
    newString = newString.replaceAll("{userid}", Constant.userModel!.id.toString());
    newString = newString.replaceAll("{amount}", Constant.amountShow(amount: amount));
    newString = newString.replaceAll("{payoutrequestid}", payoutrequestid.toString());
    newString = newString.replaceAll("{usercontactinfo}", "${Constant.userModel!.email}\n${Constant.userModel!.phoneNumber}");
    await Constant.sendMail(subject: body, isAdmin: emailTemplateModel.isSendToAdmin, body: newString, recipients: [Constant.userModel!.email]);
  }

  static Future<NotificationModel?> getNotificationContent(String type) async {
    NotificationModel? notificationModel;
    await fireStore.collection(CollectionName.dynamicNotification).where('type', isEqualTo: type).get().then((value) {
      print("------>");
      if (value.docs.isNotEmpty) {
        print(value.docs.first.data());

        notificationModel = NotificationModel.fromJson(value.docs.first.data());
      } else {
        notificationModel = NotificationModel(id: "", message: "Notification setup is pending", subject: "setup notification", type: "");
      }
    });
    return notificationModel;
  }

  static Future<bool?> setBookedOrder(DineInBookingModel orderModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.bookedTable).doc(orderModel.id).set(orderModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<bool?> setProduct(ProductModel orderModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.vendorProducts).doc(orderModel.id).set(orderModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    // menuVersion bumped by onVendorProductWrite Cloud Function only.
    return isAdded;
  }

  static Future<String> uploadUserImageToFireStorage(File image, String userID) async {
    Reference upload = FirebaseStorage.instance.ref().child('images/$userID.png');
    UploadTask uploadTask = upload.putFile(image);
    var downloadUrl = await (await uploadTask.whenComplete(() {})).ref.getDownloadURL();
    return downloadUrl.toString();
  }

  static Future<List<SubscriptionPlanModel>> getAllSubscriptionPlans() async {
    List<SubscriptionPlanModel> subscriptionPlanModels = [];
    await fireStore.collection(CollectionName.subscriptionPlans).where('isEnable', isEqualTo: true).orderBy('place', descending: false).get().then((value) async {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          SubscriptionPlanModel subscriptionPlanModel = SubscriptionPlanModel.fromJson(element.data());
          if (subscriptionPlanModel.id != Constant.commissionSubscriptionID) {
            subscriptionPlanModels.add(subscriptionPlanModel);
          }
        }
      }
    });
    return subscriptionPlanModels;
  }

  static Future<SubscriptionPlanModel?> getSubscriptionPlanById({required String planId}) async {
    SubscriptionPlanModel? subscriptionPlanModel = SubscriptionPlanModel();
    if (planId.isNotEmpty) {
      await fireStore.collection(CollectionName.subscriptionPlans).doc(planId).get().then((value) async {
        if (value.exists) {
          subscriptionPlanModel = SubscriptionPlanModel.fromJson(value.data() as Map<String, dynamic>);
        }
      });
    }
    return subscriptionPlanModel;
  }

  static Future<SubscriptionPlanModel> setSubscriptionPlan(SubscriptionPlanModel subscriptionPlanModel) async {
    if (subscriptionPlanModel.id?.isEmpty == true) {
      subscriptionPlanModel.id = const Uuid().v4();
    }
    await fireStore.collection(CollectionName.subscriptionPlans).doc(subscriptionPlanModel.id).set(subscriptionPlanModel.toJson()).then((value) async {});
    return subscriptionPlanModel;
  }

  static Future<bool?> setSubscriptionTransaction(SubscriptionHistoryModel subscriptionPlan) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.subscriptionHistory).doc(subscriptionPlan.id).set(subscriptionPlan.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<SubscriptionHistoryModel>> getSubscriptionHistory() async {
    List<SubscriptionHistoryModel> subscriptionHistoryList = [];
    await fireStore.collection(CollectionName.subscriptionHistory).where('user_id', isEqualTo: getCurrentUid()).orderBy('createdAt', descending: true).get().then((value) async {
      if (value.docs.isNotEmpty) {
        for (var element in value.docs) {
          SubscriptionHistoryModel subscriptionHistoryModel = SubscriptionHistoryModel.fromJson(element.data());
          subscriptionHistoryList.add(subscriptionHistoryModel);
        }
      }
    });
    return subscriptionHistoryList;
  }

  static Future<AdvertisementModel> firebaseCreateAdvertisement(AdvertisementModel model) async {
    await fireStore.collection(CollectionName.advertisements).doc(model.id).set(model.toJson());
    return model;
  }

  static Future<AdvertisementModel> removeAdvertisement(AdvertisementModel model) async {
    await fireStore.collection(CollectionName.advertisements).doc(model.id).delete();
    return model;
  }

  static Future<AdvertisementModel> pauseAndResumeAdvertisement(AdvertisementModel model) async {
    await fireStore.collection(CollectionName.advertisements).doc(model.id).update(model.toJson());
    return model;
  }

  static Future<List<RatingModel>> getOrderReviewsByVenderId({required String venderId}) async {
    List<RatingModel> ratingModelList = [];
    await fireStore.collection(CollectionName.foodsReview).where('VendorId', isEqualTo: venderId).get().then((value) {
      print("======>");
      print(value.docs.length);
      if (value.docs.isNotEmpty) {
        for (int i = 0; i < value.docs.length; i++) {
          ratingModelList.add(RatingModel.fromJson(value.docs[i].data()));
        }
      }
    }).catchError((error) {
      log(error.toString());
    });
    return ratingModelList;
  }

  static Future<List<UserModel>> getAvalibleDrivers() async {
    List<UserModel> driverList = [];
    try {
      log("getAvalibleDrivers :: 22");
      await fireStore
          .collection(CollectionName.users)
          .where('vendorID', isEqualTo: Constant.userModel?.vendorID)
          .where('role', isEqualTo: Constant.userRoleDriver)
          .where('active', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          for (int i = 0; i < value.docs.length; i++) {
            driverList.add(UserModel.fromJson(value.docs[i].data()));
          }
        }
      });
    } catch (e) {
      log("Error fetching drivers: ${e.toString()}");
    }

    return driverList;
  }

  static Future<List<UserModel>> getAllDrivers() async {
    List<UserModel> driverList = [];
    try {
      await fireStore
          .collection(CollectionName.users)
          .where('vendorID', isEqualTo: Constant.userModel?.vendorID)
          .where('role', isEqualTo: Constant.userRoleDriver)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          for (int i = 0; i < value.docs.length; i++) {
            driverList.add(UserModel.fromJson(value.docs[i].data()));
          }
        }
      });
    } catch (e) {
      log("Error fetching drivers: ${e.toString()}");
    }
    return driverList;
  }

  static late StreamSubscription<QuerySnapshot> adminChatSeenSubscription;

  static void setSeen() {
    final currentUserId = FireStoreUtils.getCurrentUid();

    adminChatSeenSubscription = fireStore
        .collection(CollectionName.chat)
        .doc(currentUserId)
        .collection("thread")
        .where('senderId', isEqualTo: Constant.adminType)
        .where('seen', isEqualTo: false)
        .snapshots()
        .listen((querySnapshot) async {
      for (final doc in querySnapshot.docs) {
        try {
          await doc.reference.update({'seen': true});
        } catch (e) {
          log(e.toString());
        }
      }
    }, onError: (error) {
      log(error.toString());
    });
  }

  static void stopSeenListener() {
    adminChatSeenSubscription.cancel();
  }

  static Future<ConversationModel> addChat(ConversationModel conversationModel) async {
    final chatCollection = fireStore.collection(CollectionName.chat);
    final docId = (conversationModel.receiverId?.contains('admin') == false)
        ? conversationModel.orderId
        : (conversationModel.orderId != null)
            ? conversationModel.orderId
            : conversationModel.senderId;
    await chatCollection.doc(docId).collection("thread").doc(conversationModel.id).set(conversationModel.toJson());
    return conversationModel;
  }

  static Future<InboxModel> addInbox(InboxModel inboxModel) async {
    final collection = fireStore.collection(CollectionName.chat);
    final docId = (inboxModel.senderReceiverId?.contains('admin') == false)
        ? inboxModel.orderId
        : (inboxModel.orderId != null)
            ? inboxModel.orderId
            : inboxModel.senderId;
    await collection.doc(docId).set(inboxModel.toJson());
    return inboxModel;
  }

  static Future<bool?> setEmployeeRole(EmployeeRoleModel employeeRoleModel) async {
    bool isAdded = false;
    await fireStore.collection(CollectionName.vendorEmployeeRoles).doc(employeeRoleModel.id).set(employeeRoleModel.toJson()).then((value) {
      isAdded = true;
    }).catchError((error) {
      log("Failed to update user: $error");
      isAdded = false;
    });
    return isAdded;
  }

  static Future<List<EmployeeRoleModel>> getAllEmployeeRoles({bool isActive = false}) async {
    try {
      var query = fireStore.collection(CollectionName.vendorEmployeeRoles).where('vendorId', isEqualTo: Constant.userModel?.vendorID);
      if (isActive) {
        query = query.where('isEnable', isEqualTo: true);
      }
      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        return EmployeeRoleModel.fromJson(doc.data());
      }).toList();
    } catch (error) {
      log("Failed to get employee roles: $error");
      return [];
    }
  }

  static Future<EmployeeRoleModel?> getEmployeeRoleById(String id) async {
    try {
      final docSnapshot = await fireStore.collection(CollectionName.vendorEmployeeRoles).doc(id).get();
      log("docSnapshot.data() :: ${docSnapshot.data()}");
      if (docSnapshot.exists && docSnapshot.data() != null) {
        return EmployeeRoleModel.fromJson(docSnapshot.data()!);
      }
      return null; // Not found
    } catch (error) {
      log("Failed to get employee role by ID: $error");
      return null;
    }
  }

  static Future<bool> deleteEmployeeRole(String id) async {
    bool isDeleted = false;
    await fireStore.collection(CollectionName.vendorEmployeeRoles).doc(id).delete().then((value) {
      isDeleted = true;
    }).catchError((error) {
      log("Failed to delete employee role: $error");
      isDeleted = false;
    });
    return isDeleted;
  }

  static Future<List<UserModel>> getAllEmployee() async {
    List<UserModel> employeeList = [];
    try {
      await fireStore
          .collection(CollectionName.users)
          .where('vendorID', isEqualTo: Constant.userModel?.vendorID)
          .where('role', isEqualTo: Constant.userRoleEmployee)
          .orderBy('createdAt', descending: true)
          .get()
          .then((value) {
        log("value.docs.isNotEmpty :: ${value.docs.length}");
        if (value.docs.isNotEmpty) {
          for (int i = 0; i < value.docs.length; i++) {
            employeeList.add(UserModel.fromJson(value.docs[i].data()));
          }
        }
      });
    } catch (e) {
      log("Error fetching drivers: ${e.toString()}");
    }
    return employeeList;
  }

  static Future<UserModel?> getUserByPhoneNumber(
      {required String countryCode, required String phoneNumber}) async {
    UserModel? userModel;
    try {
      final snapshot = await fireStore
          .collection(CollectionName.users)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .where('countryCode', isEqualTo: countryCode)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        userModel = UserModel.fromJson(snapshot.docs.first.data());
        userModel.id ??= snapshot.docs.first.id;
      }
    } catch (error) {
      log("Failed to get user by phone: $error");
    }
    return userModel;
  }

  static Future<UserModel?> getUserByEmail(String email) async {
    UserModel? userModel;
    final normalizedEmail = email.trim().toLowerCase();
    try {
      QuerySnapshot snapshot = await fireStore.collection(CollectionName.users).where('email', isEqualTo: normalizedEmail).limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        userModel = UserModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        userModel = null; // No user found
      }
    } catch (error) {
      log("Failed to get user by email: $error");
      userModel = null;
    }

    return userModel;
  }

  static late StreamSubscription<QuerySnapshot> orderChatSeenSubscription;

  static void setSeenChatForOrder({required String orderId}) {
    orderChatSeenSubscription = fireStore
        .collection(CollectionName.chat)
        .doc(orderId)
        .collection("thread")
        .where('senderId', isNotEqualTo: FireStoreUtils.getCurrentUid())
        .where('seen', isEqualTo: false)
        .snapshots()
        .listen((querySnapshot) async {
      for (final doc in querySnapshot.docs) {
        try {
          await doc.reference.update({'seen': true});
        } catch (e) {
          log(e.toString());
        }
      }
    }, onError: (error) {
      log(error.toString());
    });
  }

  static Future<UserModel?> getUserByEmailRole(String email) async {
    UserModel? userModel;
    final normalizedEmail = email.trim().toLowerCase();
    try {
      QuerySnapshot snapshot = await fireStore
          .collection(CollectionName.users)
          .where('role', whereIn: [
            Constant.userRoleVendor,
            Constant.userRoleEmployee,
          ])
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        userModel = UserModel.fromJson(snapshot.docs.first.data() as Map<String, dynamic>);
      } else {
        userModel = null; // No user found
      }
    } catch (error) {
      log("Failed to get user by email: $error");
      userModel = null;
    }

    return userModel;
  }

  static void stopSeenForOrderListener() {
    orderChatSeenSubscription.cancel();
  }
}
