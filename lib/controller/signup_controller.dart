import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:restaurant/app/auth_screen/login_screen.dart';
import 'package:restaurant/app/dash_board_screens/app_not_access_screen.dart';
import 'package:restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant/app/subscription_plan_screen/subscription_plan_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignupController extends GetxController {
  Rx<TextEditingController> firstNameEditingController = TextEditingController().obs;
  Rx<TextEditingController> lastNameEditingController = TextEditingController().obs;
  Rx<TextEditingController> emailEditingController = TextEditingController().obs;
  Rx<TextEditingController> phoneNUmberEditingController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController = TextEditingController(text: Constant.defaultCountryCode).obs;
  Rx<TextEditingController> countryISOCodeEditingController = TextEditingController(text: Constant.defaultCountryCode).obs;
  Rx<TextEditingController> passwordEditingController = TextEditingController().obs;
  Rx<TextEditingController> conformPasswordEditingController = TextEditingController().obs;

  RxBool passwordVisible = true.obs;
  RxBool conformPasswordVisible = true.obs;

  RxString type = "".obs;

  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    super.onInit();
  }

  void getArgument() {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      type.value = argumentData['type'];
      userModel.value = argumentData['userModel'];
      if (type.value == "mobileNumber" || type.value == "whatsapp") {
        phoneNUmberEditingController.value.text = userModel.value.phoneNumber.toString();
        countryCodeEditingController.value.text = userModel.value.countryCode.toString();
        countryISOCodeEditingController.value.text = userModel.value.countryISOCode.toString();
      } else if (type.value == "google" || type.value == "apple") {
        emailEditingController.value.text = userModel.value.email ?? "";
        firstNameEditingController.value.text = userModel.value.firstName ?? "";
        lastNameEditingController.value.text = userModel.value.lastName ?? "";
      }
    }
  }

  Future<void> signUpWithEmailAndPassword() async {
    signUp();
  }

  Future<void> signUp() async {
    final isSocialSignUp = type.value == "google" || type.value == "apple";
    if (!isSocialSignUp) {
      ShowToastDialog.showLoader("Please wait");
    }
    if (type.value == "google" || type.value == "apple" || type.value == "mobileNumber") {
      userModel.value.firstName = firstNameEditingController.value.text.toString();
      userModel.value.lastName = lastNameEditingController.value.text.toString();
      userModel.value.email = emailEditingController.value.text.toString().toLowerCase();
      userModel.value.phoneNumber = phoneNUmberEditingController.value.text.toString();
      userModel.value.role = Constant.userRoleVendor;
      userModel.value.fcmToken = await NotificationService.getToken();
      userModel.value.active = Constant.autoApproveRestaurant == true ? true : false;
      userModel.value.countryCode = countryCodeEditingController.value.text;
      userModel.value.countryISOCode = countryISOCodeEditingController.value.text;
      userModel.value.isDocumentVerify = Constant.isRestaurantVerification == true ? false : true;
      userModel.value.createdAt = Timestamp.now();
      userModel.value.appIdentifier = Platform.isAndroid ? 'android' : 'ios';
      userModel.value.isAutoVerify = Constant.isRestaurantVerification == true ? false : true;

      await FireStoreUtils.updateUser(userModel.value).then(
        (value) async {
          if (Constant.autoApproveRestaurant == true) {
            bool isPlanExpire = false;
            if (userModel.value.subscriptionPlan?.id != null) {
              if (userModel.value.subscriptionExpiryDate == null) {
                if (userModel.value.subscriptionPlan?.expiryDay == '-1') {
                  isPlanExpire = false;
                } else {
                  isPlanExpire = true;
                }
              } else {
                DateTime expiryDate = userModel.value.subscriptionExpiryDate!.toDate();
                isPlanExpire = expiryDate.isBefore(DateTime.now());
              }
            } else {
              isPlanExpire = true;
            }
            if (userModel.value.subscriptionPlanId == null || isPlanExpire == true) {
              if (Constant.adminCommission?.isEnabled == false && Constant.isSubscriptionModelApplied == false) {
                Get.offAll(const DashBoardScreen());
              } else {
                Get.offAll(const SubscriptionPlanScreen());
              }
            } else if (userModel.value.subscriptionPlan?.features?.restaurantMobileApp != false || userModel.value.subscriptionPlan?.type == 'free') {
              Get.offAll(const DashBoardScreen());
            } else {
              Get.offAll(const AppNotAccessScreen());
            }
          } else {
            ShowToastDialog.showToast("Thank you for sign up, your application is under approval so please wait till that approve.");
            Get.offAll(const LoginScreen());
          }
        },
      );
    } else {
      try {
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailEditingController.value.text.trim(),
          password: passwordEditingController.value.text.trim(),
        );
        if (credential.user != null) {
          userModel.value.id = credential.user!.uid;
          userModel.value.firstName = firstNameEditingController.value.text.toString();
          userModel.value.lastName = lastNameEditingController.value.text.toString();
          userModel.value.email = emailEditingController.value.text.toString().toLowerCase();
          userModel.value.phoneNumber = phoneNUmberEditingController.value.text.toString();
          userModel.value.role = Constant.userRoleVendor;
          userModel.value.fcmToken = await NotificationService.getToken();
          userModel.value.active = Constant.autoApproveRestaurant == true ? true : false;
          userModel.value.isDocumentVerify = Constant.isRestaurantVerification == true ? false : true;
          userModel.value.countryCode = countryCodeEditingController.value.text;
          userModel.value.countryISOCode = countryISOCodeEditingController.value.text;
          userModel.value.appIdentifier = Platform.isAndroid ? 'android' : 'ios';
          userModel.value.createdAt = Timestamp.now();
          userModel.value.provider = type.value == "whatsapp" ? 'whatsapp' : 'email';
          userModel.value.isAutoVerify = Constant.isRestaurantVerification == true ? false : true;

          await FireStoreUtils.updateUser(userModel.value).then(
            (value) async {
              if (Constant.autoApproveRestaurant == true) {
                bool isPlanExpire = false;
                if (userModel.value.subscriptionPlan?.id != null) {
                  if (userModel.value.subscriptionExpiryDate == null) {
                    if (userModel.value.subscriptionPlan?.expiryDay == '-1') {
                      isPlanExpire = false;
                    } else {
                      isPlanExpire = true;
                    }
                  } else {
                    DateTime expiryDate = userModel.value.subscriptionExpiryDate!.toDate();
                    isPlanExpire = expiryDate.isBefore(DateTime.now());
                  }
                } else {
                  isPlanExpire = true;
                }
                if (userModel.value.subscriptionPlanId == null || isPlanExpire == true) {
                  if (Constant.adminCommission?.isEnabled == false && Constant.isSubscriptionModelApplied == false) {
                    Get.offAll(const DashBoardScreen());
                  } else {
                    Get.offAll(const SubscriptionPlanScreen());
                  }
                } else if (userModel.value.subscriptionPlan?.features?.restaurantMobileApp != false || userModel.value.subscriptionPlan?.type == 'free') {
                  Get.offAll(const DashBoardScreen());
                } else {
                  Get.offAll(const AppNotAccessScreen());
                }
              } else {
                ShowToastDialog.showToast("Thank you for sign up, your application is under approval so please wait till that approve.");
                Get.offAll(const LoginScreen());
              }
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ShowToastDialog.showToast("The password provided is too weak.");
        } else if (e.code == 'email-already-in-use') {
          ShowToastDialog.showToast("The account already exists for that email.");
        } else if (e.code == 'invalid-email') {
          ShowToastDialog.showToast("Enter email is Invalid");
        }
      } catch (e) {
        ShowToastDialog.showToast(e.toString());
      }
    }

    if (!isSocialSignUp) {
      ShowToastDialog.closeLoader();
    }
  }
}
