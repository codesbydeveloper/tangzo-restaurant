import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/currency_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../constant/collection_name.dart';

class GlobalSettingController extends GetxController {
  @override
  void onInit() {
    notificationInit();
    getCurrentCurrency();

    super.onInit();
  }

  Future<void> getCurrentCurrency() async {
    // Force INR (₹) for Cashfree / India payments
    Constant.currencyModel = CurrencyModel(id: "", code: "INR", decimalDigits: 2, enable: true, name: "Indian Rupee", symbol: "₹", symbolAtRight: false);
    FireStoreUtils.fireStore.collection(CollectionName.currencies).where("isActive", isEqualTo: true).snapshots().listen((event) {
      if (event.docs.isNotEmpty) {
        final model = CurrencyModel.fromJson(event.docs.first.data());
        // Keep ₹ even if admin panel has another symbol configured
        model.symbol = "₹";
        model.code = "INR";
        model.name = "Indian Rupee";
        model.symbolAtRight = false;
        Constant.currencyModel = model;
      } else {
        Constant.currencyModel = CurrencyModel(id: "", code: "INR", decimalDigits: 2, enable: true, name: "Indian Rupee", symbol: "₹", symbolAtRight: false);
      }
    });
    await FireStoreUtils.getSettings();
  }

  NotificationService notificationService = NotificationService();

  Future<void> notificationInit() async {
    notificationService.initInfo().then((value) async {
      String? token = await NotificationService.getToken();
      if (FirebaseAuth.instance.currentUser != null) {
        await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
          if (value != null) {
            UserModel model = value;
            model.fcmToken = token;
            FireStoreUtils.updateUser(model);
          }
        });
      }
    });
  }
}
