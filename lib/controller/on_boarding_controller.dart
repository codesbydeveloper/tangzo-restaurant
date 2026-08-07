import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant/models/on_boarding_model.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class OnBoardingController extends GetxController {
  var selectedPageIndex = 0.obs;

  bool get isLastPage => selectedPageIndex.value == onBoardingList.length - 1;
  var pageController = PageController();

  @override
  void onInit() {
    getOnBoardingData();
    super.onInit();
  }

  RxBool isLoading = true.obs;
  RxList<OnBoardingModel> onBoardingList = <OnBoardingModel>[].obs;

  Future<void> getOnBoardingData() async {
    await FireStoreUtils.getOnBoardingList().then((value) {
      // Only show the second onboarding screen
      if (value.length > 1) {
        onBoardingList.value = [value[1]];
      } else if (value.isNotEmpty) {
        onBoardingList.value = [value.first];
      } else {
        onBoardingList.value = value;
      }
    });

    isLoading.value = false;
    update();
  }
}
