import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/currency_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class GlobalSettingController extends GetxController {
  @override
  void onInit() {
    notificationInit();
    getCurrentCurrency();

    super.onInit();
  }

  Future<void> getCurrentCurrency() async {
    // Force INR (₹) for Cashfree / India payments — no live currencies listener.
    Constant.currencyModel = CurrencyModel(
      id: "",
      code: "INR",
      decimalDigits: 2,
      enable: true,
      name: "Indian Rupee",
      symbol: "₹",
      symbolAtRight: false,
    );
    await FireStoreUtils.getSettings();
  }

  NotificationService notificationService = NotificationService();

  Future<void> notificationInit() async {
    notificationService.initInfo().then((value) async {
      // FCM token write is owned by SplashController (partial update only).
      if (FirebaseAuth.instance.currentUser == null) return;
      final token = await NotificationService.getToken();
      await FireStoreUtils.updateFcmTokenIfChanged(
        userId: FireStoreUtils.getCurrentUid(),
        token: token,
      );
    });
  }
}
