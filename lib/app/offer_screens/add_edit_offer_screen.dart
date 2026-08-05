import 'dart:io';

import 'package:datetime_picker_formfield_new/datetime_picker_formfield.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/controller/add_edit_coupon_controller.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/responsive.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/themes/text_field_widget.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';

import 'package:restaurant/utils/network_image_widget.dart';
import 'package:restaurant/widget/translated_text.dart';

class AddEditOfferScreen extends StatelessWidget {
  const AddEditOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
      init: AddEditCouponController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
          appBar: AppBar(
            backgroundColor: AppThemeData.secondary300,
            centerTitle: false,
            iconTheme: IconThemeData(color: AppThemeData.grey50, size: 20),
            title: TranslatedText(
              Get.arguments == null ? "Create Offer" : "Edit Offer",
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
                        DottedBorder(
                          options: RoundedRectDottedBorderOptions(
                            radius: const Radius.circular(12),
                            dashPattern: const [6, 6, 6, 6],
                            color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: SizedBox(
                                height: Responsive.height(20, context),
                                width: Responsive.width(90, context),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/ic_folder.svg',
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    TranslatedText(
                                      "Choose a image and upload here",
                                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontFamily: AppThemeData.medium, fontSize: 16),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    TranslatedText(
                                      "JPEG, PNG",
                                      style: TextStyle(fontSize: 12, color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700, fontFamily: AppThemeData.regular),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    RoundedButtonFill(
                                      title: "Brows Image",
                                      color: AppThemeData.secondary50,
                                      width: 30,
                                      height: 5,
                                      textColor: AppThemeData.secondary300,
                                      onPress: () async {
                                        buildBottomSheet(context, controller);
                                      },
                                    ),
                                  ],
                                )),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        controller.images.isEmpty
                            ? const SizedBox()
                            : SizedBox(
                                height: 90,
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: controller.images.length,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 5),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                  child: controller.images[index].runtimeType == XFile
                                                      ? Image.file(
                                                          File(controller.images[index].path),
                                                          fit: BoxFit.cover,
                                                          width: 80,
                                                          height: 80,
                                                        )
                                                      : NetworkImageWidget(
                                                          imageUrl: controller.images[index],
                                                          fit: BoxFit.cover,
                                                          width: 80,
                                                          height: 80,
                                                        ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  top: 0,
                                                  left: 0,
                                                  right: 0,
                                                  child: InkWell(
                                                    splashColor: Colors.transparent,
                                                    onTap: () {
                                                      controller.images.removeAt(index);
                                                    },
                                                    child: const Icon(
                                                      Icons.remove_circle,
                                                      size: 28,
                                                      color: AppThemeData.danger300,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFieldWidget(
                          title: 'Title',
                          controller: controller.titleController.value,
                          hintText: 'Title',
                          maxLength: 30,
                        ),
                        TextFieldWidget(
                          title: 'Coupon Code',
                          controller: controller.couponCodeController.value,
                          hintText: 'Coupon Code',
                        ),
                        TranslatedText('Select Coupon Type',
                            style: TextStyle(fontFamily: AppThemeData.medium, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900)),
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: RadioListTile<String>(
                                value: 'Fix Price',
                                groupValue: controller.selectCouponType.value,
                                title: const TranslatedText('Fix Price'),
                                activeColor: AppThemeData.secondary300,
                                onChanged: (value) {
                                  controller.selectCouponType.value = value!;
                                },
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: RadioListTile<String>(
                                value: 'Percentage',
                                groupValue: controller.selectCouponType.value,
                                title: const TranslatedText('Percentage'),
                                activeColor: AppThemeData.secondary300,
                                onChanged: (value) {
                                  controller.selectCouponType.value = value!;
                                },
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFieldWidget(
                          controller: controller.priceController.value,
                          hintText: 'Enter price',
                          textInputType: TextInputType.number,
                          prefix: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: TranslatedText(
                              controller.selectCouponType.value == "Percentage" || controller.selectCouponType.value == "Percent" ? "%" : "${Constant.currencyModel!.symbol}",
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                            ),
                          ),
                        ),
                        TranslatedText('Expires at', style: TextStyle(fontFamily: AppThemeData.medium, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900)),
                        DateTimeField(
                          format: DateFormat("MMM dd,yyyy"),
                          controller: controller.selectDateController.value,
                          textInputAction: TextInputAction.done,
                          style: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                          decoration: InputDecoration(
                            errorStyle: const TextStyle(color: Colors.red),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                            fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(10),
                              child: SvgPicture.asset("assets/icons/ic_calender.svg"),
                            ),
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
                            hintText: "Select date",
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                              fontFamily: AppThemeData.regular,
                            ),
                          ),
                          onShowPicker: (context, currentValue) {
                            return showDatePicker(
                                firstDate: DateTime.now(),
                                context: context,
                                initialDate: controller.couponModel.value.id == null ? DateTime.now() : controller.couponModel.value.expiresAt!.toDate(),
                                lastDate: DateTime(2100));
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TranslatedText(
                                "Active",
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
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
                        Row(
                          children: [
                            Expanded(
                              child: TranslatedText(
                                "Public",
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                              ),
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: CupertinoSwitch(
                                activeTrackColor: AppThemeData.secondary300,
                                value: controller.isPublic.value,
                                onChanged: (value) {
                                  controller.isPublic.value = value;
                                },
                              ),
                            ),
                          ],
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
                  title: "Save Coupon",
                  height: 5.5,
                  color: AppThemeData.secondary300,
                  textColor: AppThemeData.grey50,
                  fontSizes: 16,
                  onPress: () async {
                    controller.saveCoupon();
                  },
                )),
          ),
        );
      },
    );
  }

  Future<dynamic> buildBottomSheet(BuildContext context, AddEditCouponController controller) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          final themeChange = Provider.of<DarkThemeProvider>(context);
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: TranslatedText(
                      "Please Select",
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.bold, fontSize: 16),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.camera),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: TranslatedText("Camera"),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                                onPressed: () => controller.pickFile(source: ImageSource.gallery),
                                icon: const Icon(
                                  Icons.photo_library_sharp,
                                  size: 32,
                                )),
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: TranslatedText("Gallery"),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
          });
        });
  }
}
