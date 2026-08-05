import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
// import 'package:restaurant/utils/dynamic_traslator.dart';

class ShowToastDialog {
  static Future<void> showToast(String? message, {EasyLoadingToastPosition position = EasyLoadingToastPosition.top}) async {
    // String translated = await DynamicTranslator.translate(message ?? '');
    EasyLoading.showToast("$message".tr, toastPosition: position);
  }

  static Future<void> showToastDuration(String? message, {EasyLoadingToastPosition position = EasyLoadingToastPosition.top, required Duration duration}) async {
    // String translated = await DynamicTranslator.translate(message ?? '');
    EasyLoading.showToast("$message".tr, toastPosition: position, duration: duration);
  }

  static Future<void> showLoader(String message) async {
    // String translated = await DynamicTranslator.translate(message);
    EasyLoading.show(status: message.tr, maskType: EasyLoadingMaskType.black, dismissOnTap: false);
  }

  static void closeLoader() {
    EasyLoading.dismiss();
  }
}
