import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/controller/add_edit_role_controller.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/themes/text_field_widget.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';

import 'package:restaurant/widget/translated_text.dart';

class AddEditRoleScreen extends StatelessWidget {
  const AddEditRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: AddEditRoleController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
          appBar: AppBar(
            backgroundColor: AppThemeData.secondary300,
            centerTitle: false,
            iconTheme: IconThemeData(color: AppThemeData.grey50, size: 20),
            title: TranslatedText(
              Get.arguments == null ? "Create Role" : "Edit Role",
              style: TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
            ),
          ),
          body: controller.isLoading.value
              ? Constant.loader()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TranslatedText(
                                "Active",
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 16),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: CupertinoSwitch(
                                activeTrackColor: AppThemeData.secondary300,
                                value: controller.isActive.value,
                                onChanged: (value) {
                                  controller.isActive.value = value;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        TextFieldWidget(
                          fontFamilyTitle: AppThemeData.semiBold,
                          fontSizeTitle: 16,
                          title: 'Role Name',
                          controller: controller.nameController.value,
                          hintText: 'Role Name',
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TranslatedText(
                              "Permissions",
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 16),
                            ),
                            Row(
                              children: [
                                TranslatedText(
                                  'All',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                    fontFamily: AppThemeData.semiBold,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Checkbox(
                                    value: controller.isAllPermission.value,
                                    activeColor: AppThemeData.secondary300, // Color when checked
                                    checkColor: Colors.white, // Tick color
                                    onChanged: (bool? value) {
                                      controller.isAllPermission.value = value!;
                                      controller.setAllPermission(selectAll: value);
                                      controller.permissionList.refresh();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        ListView.builder(
                          padding: EdgeInsets.all(0),
                          primary: false,
                          itemCount: controller.permissionList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            bool selectAll = false;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08), // subtle shadow
                                      blurRadius: 12, // soft edges
                                      offset: const Offset(0, 4), // shadow position
                                      spreadRadius: 1, // light spread
                                    ),
                                  ],
                                ),
                                child: Obx(
                                  () => Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            TranslatedText(
                                              controller.permissionList[index].title ?? '',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                fontFamily: AppThemeData.semiBold,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Checkbox(
                                                  value: controller.permissionList[index].isActive,
                                                  activeColor: AppThemeData.secondary300, // Color when checked
                                                  checkColor: Colors.white, // Tick color
                                                  onChanged: (bool? value) {
                                                    selectAll = value ?? false;
                                                    controller.permissionList[index].isActive = selectAll;
                                                    controller.permissionList.refresh();
                                                    controller.isAllPermission.value = controller.permissionList.every((item) => item.isActive == true);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
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
                  title: "Save Role",
                  height: 5.5,
                  color: AppThemeData.secondary300,
                  textColor: AppThemeData.grey50,
                  fontSizes: 16,
                  onPress: () async {
                    controller.saveEmployeeRole();
                  },
                )),
          ),
        );
      },
    );
  }
}
