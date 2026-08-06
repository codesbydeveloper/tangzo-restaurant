import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/subscription_controller.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/responsive.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/widget/translated_text.dart';

class SelectPaymentScreen extends StatelessWidget {
  const SelectPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: SubscriptionController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
          appBar: AppBar(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            centerTitle: false,
            titleSpacing: 0,
            title: TranslatedText(
              "Payment Option",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: AppThemeData.medium,
                fontSize: 16,
                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
              ),
            ),
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatedText(
                          "Preferred Payment",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            fontSize: 16,
                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // Wallet and other gateways disabled — Cashfree only
                        // if (controller.walletSettingModel.value.isEnabled == true)
                        //   Container(
                        //     decoration: ShapeDecoration(
                        //       color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(16),
                        //       ),
                        //       shadows: const [
                        //         BoxShadow(
                        //           color: Color(0x07000000),
                        //           blurRadius: 20,
                        //           offset: Offset(0, 0),
                        //           spreadRadius: 0,
                        //         )
                        //       ],
                        //     ),
                        //     child: Padding(
                        //       padding: const EdgeInsets.all(8.0),
                        //       child: Column(
                        //         children: [
                        //           Visibility(
                        //             visible: controller.walletSettingModel.value.isEnabled == true,
                        //             child: cardDecoration(controller, PaymentGateway.wallet, themeChange, "assets/images/ic_wallet.png"),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            TranslatedText(
                              "Payment Options",
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: AppThemeData.semiBold,
                                fontSize: 16,
                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                        controller.isLoadingPayment.value == true
                            ? SizedBox(
                                height: Responsive.height(60, context),
                                width: Responsive.width(100, context),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: TranslatedText(
                                    "Loading, please wait...",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: AppThemeData.semiBold,
                                      fontSize: 16,
                                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                decoration: ShapeDecoration(
                                  color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  shadows: const [
                                    BoxShadow(
                                      color: Color(0x07000000),
                                      blurRadius: 20,
                                      offset: Offset(0, 0),
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      // Visibility(
                                      //   visible: controller.stripeModel.value.isEnabled == true,
                                      //   child: cardDecoration(controller, PaymentGateway.stripe, themeChange, "assets/images/stripe.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.payPalModel.value.isEnabled == true,
                                      //   child: cardDecoration(controller, PaymentGateway.paypal, themeChange, "assets/images/paypal.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.payStackModel.value.isEnable == true,
                                      //   child: cardDecoration(controller, PaymentGateway.paystack, themeChange, "assets/images/paystack.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.mercadoPagoModel.value.isEnabled == true,
                                      //   child: cardDecoration(controller, PaymentGateway.mercadopago, themeChange, "assets/images/mercado-pago.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.flutterWaveModel.value.isEnable == true,
                                      //   child: cardDecoration(controller, PaymentGateway.flutterwave, themeChange, "assets/images/flutterwave_logo.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.payFastModel.value.isEnable == true,
                                      //   child: cardDecoration(controller, PaymentGateway.payfast, themeChange, "assets/images/payfast.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.paytmModel.value.isEnabled == true,
                                      //   child: cardDecoration(controller, PaymentGateway.paytm, themeChange, "assets/images/paytm.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.razorPayModel.value.isEnabled == true,
                                      //   child: cardDecoration(controller, PaymentGateway.razorpay, themeChange, "assets/images/razorpay.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.midTransModel.value.enable == true,
                                      //   child: cardDecoration(controller, PaymentGateway.midtrans, themeChange, "assets/images/midtrans.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.orangeMoneyModel.value.enable == true,
                                      //   child: cardDecoration(controller, PaymentGateway.orangemoney, themeChange, "assets/images/orange_money.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.xenditModel.value.enable == true,
                                      //   child: cardDecoration(controller, PaymentGateway.xendit, themeChange, "assets/images/xendit.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.mtnMomoModel.value.enable == true,
                                      //   child: cardDecoration(controller, PaymentGateway.mtnmomo, themeChange, "assets/images/mtnmom.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.phonePeModel.value.enable == true,
                                      //   child: cardDecoration(controller, PaymentGateway.phonepe, themeChange, "assets/images/phonepe.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.instamojoModel.value.enable == true,
                                      //   child: cardDecoration(controller, PaymentGateway.instamojo, themeChange, "assets/images/instamojo.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.foloosiModel.value.enable == true,
                                      //   child: cardDecoration(controller, PaymentGateway.foloosi, themeChange, "assets/images/foloosi.png"),
                                      // ),
                                      // Visibility(
                                      //   visible: controller.payMongoModel.value.enable == true,
                                      //   child: cardDecoration(controller, PaymentGateway.paymongo, themeChange, "assets/images/payMongo.png"),
                                      // ),
                                      Visibility(
                                        visible: controller.cashfreeModel.value.enable == true,
                                        child: cardDecoration(controller, PaymentGateway.cashfree, themeChange, "assets/images/cashfree.png"),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: RoundedButtonFill(
                title: "${"Pay Now".tr} | ${Constant.amountShow(amount: controller.totalAmount.value.toString())}",
                height: 5,
                color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                textColor: AppThemeData.grey50,
                fontSizes: 16,
                onPress: () async {
                  if (controller.selectedPaymentMethod.value == '') {
                    ShowToastDialog.showToast("Please Select Payment Method.");
                  } else if (controller.selectedPaymentMethod.value == PaymentGateway.cashfree.name.toLowerCase() ||
                      controller.selectedPaymentMethod.value.toLowerCase() == controller.cashfreeModel.value.name?.toLowerCase()) {
                    controller.cashFreeMakePayment(context: context, amount: controller.totalAmount.value.toString(), paymentDesc: "Subscription Payment");
                  } else {
                    // Other gateways disabled — Cashfree only
                    // if (controller.selectedPaymentMethod.value == PaymentGateway.stripe.name.toLowerCase()) {
                    //   controller.stripeMakePayment(amount: controller.totalAmount.value.toString());
                    // } else if (controller.selectedPaymentMethod.value == PaymentGateway.paypal.name.toLowerCase()) {
                    //   controller.paypalPaymentSheet(controller.totalAmount.value.toString(), context);
                    // } else if (controller.selectedPaymentMethod.value == PaymentGateway.paystack.name.toLowerCase()) {
                    //   controller.payStackPayment(controller.totalAmount.value.toString());
                    // } else if (controller.selectedPaymentMethod.value == PaymentGateway.mercadopago.name.toLowerCase()) {
                    //   controller.mercadoPagoMakePayment(context: context, amount: controller.totalAmount.value.toString());
                    // } else if (controller.selectedPaymentMethod.value == PaymentGateway.flutterwave.name.toLowerCase()) {
                    //   controller.flutterWaveInitiatePayment(context: context, amount: controller.totalAmount.value.toString());
                    // } else if (controller.selectedPaymentMethod.value == PaymentGateway.payfast.name.toLowerCase()) {
                    //   controller.payFastPayment(context: context, amount: controller.totalAmount.value.toString());
                    // } else if (controller.selectedPaymentMethod.value == PaymentGateway.paytm.name.toLowerCase()) {
                    //   controller.getPaytmCheckSum(context, amount: double.parse(controller.totalAmount.value.toString()));
                    // } else if (controller.selectedPaymentMethod.value == PaymentGateway.wallet.name.toLowerCase()) {
                    //   if ((controller.userModel.value.walletAmount ?? 0.0) >= controller.totalAmount.value) {
                    //     Get.back();
                    //     controller.placeOrder();
                    //   } else {
                    //     ShowToastDialog.showToast("You don't have sufficient wallet balance to purchase the subscription plan");
                    //   }
                    // } else if (controller.selectedPaymentMethod.value == PaymentGateway.midtrans.name.toLowerCase()) {
                    //   controller.midtransMakePayment(context: context, amount: controller.totalAmount.value.toString());
                    // } else if (controller.selectedPaymentMethod.value == PaymentGateway.orangemoney.name.toLowerCase()) {
                    //   controller.orangeMakePayment(context: context, amount: controller.totalAmount.value.toString());
                    // } else if (controller.selectedPaymentMethod.value == PaymentGateway.xendit.name.toLowerCase()) {
                    //   controller.xenditPayment(context, controller.totalAmount.value.toString());
                    // } else if (controller.selectedPaymentMethod.value == PaymentGateway.razorpay.name.toLowerCase()) {
                    //   ...
                    // }
                    ShowToastDialog.showToast("Please select payment method");
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Obx cardDecoration(SubscriptionController controller, PaymentGateway value, themeChange, String image) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          children: [
            InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                controller.selectedPaymentMethod.value = value.name.toLowerCase();
              },
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(width: 1, color: Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(value.name == "payFast" ? 0 : 8.0),
                      child: Image.asset(
                        image,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  value == PaymentGateway.wallet
                      ? Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatedText(
                                value.name.capitalizeString(),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.medium,
                                  fontSize: 16,
                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                ),
                              ),
                              Text(
                                Constant.amountShow(amount: Constant.userModel?.walletAmount == null ? '0.0' : Constant.userModel?.walletAmount.toString()),
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontFamily: AppThemeData.semiBold,
                                  fontSize: 16,
                                  color: AppThemeData.secondary300,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: TranslatedText(
                            value.name.capitalizeString(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: AppThemeData.medium,
                              fontSize: 16,
                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            ),
                          ),
                        ),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  Radio(
                    value: value.name.toLowerCase(),
                    groupValue: controller.selectedPaymentMethod.value.toLowerCase(),
                    activeColor: AppThemeData.secondary300,
                    onChanged: (value) {
                      controller.selectedPaymentMethod.value = value!.toLowerCase();
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
