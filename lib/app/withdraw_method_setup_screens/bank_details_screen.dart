import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/controller/bank_details_controller.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/themes/text_field_widget.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';

import 'package:restaurant/widget/translated_text.dart';

class BankDetailsScreen extends StatelessWidget {
  const BankDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: BankDetailsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              iconTheme: IconThemeData(color: AppThemeData.grey50, size: 20),
              title: TranslatedText(
                "Bank Setup",
                style: TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFieldWidget(
                      title: 'Bank Name',
                      controller: controller.bankNameController.value,
                      hintText: 'Enter Bank Name',
                    ),
                    TextFieldWidget(
                      title: 'Branch Name',
                      controller: controller.branchNameController.value,
                      hintText: 'Enter Branch Name',
                    ),
                    TextFieldWidget(
                      title: 'Holder Name',
                      controller: controller.holderNameController.value,
                      hintText: 'Enter Holder Name',
                    ),
                    TextFieldWidget(
                      title: 'Account Number',
                      controller: controller.accountNoController.value,
                      hintText: 'Enter Account Number',
                    ),
                    TextFieldWidget(
                      title: 'IFSC Code',
                      controller: controller.otherInfoController.value,
                      hintText: 'Enter IFSC Code',
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TranslatedText(
                        'GST Available',
                        style: TextStyle(
                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                          fontSize: 14,
                          fontFamily: AppThemeData.medium,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            value: true,
                            groupValue: controller.isGstAvailable.value,
                            contentPadding: EdgeInsets.zero,
                            title: const TranslatedText('Yes'),
                            activeColor: AppThemeData.secondary300,
                            onChanged: (value) {
                              controller.isGstAvailable.value = value ?? false;
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            value: false,
                            groupValue: controller.isGstAvailable.value,
                            contentPadding: EdgeInsets.zero,
                            title: const TranslatedText('No'),
                            activeColor: AppThemeData.secondary300,
                            onChanged: (value) {
                              controller.isGstAvailable.value = value ?? false;
                            },
                          ),
                        ),
                      ],
                    ),
                    if (controller.isGstAvailable.value) ...[
                      TextFieldWidget(
                        title: 'GST Number',
                        controller: controller.gstNumberController.value,
                        hintText: 'Enter GST Number',
                        textInputAction: TextInputAction.next,
                      ),
                      TextFieldWidget(
                        title: 'PAN Number',
                        controller: controller.panNumberController.value,
                        hintText: 'Enter PAN Number',
                      ),
                    ],
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
                    title: "Add Bank",
                    height: 5.5,
                    color: AppThemeData.secondary300,
                    textColor: AppThemeData.grey50,
                    fontSizes: 16,
                    onPress: () async {
                      controller.saveBank();
                    },
                  )),
            ),
          );
        });
  }
}
