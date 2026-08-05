import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/models/vendor_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class AddDriverController extends GetxController {
  RxBool isLoading = true.obs;
  Rx<TextEditingController> firstNameEditingController = TextEditingController().obs;
  Rx<TextEditingController> lastNameEditingController = TextEditingController().obs;
  Rx<TextEditingController> emailEditingController = TextEditingController().obs;
  Rx<TextEditingController> phoneNUmberEditingController = TextEditingController().obs;
  Rx<TextEditingController> countryCodeEditingController = TextEditingController(text: Constant.defaultCountryCode).obs;
  Rx<TextEditingController> countryISOCodeEditingController = TextEditingController(text: Constant.defaultCountryCode).obs;
  Rx<TextEditingController> passwordEditingController = TextEditingController().obs;
  RxBool passwordVisible = true.obs;
  Rx<TextEditingController> conformPasswordEditingController = TextEditingController().obs;
  RxBool conformPasswordVisible = true.obs;
  Rx<VendorModel> vendorModel = VendorModel().obs;

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  Future<void> getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      driverModel.value = argumentData['driverModel'];
      if (driverModel.value.id != null) {
        firstNameEditingController.value.text = driverModel.value.firstName ?? '';
        lastNameEditingController.value.text = driverModel.value.lastName ?? '';
        emailEditingController.value.text = driverModel.value.email ?? '';
        phoneNUmberEditingController.value.text = driverModel.value.phoneNumber ?? '';
        countryCodeEditingController.value.text = driverModel.value.countryCode ?? '';
        countryISOCodeEditingController.value.text = driverModel.value.countryISOCode ?? '';
      }
    }
    await FireStoreUtils.getVendorById(Constant.userModel!.vendorID.toString()).then((value) {
      if (value != null) {
        vendorModel.value = value;
      }
    });
    isLoading.value = false;
  }

  Future<void> signUpWithEmailAndPassword() async {
    signUp();
  }

  Rx<UserModel> driverModel = UserModel().obs;
  Future<Null> signUp() async {
    ShowToastDialog.showLoader("Please wait");

    try {
      if (driverModel.value.id != null && driverModel.value.id != '') {
        driverModel.value.firstName = firstNameEditingController.value.text.trim();
        driverModel.value.lastName = lastNameEditingController.value.text.trim();
        driverModel.value.email = emailEditingController.value.text.trim();
        driverModel.value.phoneNumber = phoneNUmberEditingController.value.text.trim();
        driverModel.value.countryCode = countryCodeEditingController.value.text.trim();
        driverModel.value.countryISOCode = countryISOCodeEditingController.value.text.trim();
        driverModel.value.zoneId = vendorModel.value.id;
        driverModel.value.isAutoVerify = Constant.userModel?.isAutoVerify;
      } else {
        FirebaseApp secondaryApp = await Firebase.initializeApp(
          name: 'SecondaryApp',
          options: Firebase.app().options,
        );

        FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
        final credential = await secondaryAuth.createUserWithEmailAndPassword(
          email: emailEditingController.value.text.trim(),
          password: passwordEditingController.value.text.trim(),
        );
        if (credential.user != null) {
          driverModel.value.firstName = firstNameEditingController.value.text.trim();
          driverModel.value.lastName = lastNameEditingController.value.text.trim();
          driverModel.value.email = emailEditingController.value.text.trim().toLowerCase();
          driverModel.value.phoneNumber = phoneNUmberEditingController.value.text.trim();
          driverModel.value.role = Constant.userRoleDriver;
          driverModel.value.fcmToken = '';
          driverModel.value.active = true;
          driverModel.value.isDocumentVerify = true;
          driverModel.value.countryCode = countryCodeEditingController.value.text.trim();
          driverModel.value.countryISOCode = countryISOCodeEditingController.value.text.trim();
          driverModel.value.createdAt = Timestamp.now();
          driverModel.value.zoneId = vendorModel.value.id;
          driverModel.value.appIdentifier = Platform.isAndroid ? 'android' : 'ios';
          driverModel.value.provider = 'email';
          driverModel.value.vendorID = Constant.userModel?.vendorID;
          driverModel.value.id = credential.user!.uid;
          driverModel.value.isAutoVerify = Constant.userModel?.isAutoVerify;
        } else {
          ShowToastDialog.showToast("Something went to wrong");
          return null;
        }
        await secondaryApp.delete();
      }
      await FireStoreUtils.updateUser(driverModel.value).then(
        (value) async {
          if (value == true) {
            Get.back(result: true);
            ShowToastDialog.showToast("Delivery man details saved successfully!");
          } else {
            ShowToastDialog.showToast("Something went to wrong");
          }
        },
      );
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

    ShowToastDialog.closeLoader();
  }
}
