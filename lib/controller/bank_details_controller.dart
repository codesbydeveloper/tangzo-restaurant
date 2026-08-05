import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/models/vendor_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class BankDetailsController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> bankNameController = TextEditingController().obs;
  Rx<TextEditingController> branchNameController = TextEditingController().obs;
  Rx<TextEditingController> holderNameController = TextEditingController().obs;
  Rx<TextEditingController> accountNoController = TextEditingController().obs;
  Rx<TextEditingController> otherInfoController = TextEditingController().obs;

  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getCurrentUser();
    super.onInit();
  }

  Future<void> saveBank() async {
    ShowToastDialog.showLoader("Please wait");
    userModel.value.userBankDetails ??= UserBankDetails();
    userModel.value.userBankDetails!.accountNumber = accountNoController.value.text;
    userModel.value.userBankDetails!.bankName = bankNameController.value.text;
    userModel.value.userBankDetails!.branchName = branchNameController.value.text;
    userModel.value.userBankDetails!.holderName = holderNameController.value.text;
    userModel.value.userBankDetails!.otherDetails = otherInfoController.value.text;

    await FireStoreUtils.updateUser(userModel.value).then(
      (value) {
        ShowToastDialog.closeLoader();
        Get.back(result: userModel.value.userBankDetails?.accountNumber.trim() == '' ? false : true);
      },
    );
  }

  Future<void> getCurrentUser() async {
    String userId;
    if (Constant.userModel?.role == Constant.userRoleEmployee) {
      VendorModel? vendorModel = await FireStoreUtils.getVendorById(Constant.userModel!.vendorID!);
      userId = vendorModel?.author ?? '';
    } else {
      userId = FireStoreUtils.getCurrentUid();
    }
    await FireStoreUtils.getUserProfile(userId).then(
      (value) {
        if (value != null) {
          userModel.value = value;
          if (userModel.value.userBankDetails != null) {
            bankNameController.value.text = userModel.value.userBankDetails!.bankName.toString();
            branchNameController.value.text = userModel.value.userBankDetails!.branchName.toString();
            holderNameController.value.text = userModel.value.userBankDetails!.holderName.toString();
            accountNoController.value.text = userModel.value.userBankDetails!.accountNumber.toString();
            otherInfoController.value.text = userModel.value.userBankDetails!.otherDetails.toString();
          }
        }
      },
    );
    isLoading.value = false;
  }
}
