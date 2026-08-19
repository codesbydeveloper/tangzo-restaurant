import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';
import 'package:restaurant/app/auth_screen/signup_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/phone_number_controller.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/themes/text_field_widget.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/utils/dynamic_traslator.dart';

import 'package:restaurant/utils/translation_notifier.dart';
import 'package:restaurant/widget/translated_text.dart';

class PhoneNumberScreen extends StatelessWidget {
  const PhoneNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: PhoneNumberController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TranslatedText(
                    "Welcome Back! 👋",
                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontSize: 22, fontFamily: AppThemeData.semiBold),
                  ),
                  TranslatedText(
                    "Log in to continue enjoying delicious food delivered to your doorstep.",
                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.regular),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  TextFieldWidget(
                    title: 'WhatsApp Number',
                    controller: controller.phoneNUmberEditingController.value,
                    hintText: 'Enter WhatsApp Number',
                    textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                    ],
                    prefix: ValueListenableBuilder(
                        valueListenable: TranslationNotifier.refresh,
                        builder: (_, __, ___) {
                          return CountryCodePicker(
                            headerText: 'Select Country'.tr,
                            onInit: (value) {
                              controller.countryCodeEditingController.value.text = value?.dialCode ?? Constant.defaultCountryCode;
                              controller.countryISOCodeEditingController.value.text = value?.code ?? Constant.defaultCountryCode;
                            },
                            onChanged: (value) {
                              controller.countryCodeEditingController.value.text = value.dialCode.toString();
                              controller.countryISOCodeEditingController.value.text = value.code ?? Constant.defaultCountryCode;
                            },
                            dialogTextStyle: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontWeight: FontWeight.w500, fontFamily: AppThemeData.medium),
                            dialogBackgroundColor: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                            initialSelection: controller.countryISOCodeEditingController.value.text,
                            comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                            textStyle: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                            searchDecoration: InputDecoration(
                              iconColor: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            ),
                            searchStyle: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontWeight: FontWeight.w500, fontFamily: AppThemeData.medium),
                          );
                        }),
                  ),
                  const SizedBox(
                    height: 36,
                  ),
                  RoundedButtonFill(
                    title: "Send OTP",
                    color: AppThemeData.secondary300,
                    textColor: AppThemeData.grey50,
                    onPress: () async {
                      if (controller.phoneNUmberEditingController.value.text.isEmpty) {
                        ShowToastDialog.showToast("Please enter mobile number");
                      } else {
                        controller.sendCode();
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      children: [
                        const Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                          child: TranslatedText(
                            "or",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400,
                              fontSize: 16,
                              fontFamily: AppThemeData.medium,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                  ),
                  RoundedButtonFill(
                    title: "Continue with Email",
                    color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                    textColor: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                    onPress: () async {
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: Platform.isAndroid ? 10 : 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder(
                      valueListenable: TranslationNotifier.refresh,
                      builder: (_, __, ___) {
                        return Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: 'Didn’t have an account?'.tr,
                                  style: TextStyle(
                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                    fontFamily: AppThemeData.medium,
                                    fontWeight: FontWeight.w500,
                                  )),
                              const WidgetSpan(
                                  child: SizedBox(
                                width: 10,
                              )),
                              TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(const SignupScreen());
                                    },
                                  text: 'Sign up'.tr,
                                  style: TextStyle(
                                      color: AppThemeData.secondary300,
                                      fontFamily: AppThemeData.bold,
                                      fontWeight: FontWeight.w500,
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppThemeData.secondary300)),
                            ],
                          ),
                        );
                      }),
                ],
              ),
            ),
          );
        });
  }
}
