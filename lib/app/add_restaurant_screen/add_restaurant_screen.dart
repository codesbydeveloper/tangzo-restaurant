import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/app/add_restaurant_screen/qr_code_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/add_restaurant_controller.dart';
import 'package:restaurant/models/vendor_category_model.dart';
import 'package:restaurant/models/zone_model.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/responsive.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/themes/text_field_widget.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/dynamic_traslator.dart';

import 'package:restaurant/utils/network_image_widget.dart';
import 'package:restaurant/utils/translation_notifier.dart';
import 'package:restaurant/widget/osm_map/map_picker_page.dart';
import 'package:restaurant/widget/place_picker/location_picker_screen.dart';
import 'package:restaurant/widget/place_picker/selected_location_model.dart';
import 'package:restaurant/widget/translated_text.dart';

class AddRestaurantScreen extends StatelessWidget {
  const AddRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return GetX(
        init: AddRestaurantController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppThemeData.secondary300,
              centerTitle: false,
              titleSpacing: 0,
              iconTheme: IconThemeData(color: AppThemeData.grey50, size: 20),
              title: TranslatedText(
                "Restaurant Details",
                style: TextStyle(color: AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
              ),
              actions: [
                Visibility(
                  visible: controller.vendorModel.value.subscriptionPlan?.features?.qrCodeGenerate == true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: RoundedButtonFill(
                      title: "Generate QR Code",
                      width: 38,
                      height: 5,
                      color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                      textColor: AppThemeData.secondary300,
                      onPress: () async {
                        if (controller.vendorModel.value.id == null) {
                          ShowToastDialog.showToast("First save a restaurant details");
                        } else {
                          Get.to(const QrCodeScreen(), arguments: {"vendorModel": controller.vendorModel.value});
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            body: controller.isLoading.value
                ? Constant.loader()
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (Constant.userModel?.role != Constant.userRoleEmployee)
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
                                          // physics: const NeverScrollableScrollPhysics(),
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
                                                        if (Constant.userModel?.role != Constant.userRoleEmployee) {
                                                          controller.images.removeAt(index);
                                                        }
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
                          TextFieldWidget(
                            enable: Constant.userModel?.role != Constant.userRoleEmployee,
                            title: 'Restaurant Name',
                            controller: controller.restaurantNameController.value,
                            hintText: 'Enter restaurant name',
                          ),
                          TextFieldWidget(
                            enable: Constant.userModel?.role != Constant.userRoleEmployee,
                            title: 'Restaurant Description',
                            controller: controller.restaurantDescriptionController.value,
                            maxLine: 5,
                            hintText: 'Enter short description here....',
                          ),
                          TranslatedText(
                            "Mobile number and Address",
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFieldWidget(
                            enable: Constant.userModel?.role != Constant.userRoleEmployee,
                            title: 'Phone Number',
                            controller: controller.mobileNumberController.value,
                            hintText: 'Phone Number',
                            textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            ],
                          ),
                          InkWell(
                            splashColor: Colors.transparent,
                            enableFeedback: Constant.userModel?.role != Constant.userRoleEmployee,
                            onTap: () {
                              if (controller.addressController.value.text.isEmpty) {
                                Constant.checkPermission(
                                    onTap: () async {
                                      ShowToastDialog.showLoader("Please wait");
                                      try {
                                        await Geolocator.requestPermission();
                                        await Geolocator.getCurrentPosition();
                                        ShowToastDialog.closeLoader();
                                        if (Constant.selectedMapType == 'osm') {
                                          final result = await Get.to(() => MapPickerPage());
                                          if (result != null) {
                                            final firstPlace = result;
                                            final lat = firstPlace.coordinates.latitude;
                                            final lng = firstPlace.coordinates.longitude;
                                            final address = firstPlace.address;

                                            controller.selectedLocation = LatLng(lat, lng);
                                            controller.addressController.value.text = address.toString();
                                            controller.isAddressEnable.value = true;
                                          }
                                        } else {
                                          Get.to(LocationPickerScreen())?.then((value) async {
                                            if (value != null) {
                                              SelectedLocationModel selectedLocationModel = value;
                                              controller.selectedLocation = LatLng(selectedLocationModel.latLng!.latitude, selectedLocationModel.latLng!.longitude);
                                              controller.addressController.value.text = Constant.formatAddress(selectedLocation: selectedLocationModel);
                                              controller.isAddressEnable.value = true;
                                            }
                                          });
                                        }
                                      } catch (e) {
                                        ShowToastDialog.closeLoader();
                                      }
                                    },
                                    context: context);
                              }
                            },
                            child: TextFieldWidget(
                              title: 'Address',
                              controller: controller.addressController.value,
                              hintText: 'Enter address',
                              enable: controller.isAddressEnable.value && Constant.userModel?.role != Constant.userRoleEmployee,
                              suffix: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  enableFeedback: Constant.userModel?.role != Constant.userRoleEmployee,
                                  onTap: () {
                                    Constant.checkPermission(
                                      context: context,
                                      onTap: () async {
                                        ShowToastDialog.showToast("Please wait...");
                                        try {
                                          await Geolocator.requestPermission();
                                          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
                                          if (Constant.selectedMapType == 'osm') {
                                            final result = await Get.to(() => MapPickerPage());
                                            if (result != null) {
                                              final firstPlace = result;
                                              final lat = firstPlace.coordinates.latitude;
                                              final lng = firstPlace.coordinates.longitude;
                                              final address = firstPlace.address;

                                              controller.selectedLocation = LatLng(lat, lng);
                                              controller.addressController.value.text = address.toString();
                                              controller.isAddressEnable.value = true;
                                            }
                                          } else {
                                            Get.to(LocationPickerScreen())!.then((value) async {
                                              if (value != null) {
                                                SelectedLocationModel selectedLocationModel = value;

                                                controller.selectedLocation = LatLng(selectedLocationModel.latLng!.latitude, selectedLocationModel.latLng!.longitude);
                                                controller.addressController.value.text = Constant.formatAddress(selectedLocation: selectedLocationModel);
                                                controller.isAddressEnable.value = true;
                                              }
                                            });
                                          }
                                        } catch (e) {
                                          print(e.toString());
                                        }
                                      },
                                    );
                                  },
                                  child: TranslatedText("change",
                                      style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300)),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatedText("Zone", style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
                              const SizedBox(
                                height: 5,
                              ),
                              DropdownButtonFormField<ZoneModel>(
                                  hint: TranslatedText(
                                    'Select zone',
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
                                  initialValue: controller.selectedZone.value.id == null ? null : controller.selectedZone.value,
                                  onChanged: Constant.userModel?.role == Constant.userRoleEmployee
                                      ? null
                                      : (value) {
                                          controller.selectedZone.value = value!;
                                          controller.update();
                                        },
                                  style: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                                  items: controller.zoneList.map((item) {
                                    return DropdownMenuItem<ZoneModel>(
                                      value: item,
                                      child: TranslatedText(item.name.toString()),
                                    );
                                  }).toList()),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          TranslatedText(
                            "Service and Categories",
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatedText("Categories",
                                  style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
                              const SizedBox(
                                height: 5,
                              ),
                              ValueListenableBuilder(
                                valueListenable: TranslationNotifier.refresh,
                                builder: (_, __, ___) {
                                  return DropdownSearch<VendorCategoryModel>.multiSelection(
                                    enabled: Constant.userModel?.role != Constant.userRoleEmployee,
                                    items: (String s, LoadProps? data) => controller.vendorCategoryList,
                                    key: controller.myKey1,
                                    suffixProps: DropdownSuffixProps(
                                      dropdownButtonProps: DropdownButtonProps(
                                        focusColor: AppThemeData.secondary300,
                                        color: AppThemeData.grey600,
                                        iconClosed: const Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppThemeData.grey600,
                                        ),
                                        iconOpened: const Icon(
                                          Icons.keyboard_arrow_up,
                                          color: AppThemeData.grey600,
                                        ),
                                      ),
                                    ),
                                    decoratorProps: DropDownDecoratorProps(
                                      decoration: InputDecoration(
                                        focusColor: AppThemeData.secondary300,
                                        contentPadding: const EdgeInsets.only(left: 8, right: 8),
                                        disabledBorder: UnderlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          borderSide: BorderSide(
                                            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          borderSide: BorderSide(
                                            color: AppThemeData.secondary300,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          borderSide: BorderSide(
                                            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                            width: 1,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          borderSide: BorderSide(
                                            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                            width: 1,
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                          borderSide: BorderSide(
                                            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                            width: 1,
                                          ),
                                        ),
                                        filled: true,
                                        hintStyle: TextStyle(
                                          fontSize: 14,
                                          color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                          fontFamily: AppThemeData.medium,
                                        ),
                                        fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                        hintText: 'Select Categories'.tr,
                                      ),
                                    ),
                                    compareFn: (i1, i2) => i1.title == i2.title,
                                    popupProps: MultiSelectionPopupProps.menu(
                                      textDirection: isRTL == true ? TextDirection.rtl : TextDirection.ltr,
                                      fit: FlexFit.tight,
                                      showSelectedItems: true,
                                      listViewProps: const ListViewProps(
                                        physics: BouncingScrollPhysics(),
                                        padding: EdgeInsets.only(left: 20),
                                      ),
                                      validationBuilder: (context, selectedItems) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerRight,
                                            child: InkWell(
                                              onTap: () {
                                                controller.selectedCategories.clear();
                                                controller.selectedCategories.addAll(selectedItems);
                                                controller.myKey1.currentState?.popupOnValidate();
                                              },
                                              child: TranslatedText(
                                                "Done",
                                                style: TextStyle(
                                                  color: AppThemeData.secondary300,
                                                  fontFamily: AppThemeData.medium,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      itemBuilder: (context, item, isSelected, bool) {
                                        return ListTile(
                                          selectedColor: AppThemeData.secondary300,
                                          selected: isSelected,
                                          title: TranslatedText(
                                            item.title.toString(),
                                            style: TextStyle(
                                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                              fontFamily: AppThemeData.medium,
                                              fontSize: 18,
                                            ),
                                          ),
                                          onTap: () {
                                            controller.myKey1.currentState?.popupValidate([item]);
                                          },
                                        );
                                      },
                                    ),
                                    itemAsString: (VendorCategoryModel u) => u.title.toString().tr,
                                    selectedItems: controller.selectedCategories,
                                    onSaved: (data) {},
                                    onSelected: (data) {
                                      controller.selectedCategories.clear();
                                      controller.selectedCategories.addAll(data);
                                    },
                                  );
                                },
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TranslatedText("Services", style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
                              const SizedBox(
                                height: 5,
                              ),
                              ValueListenableBuilder(
                                  valueListenable: TranslationNotifier.refresh,
                                  builder: (_, __, ___) {
                                    return IgnorePointer(
                                      ignoring: Constant.userModel?.role == Constant.userRoleEmployee,
                                      child: MultiSelectDialogField(
                                        buttonText: Text("Select".tr),
                                        title: Text("Select".tr),
                                        confirmText: Text('Ok'.tr),
                                        cancelText: Text('Cancel'.tr),
                                        items: ['Good for Breakfast', 'Good for Lunch', 'Good for Dinner', 'Takes Reservations', 'Vegetarian Friendly', 'Live Music', 'Outdoor Seating', 'Free Wi-Fi']
                                            .map((e) => MultiSelectItem(e, e.tr))
                                            .toList(),
                                        listType: MultiSelectListType.CHIP,
                                        initialValue: controller.selectedService,
                                        decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.all(Radius.circular(6)),
                                            color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                            border: Border.all(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50)),
                                        onConfirm: (values) {
                                          controller.selectedService.value = values;
                                        },
                                      ),
                                    );
                                  }),
                            ],
                          ),
                          if (Constant.packagingChargeEnable == true)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: 10,
                                ),
                                TextFieldWidget(
                                  title: 'Packaging charge',
                                  controller: controller.packagingChargeAmountController.value,
                                  maxLine: 1,
                                  textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                  ],
                                  hintText: 'Enter Packaging charge',
                                ),
                              ],
                            ),
                          if (Constant.isSelfDeliveryFeature == true)
                            const SizedBox(
                              height: 10,
                            ),
                          if (Constant.isSelfDeliveryFeature == true)
                            Row(
                              children: [
                                Expanded(
                                  child: TranslatedText(
                                    "Self Delivery Service",
                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                  ),
                                ),
                                IgnorePointer(
                                  ignoring: Constant.userModel?.role == Constant.userRoleEmployee,
                                  child: Transform.scale(
                                    scale: 0.8,
                                    child: CupertinoSwitch(
                                      activeTrackColor: AppThemeData.secondary300,
                                      value: controller.isSelfDelivery.value,
                                      onChanged: (value) {
                                        controller.isSelfDelivery.value = value;
                                        controller.update();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TranslatedText(
                                  "Delivery Settings",
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                ),
                              ),
                              IgnorePointer(
                                ignoring: Constant.userModel?.role == Constant.userRoleEmployee,
                                child: Transform.scale(
                                  scale: 0.8,
                                  child: CupertinoSwitch(
                                    activeTrackColor: AppThemeData.secondary300,
                                    value: controller.isEnableDeliverySettings.value,
                                    onChanged: (value) {},
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextFieldWidget(
                            title: '${'Charges per'.tr} ${Constant.distanceType} ${'(distance)'.tr}',
                            controller: controller.chargePerKmController.value,
                            hintText: 'Enter charges',
                            enable: controller.isEnableDeliverySettings.value && Constant.userModel?.role != Constant.userRoleEmployee,
                            textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            ],
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: TranslatedText(
                                "${Constant.currencyModel!.symbol}",
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                              ),
                            ),
                          ),
                          TextFieldWidget(
                            title: 'Min Delivery Charges',
                            controller: controller.minDeliveryChargesController.value,
                            hintText: 'Enter Min Delivery Charges',
                            enable: controller.isEnableDeliverySettings.value && Constant.userModel?.role != Constant.userRoleEmployee,
                            textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            ],
                            prefix: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: TranslatedText(
                                "${Constant.currencyModel!.symbol}",
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                              ),
                            ),
                          ),
                          TextFieldWidget(
                            title: '${'Min Delivery Charges within'.tr} ${Constant.distanceType} ${'(distance)'.tr}',
                            controller: controller.minDeliveryChargesWithinKMController.value,
                            hintText: '${'Enter Min Delivery Charges within'.tr} ${Constant.distanceType} ${'(distance)'.tr}',
                            enable: controller.isEnableDeliverySettings.value && Constant.userModel?.role != Constant.userRoleEmployee,
                            textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
            bottomNavigationBar: (Constant.userModel?.role == 'employee')
                ? null
                : Container(
                    color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: RoundedButtonFill(
                        title: "Save Details",
                        height: 5.5,
                        color: AppThemeData.secondary300,
                        textColor: AppThemeData.grey50,
                        fontSizes: 16,
                        onPress: () async {
                          controller.saveDetails();
                        },
                      ),
                    ),
                  ),
          );
        });
  }

  Future buildBottomSheet(BuildContext context, AddRestaurantController controller) {
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
