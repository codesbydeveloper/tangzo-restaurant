import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/add_employee_controller.dart';
import 'package:restaurant/models/employee_role_model.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/themes/text_field_widget.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/dynamic_traslator.dart';
import 'package:restaurant/utils/translation_notifier.dart';

import 'package:restaurant/widget/translated_text.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({super.key});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: AddEmployeeController(),
        builder: (controller) {
          return controller.isLoading.value
              ? Constant.loader()
              : Scaffold(
                  appBar: AppBar(
                    backgroundColor: AppThemeData.secondary300,
                    centerTitle: false,
                    iconTheme: IconThemeData(
                      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                    ),
                    title: TranslatedText(
                      controller.employeeModel.value.id == null ? "Add Employee Man" : "Edit Employee Man",
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFieldWidget(
                                    title: 'First Name',
                                    controller: controller.firstNameEditingController.value,
                                    hintText: 'Enter First Name',
                                    prefix: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SvgPicture.asset(
                                        "assets/icons/ic_user.svg",
                                        colorFilter: ColorFilter.mode(
                                          themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: TextFieldWidget(
                                    title: 'Last Name',
                                    controller: controller.lastNameEditingController.value,
                                    hintText: 'Enter Last Name',
                                    prefix: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: SvgPicture.asset(
                                        "assets/icons/ic_user.svg",
                                        colorFilter: ColorFilter.mode(
                                          themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatedText("Role", style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
                              const SizedBox(
                                height: 5,
                              ),
                              DropdownButtonFormField<EmployeeRoleModel>(
                                  hint: TranslatedText(
                                    'Select Role',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey700,
                                      fontFamily: AppThemeData.regular,
                                    ),
                                  ),
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  decoration: InputDecoration(
                                    errorStyle: const TextStyle(color: Colors.red),
                                    isDense: true,
                                    filled: true,
                                    fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                    disabledBorder: UnderlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300, width: 1),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                      borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                    ),
                                  ),
                                  initialValue:
                                      controller.selectEmployeeRole.value.title == null || controller.selectEmployeeRole.value.title?.isEmpty == true ? null : controller.selectEmployeeRole.value,
                                  onChanged: (value) {
                                    controller.selectEmployeeRole.value = value!;
                                    controller.update();
                                  },
                                  style: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                                  items: controller.employeeRolelList.map((employeeRole) {
                                    return DropdownMenuItem<EmployeeRoleModel>(
                                      value: employeeRole,
                                      child: TranslatedText(employeeRole.title ?? ''),
                                    );
                                  }).toList()),
                            ],
                          ),
                          SizedBox(height: 16),
                          TextFieldWidget(
                            isReadyOnly: (controller.employeeModel.value.id != null && controller.employeeModel.value.id != ''),
                            title: 'Email Address',
                            textInputType: TextInputType.emailAddress,
                            controller: controller.emailEditingController.value,
                            hintText: 'Enter Email Address',
                            enable: true,
                            prefix: Padding(
                              padding: const EdgeInsets.all(12),
                              child: SvgPicture.asset(
                                "assets/icons/ic_mail.svg",
                                colorFilter: ColorFilter.mode(
                                  themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                          TextFieldWidget(
                            title: 'Phone Number',
                            controller: controller.phoneNUmberEditingController.value,
                            hintText: 'Enter Phone Number',
                            enable: true,
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
                                    enabled: true,
                                    onChanged: (value) {
                                      controller.countryCodeEditingController.value.text = value.dialCode.toString();
                                      controller.countryISOCodeEditingController.value.text = value.code ?? Constant.defaultCountryCode;
                                    },
                                    dialogTextStyle: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontWeight: FontWeight.w500, fontFamily: AppThemeData.medium),
                                    dialogBackgroundColor: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100,
                                    initialSelection: controller.countryISOCodeEditingController.value.text,
                                    comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                                    textStyle: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                                    searchDecoration: InputDecoration(iconColor: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
                                    searchStyle: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontWeight: FontWeight.w500, fontFamily: AppThemeData.medium),
                                  );
                                }),
                          ),
                          Visibility(
                            visible: controller.employeeModel.value.id == null,
                            child: Column(
                              children: [
                                TextFieldWidget(
                                  title: 'Password',
                                  controller: controller.passwordEditingController.value,
                                  hintText: 'Enter Password',
                                  obscureText: controller.passwordVisible.value,
                                  prefix: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                      "assets/icons/ic_lock.svg",
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
                                        onTap: () {
                                          controller.passwordVisible.value = !controller.passwordVisible.value;
                                        },
                                        child: controller.passwordVisible.value
                                            ? SvgPicture.asset(
                                                "assets/icons/ic_password_show.svg",
                                                colorFilter: ColorFilter.mode(
                                                  themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  BlendMode.srcIn,
                                                ),
                                              )
                                            : SvgPicture.asset(
                                                "assets/icons/ic_password_close.svg",
                                                colorFilter: ColorFilter.mode(
                                                  themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  BlendMode.srcIn,
                                                ),
                                              )),
                                  ),
                                ),
                                TextFieldWidget(
                                  title: 'Confirm Password',
                                  controller: controller.conformPasswordEditingController.value,
                                  hintText: 'Enter Confirm Password',
                                  obscureText: controller.conformPasswordVisible.value,
                                  prefix: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: SvgPicture.asset(
                                      "assets/icons/ic_lock.svg",
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
                                        onTap: () {
                                          controller.conformPasswordVisible.value = !controller.conformPasswordVisible.value;
                                        },
                                        child: controller.conformPasswordVisible.value
                                            ? SvgPicture.asset(
                                                "assets/icons/ic_password_show.svg",
                                                colorFilter: ColorFilter.mode(
                                                  themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  BlendMode.srcIn,
                                                ),
                                              )
                                            : SvgPicture.asset(
                                                "assets/icons/ic_password_close.svg",
                                                colorFilter: ColorFilter.mode(
                                                  themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                  BlendMode.srcIn,
                                                ),
                                              )),
                                  ),
                                ),
                              ],
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
                        title: "Save Details",
                        height: 5.5,
                        color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                        textColor: AppThemeData.grey50,
                        fontSizes: 16,
                        onPress: () async {
                          if (controller.firstNameEditingController.value.text.isEmpty) {
                            ShowToastDialog.showToast("Please enter first name");
                          } else if (controller.lastNameEditingController.value.text.isEmpty) {
                            ShowToastDialog.showToast("Please enter last name");
                          } else if (controller.selectEmployeeRole.value.id?.isEmpty == true || controller.selectEmployeeRole.value.id == null) {
                            ShowToastDialog.showToast("Please select the role");
                          } else if (controller.emailEditingController.value.text.isEmpty) {
                            ShowToastDialog.showToast("Please enter valid email");
                          } else if (controller.phoneNUmberEditingController.value.text.isEmpty) {
                            ShowToastDialog.showToast("Please enter Phone number");
                          } else if (controller.passwordEditingController.value.text.isEmpty && controller.employeeModel.value.id == null) {
                            ShowToastDialog.showToast("Please enter password");
                          } else if (controller.conformPasswordEditingController.value.text.isEmpty && controller.employeeModel.value.id == null) {
                            ShowToastDialog.showToast("Please enter Confirm password");
                          } else if (controller.passwordEditingController.value.text != controller.conformPasswordEditingController.value.text && controller.employeeModel.value.id == null) {
                            ShowToastDialog.showToast("Password and Confirm password doesn't match");
                          } else {
                            controller.signUpWithEmailAndPassword();
                          }
                        },
                      ),
                    ),
                  ),
                );
        });
  }
}
