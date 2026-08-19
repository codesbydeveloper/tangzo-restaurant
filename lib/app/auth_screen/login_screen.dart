import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/app/auth_screen/phone_number_screen.dart';
import 'package:restaurant/app/auth_screen/signup_screen.dart';
import 'package:restaurant/app/forgot_password_screen/forgot_password_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/login_controller.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/themes/text_field_widget.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/dynamic_traslator.dart';

import 'package:restaurant/utils/translation_notifier.dart';
import 'package:restaurant/widget/translated_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: LoginController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
          ),
          body: ValueListenableBuilder(
              valueListenable: TranslationNotifier.refresh,
              builder: (_, __, ___) {
                return DefaultTabController(
                  length: Constant.isEmployeeManagement == true ? 2 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TranslatedText(
                          "Welcome Back! 👋",
                          style: TextStyle(
                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            fontSize: 22,
                            fontFamily: AppThemeData.semiBold,
                          ),
                        ),
                        TranslatedText(
                          "Log in to continue managing your restaurant’s orders and reservations seamlessly.",
                          style: TextStyle(
                            color: themeChange.getThem() ? AppThemeData.grey400 : AppThemeData.grey500,
                            fontSize: 16,
                            fontFamily: AppThemeData.regular,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TabBar(
                          onTap: (value) {
                            controller.selectedTabbar.value = value;
                          },
                          isScrollable: false,
                          dividerColor: Colors.transparent,
                          indicatorColor: AppThemeData.secondary300,
                          labelColor: AppThemeData.secondary300,
                          unselectedLabelColor: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                          labelStyle: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 16),
                          unselectedLabelStyle: TextStyle(fontFamily: AppThemeData.medium, fontSize: 16),
                          indicatorWeight: 2,
                          indicatorSize: TabBarIndicatorSize.label,
                          tabs: Constant.isEmployeeManagement == true
                              ? [
                                  Tab(text: "Owner Login".tr),
                                  Tab(text: "Employee Login".tr),
                                ]
                              : [
                                  Tab(text: "Owner Login".tr),
                                ],
                        ),
                        const SizedBox(height: 40),
                        Expanded(
                          child: TabBarView(
                            children: Constant.isEmployeeManagement == true
                                ? [
                                    OwnerLoginForm(controller: controller),
                                    EmployeeLoginForm(controller: controller),
                                  ]
                                : [
                                    OwnerLoginForm(controller: controller),
                                  ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
          bottomNavigationBar: controller.selectedTabbar.value == 1
              ? SizedBox()
              : Padding(
                  padding: EdgeInsets.symmetric(vertical: Platform.isAndroid ? 20 : 30),
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
      },
    );
  }
}

class OwnerLoginForm extends StatelessWidget {
  final LoginController controller;
  const OwnerLoginForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldWidget(
              title: 'Email',
              controller: controller.emailEditingControllerOwner.value,
              hintText: 'Enter email address',
              prefix: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  'assets/icons/ic_mail.svg',
                  colorFilter: ColorFilter.mode(
                    themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            TextFieldWidget(
              title: 'Password',
              controller: controller.passwordEditingControllerOwner.value,
              hintText: 'Enter Password',
              obscureText: controller.passwordVisible.value,
              prefix: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  'assets/icons/ic_lock.svg',
                  colorFilter: ColorFilter.mode(
                    themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              suffix: Padding(
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () => controller.passwordVisible.value = !controller.passwordVisible.value,
                  child: SvgPicture.asset(
                    controller.passwordVisible.value ? "assets/icons/ic_password_show.svg" : "assets/icons/ic_password_close.svg",
                    colorFilter: ColorFilter.mode(
                      themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () => Get.to(const ForgotPasswordScreen()),
                child: TranslatedText(
                  "Forgot Password",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationColor: AppThemeData.secondary300,
                    color: AppThemeData.secondary300,
                    fontSize: 14,
                    fontFamily: AppThemeData.regular,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            RoundedButtonFill(
              title: "Login",
              color: AppThemeData.secondary300,
              textColor: AppThemeData.grey50,
              onPress: () {
                if (controller.emailEditingControllerOwner.value.text.trim().isEmpty) {
                  ShowToastDialog.showToast("Please enter valid email");
                } else if (controller.passwordEditingControllerOwner.value.text.trim().isEmpty) {
                  ShowToastDialog.showToast("Please enter valid password");
                } else {
                  controller.onwerloginWithEmailAndPassword();
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
              title: "Continue with WhatsApp",
              textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey900,
              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey100,
              icon: SvgPicture.asset(
                "assets/icons/ic_phone.svg",
                colorFilter: ColorFilter.mode(themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey900, BlendMode.srcIn),
              ),
              isRight: false,
              onPress: () => Get.to(const PhoneNumberScreen()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RoundedButtonFill(
                    title: Platform.isIOS ? "with Google" : 'Continue with Google',
                    textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey900,
                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey100,
                    icon: SvgPicture.asset("assets/icons/ic_google.svg"),
                    isRight: false,
                    onPress: () => controller.loginWithGoogle(),
                  ),
                ),
                if (Platform.isIOS) const SizedBox(width: 10),
                if (Platform.isIOS)
                  Expanded(
                    child: RoundedButtonFill(
                      title: "with Apple",
                      textColor: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey900,
                      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey100,
                      icon: SvgPicture.asset("assets/icons/ic_apple.svg"),
                      isRight: false,
                      onPress: () => controller.loginWithApple(),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EmployeeLoginForm extends StatelessWidget {
  final LoginController controller;
  const EmployeeLoginForm({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFieldWidget(
              title: 'Email',
              controller: controller.emailEditingControllerEmployee.value,
              hintText: 'Enter email address',
              prefix: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  'assets/icons/ic_mail.svg',
                  colorFilter: ColorFilter.mode(
                    themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            TextFieldWidget(
              title: 'Password',
              controller: controller.passwordEditingControllerEmployee.value,
              hintText: 'Enter Password',
              obscureText: controller.passwordVisible.value,
              prefix: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  'assets/icons/ic_lock.svg',
                  colorFilter: ColorFilter.mode(
                    themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              suffix: Padding(
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  splashColor: Colors.transparent,
                  onTap: () => controller.passwordVisible.value = !controller.passwordVisible.value,
                  child: SvgPicture.asset(
                    controller.passwordVisible.value ? "assets/icons/ic_password_show.svg" : "assets/icons/ic_password_close.svg",
                    colorFilter: ColorFilter.mode(
                      themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            RoundedButtonFill(
              title: "Login",
              color: AppThemeData.secondary300,
              textColor: AppThemeData.grey50,
              onPress: () {
                if (controller.emailEditingControllerEmployee.value.text.trim().isEmpty) {
                  ShowToastDialog.showToast("Please enter valid email");
                } else if (controller.passwordEditingControllerEmployee.value.text.trim().isEmpty) {
                  ShowToastDialog.showToast("Please enter valid password");
                } else {
                  controller.employeeloginWithEmailAndPassword();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
