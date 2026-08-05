import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/app/add_restaurant_screen/add_restaurant_screen.dart';
import 'package:restaurant/app/driver_screens/add_driver_screen.dart';
import 'package:restaurant/app/verification_screen/verification_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/driver_list_controller.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/responsive.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';

import 'package:restaurant/utils/network_image_widget.dart';
import 'package:restaurant/widget/translated_text.dart';

class DriverListScreen extends StatelessWidget {
  const DriverListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: DriverListController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              iconTheme: IconThemeData(color: AppThemeData.grey50, size: 20),
              title: TranslatedText(
                "Manage Delivery Man",
                style: TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
              actions: [
                (((Constant.userModel?.isAutoVerify == false && Constant.userModel?.isDocumentVerify == false) ||
                        (Constant.userModel?.vendorID == null || Constant.userModel?.vendorID?.isEmpty == true)))
                    ? SizedBox()
                    : InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          if (Constant.userModel?.vendorID == null || Constant.userModel?.vendorID == '') {
                            ShowToastDialog.showToast("Please add your restaurant details before creating a delivery man.");
                          } else {
                            Get.to(const AddDriverScreen())?.then((value) {
                              if (value == true) {
                                controller.getAllDriverList();
                              }
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add,
                                color: AppThemeData.grey50,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              TranslatedText(
                                "Add",
                                style: TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
                              )
                            ],
                          ),
                        ),
                      )
              ],
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : (Constant.userModel?.isAutoVerify == false && Constant.userModel?.isDocumentVerify == false)
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
                    : (Constant.userModel?.vendorID?.isEmpty == true || Constant.userModel?.vendorID == null)
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
                                  "Get started by adding your restaurant details to manage your delivery men.",
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
                                    Get.to(const AddRestaurantScreen());
                                  },
                                ),
                              ],
                            ),
                          )
                        : controller.driverUserList.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/ic_manage_deliveryman.svg",
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    TranslatedText(
                                      "No Delivery Men Available",
                                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontSize: 22, fontFamily: AppThemeData.semiBold),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    TranslatedText(
                                      "No Delivery Men found! Add your first Delivery Man to start using the self-delivery feature.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey500, fontSize: 16, fontFamily: AppThemeData.bold),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    RoundedButtonFill(
                                        title: "Add Delivery Man",
                                        width: 55,
                                        height: 5.5,
                                        color: AppThemeData.secondary300,
                                        textColor: AppThemeData.grey50,
                                        onPress: () async {
                                          Get.to(const AddDriverScreen())?.then((value) {
                                            if (value == true) {
                                              controller.getAllDriverList();
                                            }
                                          });
                                        }),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                child: ListView.builder(
                                  itemCount: controller.driverUserList.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        Get.to(const AddDriverScreen(), arguments: {"driverModel": controller.driverUserList[index]})!.then(
                                          (value) {
                                            if (value == true) {
                                              controller.getAllDriverList();
                                            }
                                          },
                                        );
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
                                            child: Row(
                                              children: [
                                                controller.driverUserList[index].profilePictureURL == null || controller.driverUserList[index].profilePictureURL == ''
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(60),
                                                        child: Image.asset(
                                                          Constant.userPlaceHolder,
                                                          height: Responsive.width(20, context),
                                                          width: Responsive.width(20, context),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius: const BorderRadius.all(Radius.circular(60)),
                                                        child: NetworkImageWidget(
                                                          imageUrl: controller.driverUserList[index].profilePictureURL.toString(),
                                                          fit: BoxFit.cover,
                                                          height: Responsive.width(20, context),
                                                          width: Responsive.width(20, context),
                                                        )),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: SizedBox(
                                                    height: Responsive.width(18, context),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        TranslatedText(
                                                          "${controller.driverUserList[index].firstName ?? ''} ${controller.driverUserList[index].lastName ?? ''}",
                                                          style: TextStyle(
                                                            fontSize: 18,
                                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                            fontFamily: AppThemeData.semiBold,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        TranslatedText(
                                                          "${controller.driverUserList[index].countryCode} ${controller.driverUserList[index].phoneNumber}",
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                            fontFamily: AppThemeData.regular,
                                                          ),
                                                        ),
                                                        TranslatedText(
                                                          controller.driverUserList[index].email.toString(),
                                                          maxLines: 1,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                            fontFamily: AppThemeData.regular,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                GetBuilder<DriverListController>(builder: (controller) {
                                                  return Transform.scale(
                                                    scale: 0.8,
                                                    child: CupertinoSwitch(
                                                      activeTrackColor: AppThemeData.secondary300,
                                                      value: controller.driverUserList[index].active ?? false,
                                                      onChanged: (value) {
                                                        controller.driverUserList[index].active = value;
                                                        controller.updateDriver(controller.driverUserList[index]);
                                                        controller.update();
                                                      },
                                                    ),
                                                  );
                                                }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
          );
        });
  }
}
