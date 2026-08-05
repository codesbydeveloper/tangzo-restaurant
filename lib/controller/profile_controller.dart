import 'dart:developer';
import 'package:get/get.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/tax_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/preferences.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<UserModel> userModel = UserModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getUserProfile();
    getThem();
    super.onInit();
  }

  Future<void> getUserProfile({Map<String, dynamic>? location}) async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then(
      (value) {
        if (value != null) {
          userModel.value = value;
        }
      },
    );
    if (location != null) {
      await getProductTax(
        latitude: location['lat'],
        longitude: location['lng'],
      );
    }
    isLoading.value = false;
  }

  Future<void> getProductTax({required double latitude, required double longitude}) async {
    await FireStoreUtils.getTaxList(latitude, longitude).then((value) {
      if (value != null) {
        Constant.taxProductList = value.where((TaxModel taxModel) => taxModel.scope == "product" && taxModel.enable == true).toList();
        log("getProductTax :: ${Constant.taxProductList?.length}");
      }
    });
  }

  RxString isDarkMode = "Light".obs;
  RxBool isDarkModeSwitch = false.obs;

  void getThem() {
    isDarkMode.value = Preferences.getString(Preferences.themKey);
    if (isDarkMode.value == "Dark") {
      isDarkModeSwitch.value = true;
    } else if (isDarkMode.value == "Light") {
      isDarkModeSwitch.value = false;
    } else {
      isDarkModeSwitch.value = false;
    }
    isLoading.value = false;
  }

  Future<bool> deleteUserFromServer() async {
    var url = '${Constant.storeUrl}/api/delete-user';
    try {
      var response = await http.post(
        Uri.parse(url),
        body: {
          'uuid': FireStoreUtils.getCurrentUid(),
        },
      );
      log("deleteUserFromServer :: ${response.body}");
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
