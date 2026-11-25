import 'package:bottom_picker/resources/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/app/Home_screen/order_details_screen.dart';
import 'package:restaurant/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:restaurant/app/driver_screens/add_driver_screen.dart';
import 'package:restaurant/app/product_rating_view_screen/product_rating_view_screen.dart';
import 'package:restaurant/app/verification_screen/verification_screen.dart';
import 'package:restaurant/constant/collection_name.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/send_notification.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/dash_board_controller.dart';
import 'package:restaurant/controller/home_controller.dart';
import 'package:restaurant/models/cart_product_model.dart';
import 'package:restaurant/models/order_model.dart';
import 'package:restaurant/models/user_model.dart';
import 'package:restaurant/models/wallet_transaction_model.dart';
import 'package:restaurant/service/audio_player_service.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/text_field_widget.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/dynamic_traslator.dart';

import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/network_image_widget.dart';
import 'package:restaurant/utils/translation_notifier.dart';
import 'package:restaurant/widget/my_separator.dart';
import 'package:restaurant/widget/translated_text.dart';
import 'package:uuid/uuid.dart';

import '../../themes/round_button_fill.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return ValueListenableBuilder(
        valueListenable: TranslationNotifier.refresh,
        builder: (_, __, ___) {
          return GetX(
              init: Get.put(HomeController(), permanent: true),
              builder: (controller) {
                return controller.isLoading.value
                    ? Constant.loader()
                    : DefaultTabController(
                        length: 5,
                        initialIndex: controller.selectedTabIndex.value.clamp(0, 4),
                        child: Scaffold(
                          appBar: AppBar(
                            backgroundColor: AppThemeData.secondary300,
                            centerTitle: false,
                            title: Row(
                              children: [
                                InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    DashBoardController dashBoardController = Get.find<DashBoardController>();
                                    if (Constant.isDineInEnable && controller.vendermodel.value.subscriptionPlan?.features?.dineIn != false) {
                                      dashBoardController.selectedIndex.value = 4;
                                    } else {
                                      dashBoardController.selectedIndex.value = 3;
                                    }
                                  },
                                  child: ClipOval(
                                    child: NetworkImageWidget(
                                      imageUrl: controller.userModel.value.profilePictureURL.toString(),
                                      height: 42,
                                      width: 42,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText(
                                      "Welcome to Tangzo Restaurant",
                                      style: TextStyle(color: AppThemeData.grey50, fontSize: 12, fontFamily: AppThemeData.regular),
                                    ),
                                    TranslatedText(
                                      controller.userModel.value.fullName(),
                                      style: TextStyle(color: AppThemeData.grey50, fontSize: 16, fontFamily: AppThemeData.semiBold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            bottom: Constant.getEmployeeRolePermission(module: "Manage Order") == true
                                ? TabBar(
                                    onTap: (value) {
                                      controller.selectedTabIndex.value = value;
                                    },
                                    tabAlignment: TabAlignment.start,
                                    labelStyle: const TextStyle(fontFamily: AppThemeData.semiBold),
                                    labelColor: AppThemeData.grey50,
                                    unselectedLabelStyle: const TextStyle(fontFamily: AppThemeData.medium),
                                    unselectedLabelColor: AppThemeData.secondary100,
                                    indicatorColor: AppThemeData.grey50,
                                    isScrollable: true,
                                    padding: const EdgeInsets.symmetric(horizontal: 18),
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 20),
                                    dividerColor: Colors.transparent,
                                    tabs: [
                                      Tab(text: "New".tr),
                                      Tab(text: "Accepted".tr),
                                      Tab(text: "Completed".tr),
                                      Tab(text: "Rejected".tr),
                                      Tab(text: "Cancelled".tr),
                                    ],
                                  )
                                : null,
                            actions: const [],
                          ),
                          body: controller.userModel.value.isAutoVerify == false && controller.userModel.value.isDocumentVerify == false
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: ShapeDecoration(
                                            color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(120),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: SvgPicture.asset("assets/icons/ic_document.svg"),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 12,
                                        ),
                                        TranslatedText(
                                          "Document Verification in Pending",
                                          style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 22, fontFamily: AppThemeData.semiBold),
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        TranslatedText(
                                          "Your documents are being reviewed. We will notify you once the verification is complete.",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.bold),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        RoundedButtonFill(
                                          title: "View Status",
                                          width: 55,
                                          height: 5.5,
                                          color: AppThemeData.secondary300,
                                          textColor: AppThemeData.grey50,
                                          onPress: () async {
                                            Get.to(const VerificationScreen());
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : controller.userModel.value.vendorID == null || controller.userModel.value.vendorID?.isEmpty == true
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(120),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: SvgPicture.asset("assets/icons/ic_building_two.svg"),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 12,
                                          ),
                                          TranslatedText(
                                            "Add Your First Restaurant",
                                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 22, fontFamily: AppThemeData.semiBold),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          TranslatedText(
                                            "Get started by adding your restaurant details to manage your menu, orders, and reservations.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.bold),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          RoundedButtonFill(
                                            title: "Add Restaurant",
                                            width: 55,
                                            height: 5.5,
                                            color: AppThemeData.secondary300,
                                            textColor: AppThemeData.grey50,
                                            onPress: () async {
                                              Get.to(const AddRestaurantScreen())?.then((v) {
                                                controller.getUserProfile(location: v);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      child: Constant.getEmployeeRolePermission(module: "Manage Order") == true
                                          ? Obx(() {
                                              // IndexedStack: TabBarView was caching children so after
                                              // reject the next order rang but did not paint until restart.
                                              final tab = controller.selectedTabIndex.value;
                                              final pages = <Widget>[
                                                _ordersListOrEmpty(
                                                  list: controller.newOrderList,
                                                  emptyMessage: "New Orders Not found",
                                                  listKey: 'new',
                                                  itemBuilder: (ctx, order) =>
                                                      newOrderWidget(themeChange, ctx, order, controller),
                                                ),
                                                _ordersListOrEmpty(
                                                  list: controller.acceptedOrderList,
                                                  emptyMessage: "Accepted Orders Not found",
                                                  listKey: 'accepted',
                                                  itemBuilder: (ctx, order) =>
                                                      acceptedWidget(themeChange, ctx, order, controller),
                                                ),
                                                _ordersListOrEmpty(
                                                  list: controller.completedOrderList,
                                                  emptyMessage: "Completed Orders Not found",
                                                  listKey: 'completed',
                                                  itemBuilder: (ctx, order) =>
                                                      completedAndRejectedWidget(themeChange, ctx, order, controller),
                                                ),
                                                _ordersListOrEmpty(
                                                  list: controller.rejectedOrderList,
                                                  emptyMessage: "Rejected Orders Not found",
                                                  listKey: 'rejected',
                                                  itemBuilder: (ctx, order) =>
                                                      completedAndRejectedWidget(themeChange, ctx, order, controller),
                                                ),
                                                _ordersListOrEmpty(
                                                  list: controller.cancelledOrderList,
                                                  emptyMessage: "Cancelled Orders Not found",
                                                  listKey: 'cancelled',
                                                  itemBuilder: (ctx, order) =>
                                                      completedAndRejectedWidget(themeChange, ctx, order, controller),
                                                ),
                                              ];
                                              return IndexedStack(
                                                index: tab.clamp(0, pages.length - 1),
                                                children: pages,
                                              );
                                            })
                                          : Constant.showEmptyView(message: "You don’t have permission to view orders."),
                                    ),
                        ),
                      );
              });
        });
  }

  Widget _ordersListOrEmpty({
    required List<OrderModel> list,
    required String emptyMessage,
    required String listKey,
    required Widget Function(BuildContext context, OrderModel order) itemBuilder,
  }) {
    if (list.isEmpty) {
      return Constant.showEmptyView(message: emptyMessage);
    }
    final ids = list.map((e) => e.id ?? '').join('_');
    return ListView.builder(
      key: ValueKey('${listKey}_${list.length}_$ids'),
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) => itemBuilder(context, list[index]),
    );
  }

  InkWell newOrderWidget(themeChange, BuildContext context, OrderModel orderModel, HomeController controller) {
    double totalAmount = 0.0;
    double subTotal = 0.0;
    double adminCommission = 0.0;
    double totalTaxAmount = 0.0;
    double orderTaxAmount = 0.0;
    double driverDeliveryTaxAmount = 0.0;
    double packagingTaxAmount = 0.0;
    double platformTaxAmount = 0.0;
    double productTaxAmount = 0.0;
    double specialDiscountAmount = 0.0;
    double couponAmount = 0.0;
    double deliveryCharges = 0.0;
    double platformFee = 0.0;
    double deliveryTips = 0.0;
    double packagingCharge = 0.0;
    double totalRejectAmount = 0.0;

    // Reset
    subTotal = 0.0;
    specialDiscountAmount = 0.0;
    couponAmount = 0.0;

    productTaxAmount = 0.0;
    orderTaxAmount = 0.0;
    driverDeliveryTaxAmount = 0.0;
    packagingTaxAmount = 0.0;
    platformTaxAmount = 0.0;
    totalTaxAmount = 0.0;

    /// ---------------- SUBTOTAL ----------------
    for (var element in orderModel.products!) {
      if (double.parse(element.discountPrice.toString()) <= 0) {
        subTotal =
            subTotal + double.parse(element.price.toString()) * double.parse(element.quantity.toString()) + (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
      } else {
        subTotal = subTotal +
            double.parse(element.discountPrice.toString()) * double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
      }
    }

    /// ---------------- DISCOUNTS ----------------
    couponAmount = double.parse(orderModel.discount.toString());

    if (orderModel.specialDiscount != null && orderModel.specialDiscount!['special_discount'] != null) {
      specialDiscountAmount = double.parse(orderModel.specialDiscount!['special_discount'].toString());
    }

    final double totalDiscount = couponAmount + specialDiscountAmount;

    /// ---------------- DISCOUNT RATIO ----------------
    double discountRatio = 0.0;
    if (subTotal > 0 && totalDiscount > 0) {
      discountRatio = totalDiscount / subTotal;
    }

    /// ---------------- PRODUCT TAX (AFTER DISCOUNT) ----------------
    if (orderModel.taxScope == "product") {
      for (var element in orderModel.products!) {
        final double price = (double.parse(element.discountPrice.toString()) > 0) ? double.parse(element.discountPrice.toString()) : double.parse(element.price.toString());

        final double qty = double.parse(element.quantity.toString());
        final double extras = double.parse(element.extrasPrice.toString());

        final double itemAmount = (price * qty) + (extras * qty);

        final double discountedItemAmount = itemAmount - (itemAmount * discountRatio);

        for (var taxElement in element.taxSetting!) {
          if (taxElement.type == "fix") {
            productTaxAmount += Constant.calculateTax(
                  amount: discountedItemAmount.toString(),
                  taxModel: taxElement,
                ) *
                qty;
          } else {
            productTaxAmount += Constant.calculateTax(
              amount: discountedItemAmount.toString(),
              taxModel: taxElement,
            );
          }
        }
      }
    }

    /// ---------------- ORDER LEVEL TAX ----------------
    if (orderModel.taxScope == "order") {
      for (var taxElement in orderModel.taxSetting ?? []) {
        orderTaxAmount += Constant.calculateTax(
          amount: (subTotal - totalDiscount).toString(),
          taxModel: taxElement,
        );
      }
    }

    /// ---------------- OTHER CHARGES ----------------
    deliveryCharges = double.parse(orderModel.deliveryCharge.toString());

    deliveryTips = double.parse(orderModel.tipAmount.toString());

    packagingCharge = double.parse(orderModel.vendor!.packagingCharge.toString());

    platformFee = double.parse(orderModel.platformFee ?? '0.0');

    /// ---------------- DELIVERY TAX ----------------
    if (orderModel.takeAway != true && orderModel.vendor?.isSelfDelivery != true) {
      for (var taxElement in orderModel.driverDeliveryTax ?? []) {
        driverDeliveryTaxAmount += Constant.calculateTax(
          amount: deliveryCharges.toString(),
          taxModel: taxElement,
        );
      }
    }

    /// ---------------- PACKAGING TAX ----------------
    if (packagingCharge > 0) {
      for (var taxElement in orderModel.packagingTax ?? []) {
        packagingTaxAmount += Constant.calculateTax(
          amount: packagingCharge.toString(),
          taxModel: taxElement,
        );
      }
    }

    /// ---------------- PLATFORM TAX ----------------
    if (platformFee > 0) {
      for (var taxElement in orderModel.platformTax ?? []) {
        platformTaxAmount += Constant.calculateTax(
          amount: platformFee.toString(),
          taxModel: taxElement,
        );
      }
    }

    /// ---------------- TOTAL TAX ----------------
    totalTaxAmount = productTaxAmount + orderTaxAmount + packagingTaxAmount;

    /// ---------------- FINAL TOTAL ----------------
    totalAmount = (subTotal - totalDiscount) + packagingCharge;

    // Customer refund must match full amount customer paid (all taxes + fees + delivery).
    if (orderModel.paymentMethod!.toLowerCase() != 'cod') {
      totalRejectAmount = totalAmount +
          productTaxAmount +
          orderTaxAmount +
          packagingTaxAmount +
          platformFee +
          platformTaxAmount +
          driverDeliveryTaxAmount +
          (orderModel.isFreeDelivery == true ? 0 : (deliveryCharges + deliveryTips));
    }

    if (orderModel.adminCommissionType == 'Percent') {
      double basePrice = subTotal / (1 + (double.parse(orderModel.adminCommission!) / 100));
      adminCommission = subTotal - basePrice;
    } else {
      adminCommission = double.parse(orderModel.adminCommission!);
    }

    return InkWell(
      splashColor: Colors.transparent,
      onTap: () async {
        Get.to(const OrderDetailsScreen(), arguments: {"orderModel": orderModel});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          decoration: ShapeDecoration(
            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: NetworkImageWidget(
                        imageUrl: orderModel.author!.profilePictureURL.toString(),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                            orderModel.author!.fullName().toString(),
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontSize: 14,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                          orderModel.takeAway == true
                              ? TranslatedText(
                                  "Take Away",
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                )
                              : TranslatedText(
                                  orderModel.address?.getFullAddress() ?? '',
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  itemCount: orderModel.products!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    CartProductModel product = orderModel.products![index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TranslatedText(
                                "${product.quantity}x ${product.name}",
                                style: TextStyle(
                                  color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppThemeData.semiBold,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  double.parse(product.discountPrice ?? "0.0") <= 0
                                      ? Constant.amountShow(amount: (double.parse(product.price.toString()) * double.parse(product.quantity.toString())).toString())
                                      : Constant.amountShow(amount: (double.parse(product.discountPrice.toString()) * double.parse(product.quantity.toString())).toString()),
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppThemeData.semiBold,
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    Get.to(const ProductRatingViewScreen(), arguments: {"orderModel": orderModel, "productId": product.id});
                                  },
                                  child: TranslatedText(
                                    "View Ratings",
                                    style: TextStyle(
                                      color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                      fontFamily: AppThemeData.semiBold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        product.variantInfo == null || product.variantInfo!.variantOptions!.isEmpty
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText(
                                      "Variants",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Wrap(
                                      spacing: 6.0,
                                      runSpacing: 6.0,
                                      children: List.generate(
                                        product.variantInfo!.variantOptions!.length,
                                        (i) {
                                          return Container(
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                              child: TranslatedText(
                                                "${product.variantInfo!.variantOptions!.keys.elementAt(i)} : ${product.variantInfo!.variantOptions![product.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.medium,
                                                  color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ],
                                ),
                              ),
                        product.extras == null || product.extras!.isEmpty
                            ? const SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TranslatedText(
                                          "Addons",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.semiBold,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(amount: (double.parse(product.extrasPrice.toString()) * double.parse(product.quantity.toString())).toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.semiBold,
                                          color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: List.generate(
                                      product.extras!.length,
                                      (i) {
                                        return Container(
                                          decoration: ShapeDecoration(
                                            color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                            child: TranslatedText(
                                              product.extras![i].toString(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.medium,
                                                color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                      ],
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20, bottom: 10),
                      child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Order Date",
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppThemeData.regular,
                        ),
                      ),
                    ),
                    TranslatedText(
                      Constant.timestampToDateTime(orderModel.createdAt!),
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Total Amount",
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppThemeData.regular,
                        ),
                      ),
                    ),
                    Text(
                      Constant.amountShow(amount: totalAmount.toString(), decimalDigits: 3),
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: Constant.adminCommission?.isEnabled == true,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              "Admin Commissions",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: adminCommission.toString(), decimalDigits: 3)}",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              "Admin Commission Tax",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: Constant.calculateAdminCommissionTax(adminCommission).toString(), decimalDigits: 3)}",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              (Constant.userModel?.userBankDetails?.gstNumber ?? '').trim().isNotEmpty ? "TCS" : "TDS",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: Constant.calculateTdsOrTcs(totalAmount, hasGst: (Constant.userModel?.userBankDetails?.gstNumber ?? '').trim().isNotEmpty).toString(), decimalDigits: 3)}",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                orderModel.scheduleTime == null
                    ? const SizedBox()
                    : Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              "Schedule Time",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          TranslatedText(
                            Constant.timestampToDateTime(orderModel.scheduleTime!),
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(
                  height: 5,
                ),
                orderModel.notes == null || orderModel.notes!.isEmpty
                    ? const SizedBox()
                    : InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return viewRemarkDialog(controller, themeChange, orderModel);
                            },
                          );
                        },
                        child: TranslatedText(
                          "View Remarks",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppThemeData.regular,
                            decoration: TextDecoration.underline,
                            color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                            fontSize: 16,
                          ),
                        ),
                      ),
                if (Constant.getEmployeeRolePermission(module: "Manage Order") == true)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: RoundedButtonFill(
                            title: "Reject",
                            color: AppThemeData.danger300,
                            textColor: AppThemeData.grey50,
                            height: 5,
                            onPress: () async {
                              ShowToastDialog.showLoader('Please wait...');
                              orderModel.status = Constant.orderRejected;
                              if (orderModel.cashback?.id != null && orderModel.cashback?.cashbackValue != null) {
                                await FireStoreUtils.deleteCashbackRedeem(orderModel);
                              }
                              await FireStoreUtils.deleteDriverCashbackRedeem(orderModel);
                              await FireStoreUtils.updateOrder(orderModel);
                              SendNotification.sendFcmMessage(Constant.restaurantRejected, orderModel.author!.fcmToken.toString(), {});
                              if (orderModel.paymentMethod!.toLowerCase() != 'cod') {
                                final refundAmount = await FireStoreUtils.getCustomerDebitedAmountForOrder(
                                  orderModel: orderModel,
                                  fallbackAmount: totalRejectAmount,
                                );
                                if (refundAmount > 0) {
                                  WalletTransactionModel historyDataModel = WalletTransactionModel(
                                      amount: refundAmount,
                                      id: const Uuid().v4(),
                                      orderId: orderModel.id,
                                      userId: orderModel.author!.id,
                                      date: Timestamp.now(),
                                      isTopup: true,
                                      paymentMethod: "Wallet",
                                      paymentStatus: "success",
                                      note: "Order Refund success",
                                      transactionUser: "user");
                                  await FireStoreUtils.fireStore.collection(CollectionName.wallet).doc(historyDataModel.id).set(historyDataModel.toJson());
                                  await FireStoreUtils.updateUserWallet(amount: refundAmount.toString(), userId: orderModel.author!.id.toString());
                                }
                              }
                              ShowToastDialog.closeLoader();
                              // Do not Get.back() / getOrder() here — stream is live;
                              // cancel+resubscribe + extra pop broke next-order UI.
                              await controller.refreshOrdersNow(playSoundIfNew: false);
                              await AudioPlayerService.playSound(false);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Constant.isSelfDeliveryFeature == true && controller.vendermodel.value.isSelfDelivery == true && orderModel.takeAway == false
                                ? RoundedButtonFill(
                                    title: "Self Delivery",
                                    height: 5,
                                    color: AppThemeData.success400,
                                    textColor: AppThemeData.grey50,
                                    onPress: () async {
                                      if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) && controller.vendermodel.value.subscriptionPlan != null) {
                                        if (controller.vendermodel.value.subscriptionTotalOrders == '0' || controller.vendermodel.value.subscriptionTotalOrders == null) {
                                          ShowToastDialog.closeLoader();
                                          ShowToastDialog.showToast(
                                              "You have reached the maximum order capacity for your current plan. Upgrade your subscription to continue accepting orders seamlessly!.");
                                          return;
                                        }
                                      }

                                      if (orderModel.scheduleTime != null) {
                                        if (DateTime.now().isAtSameMomentOrAfter(Constant.checkScheduleTime(scheduleDate: orderModel.scheduleTime!.toDate()))) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return estimatedTimeDialog(controller, themeChange, orderModel, context);
                                            },
                                          );
                                        } else {
                                          await AudioPlayerService.playSound(false);
                                          ShowToastDialog.showToast(
                                              "${"You can accept order on".tr} ${Constant.timestampToDateTime(Timestamp.fromDate(Constant.checkScheduleTime(scheduleDate: orderModel.scheduleTime!.toDate())))}.");
                                        }
                                      } else {
                                        controller.driverUserList.clear();
                                        controller.selectDriverUser.value = UserModel();

                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return estimatedTimeDialog(controller, themeChange, orderModel, context);
                                          },
                                        );
                                      }
                                    },
                                  )
                                : RoundedButtonFill(
                                    title: "Accept",
                                    height: 5,
                                    color: AppThemeData.success400,
                                    textColor: AppThemeData.grey50,
                                    onPress: () async {
                                      // if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) &&
                                      //     Constant.userModel?.subscriptionPlan?.type != 'free' &&
                                      //     Constant.userModel?.subscriptionPlan?.orderLimit != '-1' &&
                                      //     int.parse(Constant.userModel?.subscriptionPlan?.orderLimit ?? '0') <= controller.totalOrderList.length) {
                                      //   ShowToastDialog.showToast("Your current subscription plan has reached its maximum order limit. Upgrade now to accept more order.");
                                      //   return;
                                      // }

                                      if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) && controller.vendermodel.value.subscriptionPlan != null) {
                                        if (controller.vendermodel.value.subscriptionTotalOrders == '0' || controller.vendermodel.value.subscriptionTotalOrders == null) {
                                          ShowToastDialog.closeLoader();
                                          ShowToastDialog.showToast(
                                              "You have reached the maximum order capacity for your current plan. Upgrade your subscription to continue accepting orders seamlessly!.");
                                          return;
                                        }
                                      }
                                      if (orderModel.scheduleTime != null) {
                                        if (DateTime.now().isAtSameMomentOrAfter(Constant.checkScheduleTime(scheduleDate: orderModel.scheduleTime!.toDate()))) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return estimatedTimeDialog(controller, themeChange, orderModel, context);
                                            },
                                          );
                                        } else {
                                          await AudioPlayerService.playSound(false);
                                          ShowToastDialog.showToast(
                                              "${"You can accept order on".tr} ${Constant.timestampToDateTime(Timestamp.fromDate(Constant.checkScheduleTime(scheduleDate: orderModel.scheduleTime!.toDate())))}.");
                                        }
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return estimatedTimeDialog(controller, themeChange, orderModel, context);
                                          },
                                        );
                                      }
                                    },
                                  ))
                      ],
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InkWell acceptedWidget(themeChange, BuildContext context, OrderModel orderModel, HomeController controller) {
    double totalAmount = 0.0;
    double subTotal = 0.0;
    double adminCommission = 0.0;
    double totalTaxAmount = 0.0;
    double orderTaxAmount = 0.0;
    double driverDeliveryTaxAmount = 0.0;
    double packagingTaxAmount = 0.0;
    double platformTaxAmount = 0.0;
    double productTaxAmount = 0.0;
    double specialDiscountAmount = 0.0;
    double couponAmount = 0.0;
    double deliveryCharges = 0.0;
    double platformFee = 0.0;
    double deliveryTips = 0.0;
    double packagingCharge = 0.0;
    double totalRejectAmount = 0.0;

    // Reset
    subTotal = 0.0;
    specialDiscountAmount = 0.0;
    couponAmount = 0.0;

    productTaxAmount = 0.0;
    orderTaxAmount = 0.0;
    driverDeliveryTaxAmount = 0.0;
    packagingTaxAmount = 0.0;
    platformTaxAmount = 0.0;
    totalTaxAmount = 0.0;

    /// ---------------- SUBTOTAL ----------------
    for (var element in orderModel.products!) {
      if (double.parse(element.discountPrice.toString()) <= 0) {
        subTotal =
            subTotal + double.parse(element.price.toString()) * double.parse(element.quantity.toString()) + (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
      } else {
        subTotal = subTotal +
            double.parse(element.discountPrice.toString()) * double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
      }
    }

    /// ---------------- DISCOUNTS ----------------
    couponAmount = double.parse(orderModel.discount.toString());

    if (orderModel.specialDiscount != null && orderModel.specialDiscount!['special_discount'] != null) {
      specialDiscountAmount = double.parse(orderModel.specialDiscount!['special_discount'].toString());
    }

    final double totalDiscount = couponAmount + specialDiscountAmount;

    /// ---------------- DISCOUNT RATIO ----------------
    double discountRatio = 0.0;
    if (subTotal > 0 && totalDiscount > 0) {
      discountRatio = totalDiscount / subTotal;
    }

    /// ---------------- PRODUCT TAX (AFTER DISCOUNT) ----------------
    if (orderModel.taxScope == "product") {
      for (var element in orderModel.products!) {
        final double price = (double.parse(element.discountPrice.toString()) > 0) ? double.parse(element.discountPrice.toString()) : double.parse(element.price.toString());

        final double qty = double.parse(element.quantity.toString());
        final double extras = double.parse(element.extrasPrice.toString());

        final double itemAmount = (price * qty) + (extras * qty);

        final double discountedItemAmount = itemAmount - (itemAmount * discountRatio);

        for (var taxElement in element.taxSetting!) {
          if (taxElement.type == "fix") {
            productTaxAmount += Constant.calculateTax(
                  amount: discountedItemAmount.toString(),
                  taxModel: taxElement,
                ) *
                qty;
          } else {
            productTaxAmount += Constant.calculateTax(
              amount: discountedItemAmount.toString(),
              taxModel: taxElement,
            );
          }
        }
      }
    }

    /// ---------------- ORDER LEVEL TAX ----------------
    if (orderModel.taxScope == "order") {
      for (var taxElement in orderModel.taxSetting ?? []) {
        orderTaxAmount += Constant.calculateTax(
          amount: (subTotal - totalDiscount).toString(),
          taxModel: taxElement,
        );
      }
    }

    /// ---------------- OTHER CHARGES ----------------
    deliveryCharges = double.parse(orderModel.deliveryCharge.toString());

    deliveryTips = double.parse(orderModel.tipAmount.toString());

    packagingCharge = double.parse(orderModel.vendor!.packagingCharge.toString());

    platformFee = double.parse(orderModel.platformFee ?? '0.0');

    /// ---------------- DELIVERY TAX ----------------
    if (orderModel.takeAway != true && orderModel.vendor?.isSelfDelivery != true) {
      for (var taxElement in orderModel.driverDeliveryTax ?? []) {
        driverDeliveryTaxAmount += Constant.calculateTax(
          amount: deliveryCharges.toString(),
          taxModel: taxElement,
        );
      }
    }

    /// ---------------- PACKAGING TAX ----------------
    if (packagingCharge > 0) {
      for (var taxElement in orderModel.packagingTax ?? []) {
        packagingTaxAmount += Constant.calculateTax(
          amount: packagingCharge.toString(),
          taxModel: taxElement,
        );
      }
    }

    /// ---------------- PLATFORM TAX ----------------
    if (platformFee > 0) {
      for (var taxElement in orderModel.platformTax ?? []) {
        platformTaxAmount += Constant.calculateTax(
          amount: platformFee.toString(),
          taxModel: taxElement,
        );
      }
    }

    /// ---------------- TOTAL TAX ----------------
    totalTaxAmount = productTaxAmount + orderTaxAmount + packagingTaxAmount;

    /// ---------------- FINAL TOTAL ----------------
    totalAmount = (subTotal - totalDiscount) + packagingCharge;

    // Customer refund must match full amount customer paid (all taxes + fees + delivery).
    if (orderModel.paymentMethod!.toLowerCase() != 'cod') {
      totalRejectAmount = totalAmount +
          productTaxAmount +
          orderTaxAmount +
          packagingTaxAmount +
          platformFee +
          platformTaxAmount +
          driverDeliveryTaxAmount +
          (orderModel.isFreeDelivery == true ? 0 : (deliveryCharges + deliveryTips));
    }

    if (orderModel.adminCommissionType == 'Percent') {
      double basePrice = subTotal / (1 + (double.parse(orderModel.adminCommission!) / 100));
      adminCommission = subTotal - basePrice;
    } else {
      adminCommission = double.parse(orderModel.adminCommission!);
    }

    return InkWell(
      splashColor: Colors.transparent,
      onTap: () async {
        Get.to(const OrderDetailsScreen(), arguments: {"orderModel": orderModel});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          decoration: ShapeDecoration(
            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: NetworkImageWidget(
                        imageUrl: orderModel.author!.profilePictureURL.toString(),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                            orderModel.author!.fullName().toString(),
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontSize: 14,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                          orderModel.takeAway == true
                              ? TranslatedText(
                                  "Take Away",
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                )
                              : TranslatedText(
                                  orderModel.address?.getFullAddress() ?? '',
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right)
                  ],
                ),
                if (orderModel.shiprocketPickupOtp != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: themeChange.getThem()
                          ? AppThemeData.warning500.withOpacity(0.35)
                          : AppThemeData.warning50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppThemeData.warning300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline, size: 20, color: AppThemeData.warning400),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatedText(
                                "Pickup OTP",
                                style: TextStyle(
                                  color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
                                  fontSize: 12,
                                  fontFamily: AppThemeData.medium,
                                ),
                              ),
                              Text(
                                orderModel.shiprocketPickupOtp!,
                                style: TextStyle(
                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                  fontSize: 22,
                                  fontFamily: AppThemeData.semiBold,
                                  letterSpacing: 4,
                                ),
                              ),
                              TranslatedText(
                                "Share this OTP with the Shiprocket rider at pickup",
                                style: TextStyle(
                                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                  fontSize: 11,
                                  fontFamily: AppThemeData.regular,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderModel.products!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    CartProductModel product = orderModel.products![index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TranslatedText(
                                "${product.quantity}x ${product.name}",
                                style: TextStyle(
                                  color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppThemeData.semiBold,
                                ),
                              ),
                            ),
                            Text(
                              double.parse(product.discountPrice ?? "0.0") <= 0
                                  ? Constant.amountShow(amount: (double.parse(product.price.toString()) * double.parse(product.quantity.toString())).toString())
                                  : Constant.amountShow(amount: (double.parse(product.discountPrice.toString()) * double.parse(product.quantity.toString())).toString()),
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppThemeData.semiBold,
                              ),
                            ),
                          ],
                        ),
                        product.variantInfo == null || product.variantInfo!.variantOptions!.isEmpty
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText(
                                      "Variants",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Wrap(
                                      spacing: 6.0,
                                      runSpacing: 6.0,
                                      children: List.generate(
                                        product.variantInfo!.variantOptions!.length,
                                        (i) {
                                          return Container(
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                              child: TranslatedText(
                                                "${product.variantInfo!.variantOptions!.keys.elementAt(i)} : ${product.variantInfo!.variantOptions![product.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.medium,
                                                  color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ],
                                ),
                              ),
                        product.extras == null || product.extras!.isEmpty
                            ? const SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TranslatedText(
                                          "Addons",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.semiBold,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(amount: (double.parse(product.extrasPrice.toString()) * double.parse(product.quantity.toString())).toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.semiBold,
                                          color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: List.generate(
                                      product.extras!.length,
                                      (i) {
                                        return Container(
                                          decoration: ShapeDecoration(
                                            color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                            child: TranslatedText(
                                              product.extras![i].toString(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.medium,
                                                color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Order Date",
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppThemeData.regular,
                        ),
                      ),
                    ),
                    TranslatedText(
                      Constant.timestampToDateTime(orderModel.createdAt!),
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Total Amount",
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppThemeData.regular,
                        ),
                      ),
                    ),
                    Text(
                      Constant.amountShow(amount: totalAmount.toString(), decimalDigits: 3),
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: Constant.adminCommission?.isEnabled == true,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              "Admin Commissions",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: adminCommission.toString(), decimalDigits: 3)}",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              "Admin Commission Tax",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: Constant.calculateAdminCommissionTax(adminCommission).toString(), decimalDigits: 3)}",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              (Constant.userModel?.userBankDetails?.gstNumber ?? '').trim().isNotEmpty ? "TCS" : "TDS",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: Constant.calculateTdsOrTcs(totalAmount, hasGst: (Constant.userModel?.userBankDetails?.gstNumber ?? '').trim().isNotEmpty).toString(), decimalDigits: 3)}",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                orderModel.scheduleTime == null
                    ? const SizedBox()
                    : Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              "Schedule Time",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          TranslatedText(
                            Constant.timestampToDateTime(orderModel.scheduleTime!),
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(
                  height: 5,
                ),
                orderModel.notes == null || orderModel.notes!.isEmpty
                    ? const SizedBox()
                    : InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return viewRemarkDialog(controller, themeChange, orderModel);
                            },
                          );
                        },
                        child: TranslatedText(
                          "View Remarks",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppThemeData.regular,
                            decoration: TextDecoration.underline,
                            color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                            fontSize: 16,
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Builder(
                    builder: (context) {
                      final bool canCancelOrder = orderModel.status != Constant.orderShipped &&
                          orderModel.status != Constant.orderInTransit;
                      return Row(
                        children: [
                          Expanded(
                            child: RoundedButtonFill(
                              title: "Cancel Order",
                              color: canCancelOrder
                                  ? AppThemeData.danger300
                                  : (themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey300),
                              textColor: canCancelOrder
                                  ? AppThemeData.grey50
                                  : (themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500),
                              height: 5,
                              onPress: () async {
                                if (!canCancelOrder) {
                                  ShowToastDialog.showToast(
                                    "Cancel is not allowed once the order is shipped or in transit.",
                                  );
                                  return;
                                }
                                ShowToastDialog.showLoader('Please wait...');
                                orderModel.status = Constant.orderCancelled;
                                if (orderModel.cashback?.id != null && orderModel.cashback?.cashbackValue != null) {
                                  await FireStoreUtils.deleteCashbackRedeem(orderModel);
                                }
                                await FireStoreUtils.deleteDriverCashbackRedeem(orderModel);
                                if (orderModel.driver?.id != null) {
                                  UserModel? driver = await FireStoreUtils.getUserById(orderModel.driver!.id!);
                                  driver?.inProgressOrderID?.remove(orderModel.id);
                                  await FireStoreUtils.updateDriverUser(driver!);
                                }
                                await FireStoreUtils.updateOrder(orderModel);

                                SendNotification.sendFcmMessage(Constant.restaurantCancelled, orderModel.author!.fcmToken.toString(), {});

                                if (orderModel.paymentMethod!.toLowerCase() != 'cod') {
                                  // Reverse exact restaurant credit (same amount that was credited).
                                  await FireStoreUtils.reverseVendorCreditForOrder(orderModel);

                                  // Refund exact customer debit (same amount that was debited).
                                  final refundAmount = await FireStoreUtils.getCustomerDebitedAmountForOrder(
                                    orderModel: orderModel,
                                    fallbackAmount: totalRejectAmount,
                                  );
                                  if (refundAmount > 0) {
                                    WalletTransactionModel historyDataModel = WalletTransactionModel(
                                        amount: refundAmount,
                                        id: const Uuid().v4(),
                                        orderId: orderModel.id,
                                        userId: orderModel.author!.id,
                                        date: Timestamp.now(),
                                        isTopup: true,
                                        paymentMethod: "Wallet",
                                        paymentStatus: "success",
                                        note: "Order Refund success",
                                        transactionUser: "user");

                                    await FireStoreUtils.fireStore.collection(CollectionName.wallet).doc(historyDataModel.id).set(historyDataModel.toJson());
                                    await FireStoreUtils.updateUserWallet(amount: refundAmount.toString(), userId: orderModel.author!.id.toString());
                                  }
                                }

                                ShowToastDialog.closeLoader();
                                await controller.refreshOrdersNow(playSoundIfNew: false);
                                await AudioPlayerService.playSound(false);
                              },
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: orderModel.takeAway == true
                                ? RoundedButtonFill(
                                    title: "Delivered",
                                    color: AppThemeData.secondary300,
                                    textColor: AppThemeData.grey50,
                                    height: 5,
                                    onPress: () async {
                                      ShowToastDialog.showLoader('Please wait...');
                                      orderModel.status = Constant.orderCompleted;
                                      if (orderModel.cashback?.cashbackValue != null && orderModel.cashback?.id != null) {
                                        WalletTransactionModel transactionModel = WalletTransactionModel(
                                            id: Constant.getUuid(),
                                            amount: double.parse("${orderModel.cashback?.cashbackValue ?? 0.0}"),
                                            date: Timestamp.now(),
                                            paymentMethod: "Cashback Amount",
                                            transactionUser: "user",
                                            userId: orderModel.author?.id,
                                            isTopup: true,
                                            orderId: orderModel.id,
                                            note: "Cashback Amount",
                                            paymentStatus: "success");
                                        await FireStoreUtils.setWalletTransaction(transactionModel).then((value) async {
                                          if (value == true) {
                                            await FireStoreUtils.updateUserWallet(
                                                amount: double.parse("${orderModel.cashback?.cashbackValue ?? 0.0}").toString(), userId: orderModel.author!.id.toString());
                                          }
                                        });
                                      }
                                      await FireStoreUtils.updateOrder(orderModel);
                                      await FireStoreUtils.restaurantVendorWalletSet(orderModel);
                                      SendNotification.sendFcmMessage(Constant.takeawayCompleted, orderModel.author!.fcmToken.toString(), {});

                                      ShowToastDialog.closeLoader();
                                    },
                                  )
                                : RoundedButtonFill(
                                    title: Constant.statusDisplayLabel(
                                      status: orderModel.status.toString(),
                                    ),
                                    color: AppThemeData.secondary300,
                                    textColor: AppThemeData.grey50,
                                    height: 5,
                                    onPress: () async {},
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InkWell completedAndRejectedWidget(themeChange, BuildContext context, OrderModel orderModel, HomeController controller) {
    double totalAmount = 0.0;
    double subTotal = 0.0;
    double taxAmount = 0.0;
    double specialDiscount = 0.0;
    double adminCommission = 0.0;

    for (var element in orderModel.products!) {
      if (double.parse(element.discountPrice.toString()) <= 0) {
        subTotal =
            subTotal + double.parse(element.price.toString()) * double.parse(element.quantity.toString()) + (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
      } else {
        subTotal = subTotal +
            double.parse(element.discountPrice.toString()) * double.parse(element.quantity.toString()) +
            (double.parse(element.extrasPrice.toString()) * double.parse(element.quantity.toString()));
      }
    }

    if (orderModel.specialDiscount != null && orderModel.specialDiscount!['special_discount'] != null) {
      specialDiscount = double.parse(orderModel.specialDiscount!['special_discount'].toString());
    }

    if (orderModel.taxSetting != null) {
      for (var element in orderModel.taxSetting!) {
        taxAmount = taxAmount + Constant.calculateTax(amount: (subTotal - double.parse(orderModel.discount.toString()) - specialDiscount).toString(), taxModel: element);
      }
    }

    totalAmount = subTotal - double.parse(orderModel.discount.toString()) - specialDiscount;

    if (orderModel.adminCommissionType == 'Percent') {
      double basePrice = subTotal / (1 + (double.parse(orderModel.adminCommission!) / 100));
      adminCommission = subTotal - basePrice;
    } else {
      adminCommission = double.parse(orderModel.adminCommission!);
    }

    return InkWell(
      onTap: () async {
        Get.to(const OrderDetailsScreen(), arguments: {"orderModel": orderModel});
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Container(
          decoration: ShapeDecoration(
            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: NetworkImageWidget(
                        imageUrl: orderModel.author!.profilePictureURL.toString(),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TranslatedText(
                            orderModel.author!.fullName().toString(),
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                              fontSize: 14,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                          orderModel.takeAway == true
                              ? TranslatedText(
                                  "Take Away",
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                )
                              : TranslatedText(
                                  orderModel.address?.getFullAddress() ?? '',
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                                    fontSize: 12,
                                    fontFamily: AppThemeData.medium,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right)
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: MySeparator(color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: orderModel.products!.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    CartProductModel product = orderModel.products![index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TranslatedText(
                                "${product.quantity}x ${product.name}",
                                style: TextStyle(
                                  color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppThemeData.semiBold,
                                ),
                              ),
                            ),
                            Text(
                              double.parse(product.discountPrice ?? "0.0") <= 0
                                  ? Constant.amountShow(amount: (double.parse(product.price.toString()) * double.parse(product.quantity.toString())).toString())
                                  : Constant.amountShow(amount: (double.parse(product.discountPrice.toString()) * double.parse(product.quantity.toString())).toString()),
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: AppThemeData.semiBold,
                              ),
                            ),
                          ],
                        ),
                        product.variantInfo == null || product.variantInfo!.variantOptions!.isEmpty
                            ? Container()
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText(
                                      "Variants",
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Wrap(
                                      spacing: 6.0,
                                      runSpacing: 6.0,
                                      children: List.generate(
                                        product.variantInfo!.variantOptions!.length,
                                        (i) {
                                          return Container(
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                              child: TranslatedText(
                                                "${product.variantInfo!.variantOptions!.keys.elementAt(i)} : ${product.variantInfo!.variantOptions![product.variantInfo!.variantOptions!.keys.elementAt(i)]}",
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.medium,
                                                  color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    ),
                                  ],
                                ),
                              ),
                        product.extras == null || product.extras!.isEmpty
                            ? const SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TranslatedText(
                                          "Addons",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontFamily: AppThemeData.semiBold,
                                            color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        Constant.amountShow(amount: (double.parse(product.extrasPrice.toString()) * double.parse(product.quantity.toString())).toString()),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.semiBold,
                                          color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    spacing: 6.0,
                                    runSpacing: 6.0,
                                    children: List.generate(
                                      product.extras!.length,
                                      (i) {
                                        return Container(
                                          decoration: ShapeDecoration(
                                            color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                                            child: TranslatedText(
                                              product.extras![i].toString(),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: AppThemeData.medium,
                                                color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ],
                              ),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Order Date",
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppThemeData.regular,
                        ),
                      ),
                    ),
                    TranslatedText(
                      Constant.timestampToDateTime(orderModel.createdAt!),
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TranslatedText(
                        "Total Amount",
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppThemeData.regular,
                        ),
                      ),
                    ),
                    Text(
                      Constant.amountShow(amount: totalAmount.toString(), decimalDigits: 3),
                      style: TextStyle(
                        color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppThemeData.semiBold,
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: Constant.adminCommission?.isEnabled == true,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              "Admin Commissions",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: adminCommission.toString(), decimalDigits: 3)}",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              "Admin Commission Tax",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: Constant.calculateAdminCommissionTax(adminCommission).toString(), decimalDigits: 3)}",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              (Constant.userModel?.userBankDetails?.gstNumber ?? '').trim().isNotEmpty ? "TCS" : "TDS",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          Text(
                            "-${Constant.amountShow(amount: Constant.calculateTdsOrTcs(totalAmount, hasGst: (Constant.userModel?.userBankDetails?.gstNumber ?? '').trim().isNotEmpty).toString(), decimalDigits: 3)}",
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                orderModel.scheduleTime == null
                    ? const SizedBox()
                    : Row(
                        children: [
                          Expanded(
                            child: TranslatedText(
                              "Schedule Time",
                              style: TextStyle(
                                color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                fontFamily: AppThemeData.regular,
                              ),
                            ),
                          ),
                          TranslatedText(
                            Constant.timestampToDateTime(orderModel.scheduleTime!),
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              fontFamily: AppThemeData.semiBold,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(
                  height: 5,
                ),
                orderModel.notes == null || orderModel.notes!.isEmpty
                    ? const SizedBox()
                    : InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return viewRemarkDialog(controller, themeChange, orderModel);
                            },
                          );
                        },
                        child: TranslatedText(
                          "View Remarks",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppThemeData.regular,
                            decoration: TextDecoration.underline,
                            color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                            fontSize: 16,
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: RoundedButtonFill(
                    title: Constant.statusDisplayLabel(
                      status: orderModel.status.toString(),
                    ),
                    color: orderModel.status == Constant.orderRejected
                        ? AppThemeData.danger300
                        : Constant.statusColor(status: orderModel.status),
                    textColor: AppThemeData.grey50,
                    height: 5,
                    onPress: () async {},
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Dialog showListOfDeliverymenDialog(HomeController controller, themeChange, OrderModel orderModel) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: TranslatedText(
                      "Select the delivery man",
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: AppThemeData.semiBold,
                        color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: TranslatedText(
                        'Add Delivery Man',
                        style: TextStyle(color: AppThemeData.secondary300, fontFamily: AppThemeData.medium),
                      ),
                    ),
                    onPressed: () {
                      Get.to(AddDriverScreen())?.then((value) async {
                        if (value == true) {
                          Get.back();
                          ShowToastDialog.showToastDuration("Please ensure that the deliveryman is signed in and has an active status to assign the delivery.", duration: Duration(seconds: 4));
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Obx(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownSearch<UserModel>(
                  items: (String s, LoadProps? data) => controller.driverUserList,
                  selectedItem: controller.selectDriverUser.value,
                  compareFn: (UserModel a, UserModel b) => a.id == b.id,
                  itemAsString: (UserModel? user) => user == null || user.id == null ? "Select Delivery Man" : "${user.firstName} ${user.lastName}",
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: "Search Delivery Man",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    ),
                    itemBuilder: (context, UserModel driver, bool isSelected, bool check) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 5,
                              child: TranslatedText(
                                "${driver.firstName} ${driver.lastName}",
                                style: TextStyle(
                                  fontFamily: AppThemeData.medium,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            if (Constant.singleOrderReceive == true)
                              Expanded(
                                flex: 1,
                                child: driver.inProgressOrderID?.isEmpty == true
                                    ? TranslatedText(
                                        'Assign',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.medium,
                                          fontSize: 12,
                                          color: AppThemeData.secondary300,
                                        ),
                                      )
                                    : TranslatedText(
                                        'Occupied',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: AppThemeData.medium,
                                          fontSize: 12,
                                          color: AppThemeData.danger300,
                                        ),
                                      ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  decoratorProps: DropDownDecoratorProps(
                    decoration: InputDecoration(
                      labelText: "Select Delivery Man",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                  onSelected: (UserModel? value) {
                    if (value == null) return;

                    if (Constant.singleOrderReceive == true && value.inProgressOrderID?.isNotEmpty == true) {
                      ShowToastDialog.showToast(
                        "This delivery man is already assigned. Kindly select a different one.",
                      );
                      return;
                    }

                    controller.selectDriverUser.value = value;
                  },
                ))),
            SizedBox(height: 20),
            PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                height: 3.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: RoundedButtonFill(
                          title: "Cancel",
                          color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                          textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                          onPress: () async {
                            Get.back();
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: RoundedButtonFill(
                          title: "Order Assign",
                          color: AppThemeData.secondary300,
                          textColor: AppThemeData.grey50,
                          onPress: () async {
                            if (controller.selectDriverUser.value.id != null && controller.selectDriverUser.value.id != '') {
                              Get.back();
                              ShowToastDialog.showLoader('Please wait...');
                              await AudioPlayerService.playSound(false);
                              if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) && controller.vendermodel.value.subscriptionPlan != null) {
                                if (controller.vendermodel.value.subscriptionTotalOrders != '-1' && controller.vendermodel.value.subscriptionTotalOrders != null) {
                                  controller.vendermodel.value.subscriptionTotalOrders = (int.parse(controller.vendermodel.value.subscriptionTotalOrders!) - 1).toString();
                                  await FireStoreUtils.updateVendor(controller.vendermodel.value);
                                }
                              }
                              orderModel.notes = "";
                              orderModel.driverID = controller.selectDriverUser.value.id;
                              orderModel.driver = controller.selectDriverUser.value;
                              orderModel.status = Constant.orderInTransit;
                              controller.selectDriverUser.value.inProgressOrderID!.add(orderModel.id);
                              await AudioPlayerService.playSound(false);
                              final OrderModel orderWithCashback =
                                  await FireStoreUtils.attachDriverCashbackIfEligible(
                                orderModel,
                                controller.selectDriverUser.value.id ?? '',
                              );
                              await FireStoreUtils.updateOrder(orderWithCashback);
                              await FireStoreUtils.updateDriverUser(controller.selectDriverUser.value);
                              await FireStoreUtils.restaurantVendorWalletSet(orderWithCashback);
                              SendNotification.sendFcmMessage(Constant.restaurantAccepted, orderWithCashback.author!.fcmToken.toString(), {});
                              SendNotification.sendFcmMessage(Constant.newDeliveryOrder, orderWithCashback.driver?.fcmToken ?? '', {});
                              await AudioPlayerService.playSound(false);
                              ShowToastDialog.closeLoader();
                            } else {
                              ShowToastDialog.showToast("Please select the delivery man");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Dialog estimatedTimeDialog(HomeController controller, themeChange, OrderModel orderModel, BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: TranslatedText(
                "Estimate time to prepare",
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: AppThemeData.semiBold,
                  color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                  fontSize: 18,
                ),
              ),
            ),
            PreferredSize(
              preferredSize: const Size.fromHeight(4.0),
              child: Container(
                color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                height: 3.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  TextFieldWidget(
                    title: 'Estimated time to Prepare',
                    inputFormatters: [MaskedInputFormatter('##:##')],
                    controller: controller.estimatedTimeController.value,
                    hintText: '00:00',
                    textInputType: TextInputType.number,
                    prefix: const Icon(Icons.alarm),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: RoundedButtonFill(
                          title: "Cancel",
                          color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                          textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                          onPress: () async {
                            Get.back();
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: RoundedButtonFill(
                          title: "Shipped order",
                          color: AppThemeData.secondary300,
                          textColor: AppThemeData.grey50,
                          onPress: () async {
                            if (controller.estimatedTimeController.value.text.isNotEmpty) {
                              if (Constant.isSelfDeliveryFeature == true && controller.vendermodel.value.isSelfDelivery == true && orderModel.takeAway == false) {
                                ShowToastDialog.showLoader('Please wait...');
                                await controller.getAllDriverList();
                                ShowToastDialog.closeLoader();
                                orderModel.estimatedTimeToPrepare = controller.estimatedTimeController.value.text;
                                Get.back();
                                showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (BuildContext context) {
                                    return showListOfDeliverymenDialog(controller, themeChange, orderModel);
                                  },
                                );
                              } else {
                                ShowToastDialog.showLoader('Please wait...');
                                if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) && controller.vendermodel.value.subscriptionPlan != null) {
                                  if (controller.vendermodel.value.subscriptionTotalOrders != '-1' && controller.vendermodel.value.subscriptionTotalOrders != null) {
                                    controller.vendermodel.value.subscriptionTotalOrders = (int.parse(controller.vendermodel.value.subscriptionTotalOrders!) - 1).toString();
                                    await FireStoreUtils.updateVendor(controller.vendermodel.value);
                                  }
                                }
                                orderModel.estimatedTimeToPrepare = controller.estimatedTimeController.value.text;
                                orderModel.status = Constant.orderAccepted;
                                await AudioPlayerService.playSound(false);
                                await FireStoreUtils.updateOrder(orderModel);
                                await FireStoreUtils.restaurantVendorWalletSet(orderModel);
                                SendNotification.sendFcmMessage(Constant.restaurantAccepted, orderModel.author!.fcmToken.toString(), {});
                                ShowToastDialog.closeLoader();
                                await AudioPlayerService.playSound(false);
                                Get.back();
                              }
                            } else {
                              ShowToastDialog.showToast("Please enter estimated time");
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Dialog viewRemarkDialog(HomeController controller, themeChange, OrderModel orderModel) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: TranslatedText(
                  orderModel.notes.toString(),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: AppThemeData.semiBold,
                    color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                    fontSize: 18,
                  ),
                ),
              ),
              RoundedButtonFill(
                title: "Cancel",
                color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                onPress: () async {
                  Get.back();
                },
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
