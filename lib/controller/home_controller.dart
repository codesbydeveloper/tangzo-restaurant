import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;
  Set<String> _knownNewOrderIds = <String>{};
  bool _applyingOrders = false;

  @override
  void onInit() {
    getUserProfile();
    super.onInit();
  }

  @override
  void onClose() {
    _ordersSub?.cancel();
    _ordersSub = null;
    super.onClose();
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

  /// Bound live board so historical orders are not streamed forever.
  /// Uses existing vendorID+createdAt index (no new composite required).
  static const int _liveOrderLimit = 100;

  Future<void> getOrder() async {
    await _ordersSub?.cancel();
    _ordersSub = null;

    final vendorId = Constant.userModel?.vendorID ?? userModel.value.vendorID;
    if (vendorId == null || vendorId.isEmpty) {
      return;
    }

    _ordersSub = FireStoreUtils.fireStore
        .collection(CollectionName.restaurantOrders)
        .where('vendorID', isEqualTo: vendorId)
        .orderBy('createdAt', descending: true)
        .limit(_liveOrderLimit)
        .snapshots()
        .listen(
      (event) async {
        await _applyOrderDocs(event.docs, playSoundIfNew: true);
      },
      onError: (Object e, StackTrace st) {
        log('HomeController orders stream error: $e\n$st');
      },
    );
  }

  /// One-shot refresh used after reject/FCM so UI paints even if TabBarView was stale.
  Future<void> refreshOrdersNow({bool playSoundIfNew = false}) async {
    final vendorId = Constant.userModel?.vendorID ?? userModel.value.vendorID;
    if (vendorId == null || vendorId.isEmpty) return;
    try {
      final snap = await FireStoreUtils.fireStore
          .collection(CollectionName.restaurantOrders)
          .where('vendorID', isEqualTo: vendorId)
          .orderBy('createdAt', descending: true)
          .limit(_liveOrderLimit)
          .get();
      await _applyOrderDocs(snap.docs, playSoundIfNew: playSoundIfNew);
    } catch (e, st) {
      log('HomeController.refreshOrdersNow: $e\n$st');
    }
  }

  Future<void> _applyOrderDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, {
    required bool playSoundIfNew,
  }) async {
    if (_applyingOrders) return;
    _applyingOrders = true;
    try {
      final List<OrderModel> nextAll = [];
      for (final element in docs) {
        try {
          nextAll.add(OrderModel.fromJson(element.data()));
        } catch (e, st) {
          log('HomeController skip bad order ${element.id}: $e\n$st');
        }
      }

      final nextNew =
          nextAll.where((p0) => p0.status == Constant.orderPlaced).toList();
      final nextAccepted = nextAll
          .where((p0) =>
              p0.status == Constant.orderAccepted ||
              p0.status == Constant.driverAccepted ||
              p0.status == Constant.driverPending ||
              p0.status == Constant.driverRejected ||
              p0.status == Constant.orderShipped ||
              p0.status == Constant.orderInTransit ||
              p0.status == Constant.noRiderAvailable)
          .toList();
      final nextCompleted =
          nextAll.where((p0) => p0.status == Constant.orderCompleted).toList();
      final nextRejected =
          nextAll.where((p0) => p0.status == Constant.orderRejected).toList();
      final nextCancelled =
          nextAll.where((p0) => p0.status == Constant.orderCancelled).toList();

      // Fresh list refs so GetX always notifies (assignAll alone can miss TabBarView).
      allOrderList.value = List<OrderModel>.from(nextAll);
      newOrderList.value = List<OrderModel>.from(nextNew);
      acceptedOrderList.value = List<OrderModel>.from(nextAccepted);
      completedOrderList.value = List<OrderModel>.from(nextCompleted);
      rejectedOrderList.value = List<OrderModel>.from(nextRejected);
      cancelledOrderList.value = List<OrderModel>.from(nextCancelled);
      newOrderList.refresh();
      acceptedOrderList.refresh();
      update();

      final currentNewIds = nextNew
          .map((e) => e.id?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
      final hasBrandNew =
          currentNewIds.any((id) => !_knownNewOrderIds.contains(id));
      _knownNewOrderIds = currentNewIds;

      if (playSoundIfNew) {
        SchedulerBinding.instance.addPostFrameCallback((_) async {
          if (nextNew.isNotEmpty) {
            if (hasBrandNew && nextNew.every((element) => element.scheduleTime == null)) {
              await AudioPlayerService.playSound(true);
            }
          } else {
            await AudioPlayerService.playSound(false);
          }
        });
      }
    } finally {
      _applyingOrders = false;
    }
  }
}
