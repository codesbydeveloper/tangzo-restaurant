import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant/constant/collection_name.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/order_model.dart';
import 'package:restaurant/models/tax_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/models/vendor_model.dart';
import 'package:restaurant/service/audio_player_service.dart';
import 'package:restaurant/utils/fire_store_utils.dart';

class HomeController extends GetxController {
  RxBool isLoading = true.obs;

  Rx<TextEditingController> estimatedTimeController = TextEditingController().obs;

  RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getUserProfile();
    super.onInit();
  }

  RxList<OrderModel> allOrderList = <OrderModel>[].obs;
  RxList<OrderModel> newOrderList = <OrderModel>[].obs;
  RxList<OrderModel> acceptedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> completedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> rejectedOrderList = <OrderModel>[].obs;
  RxList<OrderModel> cancelledOrderList = <OrderModel>[].obs;

  Rx<UserModel> userModel = UserModel().obs;
  Rx<VendorModel> vendermodel = VendorModel().obs;

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

    if (userModel.value.vendorID != null || userModel.value.vendorID?.isNotEmpty == true) {
      await FireStoreUtils.getVendorById(userModel.value.vendorID!).then(
        (vender) async {
          if (vender?.id != null) {
            vendermodel.value = vender!;
          }
        },
      );
    }

    await getOrder();
    isLoading.value = false;
  }

  Future<void> getProductTax({required double latitude, required double longitude}) async {
    await FireStoreUtils.getTaxList(latitude, longitude).then((value) {
      if (value != null) {
        Constant.taxProductList = value.where((TaxModel taxModel) => taxModel.scope == "product" && taxModel.enable == true).toList();
      }
    });
  }

  RxList<UserModel> driverUserList = <UserModel>[].obs;
  Rx<UserModel> selectDriverUser = UserModel().obs;
  Future<void> getAllDriverList() async {
    await FireStoreUtils.getAvalibleDrivers().then(
      (value) {
        if (value.isNotEmpty == true) {
          driverUserList.value = value;
        }
      },
    );
    isLoading.value = false;
  }

  Future<void> getOrder() async {
    FireStoreUtils.fireStore.collection(CollectionName.restaurantOrders).where('vendorID', isEqualTo: Constant.userModel!.vendorID).orderBy('createdAt', descending: true).snapshots().listen(
      (event) async {
        allOrderList.clear();
        for (var element in event.docs) {
          OrderModel orderModel = OrderModel.fromJson(element.data());
          allOrderList.add(orderModel);
          newOrderList.value = allOrderList.where((p0) => p0.status == Constant.orderPlaced).toList();
          acceptedOrderList.value = allOrderList
              .where((p0) =>
                  p0.status == Constant.orderAccepted ||
                  p0.status == Constant.driverAccepted ||
                  p0.status == Constant.driverPending ||
                  p0.status == Constant.driverRejected ||
                  p0.status == Constant.orderShipped ||
                  p0.status == Constant.orderInTransit)
              .toList();
          completedOrderList.value = allOrderList.where((p0) => p0.status == Constant.orderCompleted).toList();
          rejectedOrderList.value = allOrderList.where((p0) => p0.status == Constant.orderRejected).toList();
          cancelledOrderList.value = allOrderList.where((p0) => p0.status == Constant.orderCancelled).toList();
          update();
        }

        if (newOrderList.isNotEmpty == true) {
          if (newOrderList.every((element) => element.scheduleTime == null)) {
            await AudioPlayerService.playSound(true);
          } else {
            await AudioPlayerService.playSound(false);
          }
        } else {
          log("PlaySound :::::: 22");
          await AudioPlayerService.playSound(false);
        }
      },
    );
  }
}
