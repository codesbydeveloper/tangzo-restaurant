import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/subscription_controller.dart';
import 'package:restaurant/themes/app_them_data.dart';
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
          body: controller.isLoadingPayment.value
              ? Align(
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
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatedText(
                          "Select Payment Method",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontFamily: AppThemeData.semiBold,
                            fontSize: 16,
                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          decoration: ShapeDecoration(
                            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Visibility(
                                  visible: controller.walletSettingModel.value.isEnabled == true,
                                  child: cardDecoration(controller, PaymentGateway.wallet, themeChange, "assets/images/ic_wallet.png"),
                                ),
                                Visibility(
                                  visible: controller.cashfreeModel.value.enable == true,
                                  child: cardDecoration(controller, PaymentGateway.cashfree, themeChange, "assets/images/cashfree.png"),
                                ),
                                Visibility(
                                  visible: controller.stripeModel.value.isEnabled == true,
                                  child: cardDecoration(controller, PaymentGateway.stripe, themeChange, "assets/images/stripe.png"),
                                ),
                                Visibility(
                                  visible: controller.payPalModel.value.isEnabled == true,
                                  child: cardDecoration(controller, PaymentGateway.paypal, themeChange, "assets/images/paypal.png"),
                                ),
                                Visibility(
                                  visible: controller.payStackModel.value.isEnable == true,
                                  child: cardDecoration(controller, PaymentGateway.paystack, themeChange, "assets/images/paystack.png"),
                                ),
                                Visibility(
                                  visible: controller.razorPayModel.value.isEnabled == true,
                                  child: cardDecoration(controller, PaymentGateway.razorpay, themeChange, "assets/images/razorpay.png"),
                                ),
                                Visibility(
                                  visible: controller.flutterWaveModel.value.isEnable == true,
                                  child: cardDecoration(controller, PaymentGateway.flutterwave, themeChange, "assets/images/flutterwave_logo.png"),
                                ),
                                Visibility(
                                  visible: controller.payFastModel.value.isEnable == true,
                                  child: cardDecoration(controller, PaymentGateway.payfast, themeChange, "assets/images/payfast.png"),
                                ),
                                Visibility(
                                  visible: controller.paytmModel.value.isEnabled == true,
                                  child: cardDecoration(controller, PaymentGateway.paytm, themeChange, "assets/images/paytm.png"),
                                ),
                                Visibility(
                                  visible: controller.mercadoPagoModel.value.isEnabled == true,
                                  child: cardDecoration(controller, PaymentGateway.mercadopago, themeChange, "assets/images/mercado-pago.png"),
                                ),
                                Visibility(
                                  visible: controller.midTransModel.value.enable == true,
                                  child: cardDecoration(controller, PaymentGateway.midtrans, themeChange, "assets/images/midtrans.png"),
                                ),
                                Visibility(
                                  visible: controller.orangeMoneyModel.value.enable == true,
                                  child: cardDecoration(controller, PaymentGateway.orangemoney, themeChange, "assets/images/orange_money.png"),
                                ),
                                Visibility(
                                  visible: controller.xenditModel.value.enable == true,
                                  child: cardDecoration(controller, PaymentGateway.xendit, themeChange, "assets/images/xendit.png"),
                                ),
                                Visibility(
                                  visible: controller.mtnMomoModel.value.enable == true,
                                  child: cardDecoration(controller, PaymentGateway.mtnmomo, themeChange, "assets/images/mtnmom.png"),
                                ),
                                Visibility(
                                  visible: controller.phonePeModel.value.enable == true,
                                  child: cardDecoration(controller, PaymentGateway.phonepe, themeChange, "assets/images/phonepe.png"),
                                ),
                                Visibility(
                                  visible: controller.instamojoModel.value.enable == true,
                                  child: cardDecoration(controller, PaymentGateway.instamojo, themeChange, "assets/images/instamojo.png"),
                                ),
                                Visibility(
                                  visible: controller.payMongoModel.value.enable == true,
                                  child: cardDecoration(controller, PaymentGateway.paymongo, themeChange, "assets/images/payMongo.png"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          bottomNavigationBar: Container(
            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: RoundedButtonFill(
                title: "${'Pay Now'} | ${Constant.amountShow(amount: controller.totalAmount.value.toString())}",
                height: 5.5,
                color: AppThemeData.primary300,
                textColor: AppThemeData.grey50,
                fontSizes: 16,
                onPress: () async {
                  final amount = controller.totalAmount.value.toString();
                  final method = controller.selectedPaymentMethod.value;
                  if (method.isEmpty) {
                    ShowToastDialog.showToast("Please select payment method");
                    return;
                  }
                  if (method == PaymentGateway.wallet.name) {
                    await controller.placeOrder();
                  } else if (method == PaymentGateway.cashfree.name) {
                    await controller.cashFreeMakePayment(context: context, amount: amount, paymentDesc: "Subscription Payment");
                  } else if (method == PaymentGateway.stripe.name) {
                    await controller.stripeMakePayment(amount: amount);
                  } else if (method == PaymentGateway.paypal.name) {
                    controller.paypalPaymentSheet(amount, context);
                  } else if (method == PaymentGateway.paystack.name) {
                    await controller.payStackPayment(amount);
                  } else if (method == PaymentGateway.razorpay.name) {
                    controller.openCheckout(amount: amount, orderId: '');
                  } else if (method == PaymentGateway.flutterwave.name) {
                    await controller.flutterWaveInitiatePayment(context: context, amount: amount);
                  } else if (method == PaymentGateway.payfast.name) {
                    controller.payFastPayment(context: context, amount: amount);
                  } else if (method == PaymentGateway.paytm.name) {
                    await controller.getPaytmCheckSum(context, amount: double.parse(amount));
                  } else if (method == PaymentGateway.mercadopago.name) {
                    await controller.mercadoPagoMakePayment(context: context, amount: amount);
                  } else if (method == PaymentGateway.midtrans.name) {
                    await controller.midtransMakePayment(context: context, amount: amount);
                  } else if (method == PaymentGateway.orangemoney.name) {
                    await controller.orangeMakePayment(context: context, amount: amount);
                  } else if (method == PaymentGateway.xendit.name) {
                    await controller.xenditPayment(context, amount);
                  } else if (method == PaymentGateway.mtnmomo.name) {
                    await controller.mtnMomoMakePayment(amount: amount);
                  } else if (method == PaymentGateway.instamojo.name) {
                    await controller.makeInstamojoPayment(amount: amount, paymentDesc: "Subscription Payment");
                  } else if (method == PaymentGateway.paymongo.name) {
                    await controller.makePayMongoPayment(amount: amount, paymentDesc: "Subscription Payment");
                  } else {
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
        child: InkWell(
          onTap: () {
            controller.selectedPaymentMethod.value = value.name;
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
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(image),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TranslatedText(
                  value == PaymentGateway.wallet
                      ? "Wallet"
                      : value == PaymentGateway.cashfree
                          ? "Cashfree"
                          : (value.name.capitalizeFirst ?? value.name),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: AppThemeData.medium,
                    fontSize: 16,
                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                  ),
                ),
              ),
              Radio(
                value: value.name,
                groupValue: controller.selectedPaymentMethod.value,
                activeColor: AppThemeData.primary300,
                onChanged: (v) {
                  controller.selectedPaymentMethod.value = v.toString();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
