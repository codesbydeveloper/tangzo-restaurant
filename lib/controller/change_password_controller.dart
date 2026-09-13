import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';

class ChangePasswordController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<TextEditingController> emailEditingController = TextEditingController().obs;

  Future<void> forgotPassword() async {
    final email = emailEditingController.value.text.trim().toLowerCase();
    try {
      if (email.isEmpty) {
        ShowToastDialog.showToast("Please enter a valid email.");
        return;
      }
      ShowToastDialog.showLoader("Please wait");
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('${'Reset Password link sent your'.tr} $email ${'email'.tr}');
      Get.back();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ShowToastDialog.showToast('No user found for that email.');
      } else {
        ShowToastDialog.showToast(e.message ?? 'An error occurred');
      }
      ShowToastDialog.closeLoader();
    }
  }
}
