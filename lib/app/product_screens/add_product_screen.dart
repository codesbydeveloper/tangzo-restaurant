import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/controller/add_product_controller.dart';
import 'package:restaurant/models/AttributesModel.dart';
import 'package:restaurant/models/product_model.dart';
import 'package:restaurant/models/vendor_category_model.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/responsive.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/themes/text_field_widget.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/dynamic_traslator.dart';

import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/network_image_widget.dart';
import 'package:restaurant/widget/animated_border_container.dart';
import 'package:restaurant/widget/dimensions.dart';
import 'package:restaurant/widget/translated_text.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: AddProductController(),
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
                      controller.productModel.value.id == null ? "Add Product" : "Edit product",
                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
                    ),
                    actions: Constant.openAIStatus == false
                        ? null
                        : [
                            InkWell(
                              onTap: () {
                                buildBottomSheet(context, controller, "Ai");
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SvgPicture.asset(
                                  "assets/icons/hexa-ai.svg",
                                  width: 32,
                                ),
                              ),
                            ),
                          ],
                  ),
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              color: themeChange.getThem() ? AppThemeData.danger600 : AppThemeData.danger50,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TranslatedText(
                                "Product prices include a 15% admin commission. For instance, a \$100 product will cost \$115 for the customer. 15% will be applied automatically.",
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.danger200 : AppThemeData.danger400, fontSize: 14, fontFamily: AppThemeData.medium),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          DottedBorder(
                            options: RectDottedBorderOptions(),
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
                                          buildBottomSheet(context, controller, "product");
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
                                  height: 80,
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
                          SizedBox(
                            height: 10,
                          ),
                          Constant.openAIStatus == false
                              ? SizedBox()
                              : InkWell(
                                  onTap: () {
                                    if (controller.productTitleController.value.text.trim().isEmpty) {
                                      ShowToastDialog.showToast("Please enter product title to generate");
                                      return;
                                    }
                                    controller.generateTitleAndDescription();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: AppThemeData.primary300,
                                      ),
                                      TranslatedText(
                                        "Generate",
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300, fontFamily: AppThemeData.medium, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          AnimatedBorderContainer(
                            padding: controller.isTitleGenerated.value ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge) : EdgeInsets.zero,
                            isLoading: controller.isTitleGenerated.value,
                            color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
                            child: Column(
                              children: [
                                TextFieldWidget(
                                  title: 'Product Title',
                                  controller: controller.productTitleController.value,
                                  hintText: 'Enter product title',
                                ),
                                TextFieldWidget(
                                  title: 'Product Description',
                                  controller: controller.productDescriptionController.value,
                                  hintText: 'Enter short description here....',
                                  maxLine: 5,
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          SizedBox(
                            height: 5,
                          ),
                          Constant.openAIStatus == false
                              ? SizedBox()
                              : InkWell(
                                  onTap: () {
                                    if (controller.productTitleController.value.text.trim().isEmpty) {
                                      ShowToastDialog.showToast("Please enter product title to generate");
                                      return;
                                    }
                                    if (controller.productDescriptionController.value.text.trim().isEmpty) {
                                      ShowToastDialog.showToast("Please enter product description to generate");
                                      return;
                                    }
                                    controller.generateVariationData();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: AppThemeData.primary300,
                                      ),
                                      TranslatedText(
                                        "Generate",
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300, fontFamily: AppThemeData.medium, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          AnimatedBorderContainer(
                            padding: controller.generateVariationDataGenerated.value
                                ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge)
                                : EdgeInsets.zero,
                            isLoading: controller.generateVariationDataGenerated.value,
                            color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText("Product Categories",
                                        style: TextStyle(fontFamily: AppThemeData.semiBold, fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800)),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    DropdownButtonFormField<VendorCategoryModel>(
                                        hint: TranslatedText(
                                          'Select Product Categories',
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
                                        initialValue: controller.selectedProductCategory.value.id == null ? null : controller.selectedProductCategory.value,
                                        onChanged: (value) {
                                          controller.selectedProductCategory.value = value!;
                                          controller.update();
                                        },
                                        style: TextStyle(fontSize: 14, color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium),
                                        items: controller.vendorCategoryList.map((item) {
                                          return DropdownMenuItem<VendorCategoryModel>(
                                            value: item,
                                            child: TranslatedText(item.title.toString()),
                                          );
                                        }).toList()),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                                TranslatedText(
                                  "Attributes and Prices",
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TranslatedText(
                                      "Attributes",
                                      style: TextStyle(
                                        fontFamily: AppThemeData.semiBold,
                                        fontSize: 14,
                                        color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    DropdownSearch<AttributesModel>.multiSelection(
                                      items: (String s, LoadProps? data) => controller.attributesList,
                                      key: controller.myKey1,
                                      suffixProps: DropdownSuffixProps(
                                        dropdownButtonProps: DropdownButtonProps(
                                          focusColor: AppThemeData.secondary300,
                                          color: AppThemeData.grey800,
                                          iconClosed: const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: AppThemeData.grey800,
                                          ),
                                          iconOpened: const Icon(
                                            Icons.keyboard_arrow_up,
                                            color: AppThemeData.grey800,
                                          ),
                                        ),
                                      ),
                                      decoratorProps: DropDownDecoratorProps(
                                        decoration: InputDecoration(
                                            focusColor: AppThemeData.secondary300,
                                            suffixIcon: const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: AppThemeData.grey800,
                                            ),
                                            contentPadding: const EdgeInsets.only(left: 8, right: 8),
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
                                            filled: true,
                                            hintStyle: TextStyle(
                                              fontSize: 14,
                                              color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                              fontFamily: AppThemeData.medium,
                                            ),
                                            fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                            hintText: 'Select Attributes'),
                                      ),
                                      compareFn: (i1, i2) => i1.title == i2.title,
                                      popupProps: MultiSelectionPopupProps.menu(
                                        fit: FlexFit.tight,
                                        showSelectedItems: true,
                                        listViewProps: const ListViewProps(physics: BouncingScrollPhysics(), padding: EdgeInsets.only(left: 20)),
                                        itemBuilder: (context, item, isSelected, bool) {
                                          return ListTile(
                                            selectedColor: AppThemeData.secondary300,
                                            selected: isSelected,
                                            title: TranslatedText(
                                              item.title.toString(),
                                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                            ),
                                            onTap: () {
                                              controller.myKey1.currentState?.popupValidate([item]);
                                            },
                                          );
                                        },
                                      ),
                                      itemAsString: (AttributesModel u) => u.title.toString(),
                                      selectedItems: controller.selectedAttributesList,
                                      onSaved: (data) {},
                                      onSelected: (data) {
                                        if (controller.itemAttributes.value!.attributes != null) {
                                          controller.selectedAttributesList.clear();
                                          controller.itemAttributes.value!.attributes!.clear();
                                          controller.itemAttributes.value!.variants!.clear();
                                        } else {
                                          controller.itemAttributes.value = ItemAttribute(attributes: [], variants: []);
                                        }
                                        controller.selectedAttributesList.addAll(data);

                                        for (var element in controller.selectedAttributesList) {
                                          controller.addAttribute(element.id.toString());
                                        }
                                        setState(() {});
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    controller.itemAttributes.value!.attributes == null || controller.itemAttributes.value!.attributes!.isEmpty
                                        ? Container()
                                        : Container(
                                            decoration: ShapeDecoration(
                                              color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  TranslatedText(
                                                    "Attributes Value",
                                                    style: TextStyle(
                                                      color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                      fontFamily: AppThemeData.semiBold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  ListView.builder(
                                                    itemCount: controller.itemAttributes.value!.attributes!.length,
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemBuilder: (context, index) {
                                                      String title = "";
                                                      for (var element in controller.attributesList) {
                                                        if (controller.itemAttributes.value!.attributes![index].attributeId == element.id) {
                                                          title = element.title.toString();
                                                        }
                                                      }

                                                      return Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: TranslatedText(
                                                                    title,
                                                                    style: TextStyle(
                                                                      color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
                                                                      fontFamily: AppThemeData.medium,
                                                                      fontSize: 16,
                                                                    ),
                                                                  ),
                                                                ),
                                                                InkWell(
                                                                  splashColor: Colors.transparent,
                                                                  onTap: () {
                                                                    showDialog(
                                                                      context: context,
                                                                      builder: (BuildContext context) {
                                                                        return addAttributeValueDialog(
                                                                            controller, themeChange, index, controller.itemAttributes.value!.attributes![index].attributeId.toString());
                                                                      },
                                                                    );
                                                                  },
                                                                  child: Icon(
                                                                    Icons.add,
                                                                    color: AppThemeData.secondary300,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                            Wrap(
                                                              spacing: 4.0,
                                                              runSpacing: 4.0,
                                                              children: List.generate(
                                                                controller.itemAttributes.value!.attributes![index].attributeOptions!.length,
                                                                (i) {
                                                                  return InkWell(
                                                                      splashColor: Colors.transparent,
                                                                      onTap: () {
                                                                        controller.itemAttributes.value!.attributes![index].attributeOptions!.removeAt(i);

                                                                        List<List<dynamic>> listArary = [];
                                                                        for (int i = 0; i < controller.itemAttributes.value!.attributes!.length; i++) {
                                                                          if (controller.itemAttributes.value!.attributes![i].attributeOptions!.isNotEmpty) {
                                                                            listArary.add(controller.itemAttributes.value!.attributes![i].attributeOptions!);
                                                                          }
                                                                        }

                                                                        if (listArary.isNotEmpty) {
                                                                          List<Variants>? variantsTemp = [];
                                                                          List<dynamic> list = getCombination(listArary);
                                                                          for (var element in list) {
                                                                            bool productIsInList = controller.itemAttributes.value!.variants!.any((product) => product.variantSku == element);
                                                                            if (productIsInList) {
                                                                              Variants variant = controller.itemAttributes.value!.variants!.firstWhere((product) => product.variantSku == element);
                                                                              Variants variantsModel = Variants(
                                                                                  variantSku: variant.variantSku,
                                                                                  variantId: variant.variantId,
                                                                                  variantImage: variant.variantImage,
                                                                                  variantPrice: variant.variantPrice,
                                                                                  variantQuantity: variant.variantQuantity);
                                                                              variantsTemp.add(variantsModel);
                                                                            }
                                                                          }
                                                                          controller.itemAttributes.value!.variants!.clear();
                                                                          controller.itemAttributes.value!.variants!.addAll(variantsTemp);
                                                                        } else {
                                                                          controller.itemAttributes.value!.variants!.clear();
                                                                        }
                                                                        controller.update();
                                                                        setState(() {});
                                                                      },
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                                                        child: _buildChip(themeChange, controller.itemAttributes.value!.attributes![index].attributeOptions![i], index, i),
                                                                      ));
                                                                },
                                                              ).toList(),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                  SingleChildScrollView(
                                                    scrollDirection: Axis.horizontal,
                                                    child: controller.itemAttributes.value!.variants!.isEmpty
                                                        ? const SizedBox()
                                                        : ClipRRect(
                                                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                                                            child: DataTable(
                                                                horizontalMargin: 20,
                                                                columnSpacing: 30,
                                                                dataRowMaxHeight: 70,
                                                                border: TableBorder.all(
                                                                  color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
                                                                  borderRadius: BorderRadius.circular(12),
                                                                ),
                                                                headingRowColor: WidgetStateColor.resolveWith((states) => themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface),
                                                                columns: [
                                                                  DataColumn(
                                                                    label: SizedBox(
                                                                      width: Responsive.width(20, context),
                                                                      child: TranslatedText(
                                                                        "Variant",
                                                                        style: TextStyle(
                                                                          fontFamily: AppThemeData.medium,
                                                                          fontSize: 14,
                                                                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: SizedBox(
                                                                      width: Responsive.width(20, context),
                                                                      child: TranslatedText(
                                                                        "Price",
                                                                        style: TextStyle(
                                                                          fontFamily: AppThemeData.medium,
                                                                          fontSize: 14,
                                                                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: SizedBox(
                                                                      width: Responsive.width(20, context),
                                                                      child: TranslatedText(
                                                                        "Quantity",
                                                                        style: TextStyle(
                                                                          fontFamily: AppThemeData.medium,
                                                                          fontSize: 14,
                                                                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                    label: SizedBox(
                                                                      width: Responsive.width(20, context),
                                                                      child: TranslatedText(
                                                                        "Image",
                                                                        style: TextStyle(
                                                                          fontFamily: AppThemeData.medium,
                                                                          fontSize: 14,
                                                                          color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                                rows: controller.itemAttributes.value!.variants!
                                                                    .map(
                                                                      (e) => DataRow(
                                                                        cells: [
                                                                          DataCell(
                                                                            TranslatedText(
                                                                              e.variantSku.toString(),
                                                                              style: TextStyle(
                                                                                fontFamily: AppThemeData.semiBold,
                                                                                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          DataCell(
                                                                            TextFormField(
                                                                              initialValue: e.variantPrice,
                                                                              textCapitalization: TextCapitalization.sentences,
                                                                              textInputAction: TextInputAction.done,
                                                                              inputFormatters: [
                                                                                FilteringTextInputFormatter.allow(RegExp('[0-9-.]')),
                                                                              ],
                                                                              keyboardType: TextInputType.text,
                                                                              onChanged: (value) {
                                                                                e.variantPrice = value;
                                                                              },
                                                                              style: TextStyle(
                                                                                  fontSize: 14,
                                                                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                                  fontFamily: AppThemeData.medium),
                                                                              decoration: InputDecoration(
                                                                                errorStyle: const TextStyle(color: Colors.red),
                                                                                filled: true,
                                                                                enabled: true,
                                                                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                                                                fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                                                                disabledBorder: UnderlineInputBorder(
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                  borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                  borderSide:
                                                                                      BorderSide(color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300, width: 1),
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
                                                                                hintText: "Price".tr,
                                                                                prefix: Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                                                  child: TranslatedText(
                                                                                    "${Constant.currencyModel!.symbol}",
                                                                                    style: TextStyle(
                                                                                        color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                                                                                        fontFamily: AppThemeData.semiBold,
                                                                                        fontSize: 18),
                                                                                  ),
                                                                                ),
                                                                                hintStyle: TextStyle(
                                                                                  fontSize: 14,
                                                                                  color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                                                                                  fontFamily: AppThemeData.regular,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          DataCell(
                                                                            TextFormField(
                                                                              initialValue: e.variantQuantity,
                                                                              textInputAction: TextInputAction.done,
                                                                              inputFormatters: [
                                                                                FilteringTextInputFormatter.allow(RegExp('[0-9-.]')),
                                                                              ],
                                                                              keyboardType: TextInputType.text,
                                                                              onChanged: (value) {
                                                                                e.variantQuantity = value;
                                                                              },
                                                                              style: TextStyle(
                                                                                  fontSize: 14,
                                                                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                                                  fontFamily: AppThemeData.medium),
                                                                              decoration: InputDecoration(
                                                                                errorStyle: const TextStyle(color: Colors.red),
                                                                                filled: true,
                                                                                enabled: true,
                                                                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                                                                                fillColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                                                                disabledBorder: UnderlineInputBorder(
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                  borderSide: BorderSide(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, width: 1),
                                                                                ),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                  borderSide:
                                                                                      BorderSide(color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300, width: 1),
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
                                                                                hintText: "Quantity".tr,
                                                                                hintStyle: TextStyle(
                                                                                  fontSize: 14,
                                                                                  color: themeChange.getThem() ? AppThemeData.grey600 : AppThemeData.grey400,
                                                                                  fontFamily: AppThemeData.regular,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          DataCell(e.variantImage != null && e.variantImage!.isNotEmpty
                                                                              ? InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  onTap: () {
                                                                                    int index = controller.itemAttributes.value!.variants!.indexWhere((element) => element.variantId == e.variantId);
                                                                                    onCameraClick(context, index, controller);
                                                                                  },
                                                                                  child: ClipRRect(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                    child: NetworkImageWidget(
                                                                                      height: 50,
                                                                                      width: 60,
                                                                                      fit: BoxFit.cover,
                                                                                      imageUrl: e.variantImage.toString(),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : InkWell(
                                                                                  splashColor: Colors.transparent,
                                                                                  onTap: () {
                                                                                    int index = controller.itemAttributes.value!.variants!.indexWhere((element) => element.variantId == e.variantId);
                                                                                    onCameraClick(context, index, controller);
                                                                                  },
                                                                                  child: SvgPicture.asset("assets/icons/ic_folder_upload.svg"))),
                                                                        ],
                                                                      ),
                                                                    )
                                                                    .toList()),
                                                          ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFieldWidget(
                                  title: 'Regular Price',
                                  controller: controller.regularPriceController.value,
                                  hintText: 'Enter Regular Price',
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                  ],
                                  textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                  prefix: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: TranslatedText(
                                      "${Constant.currencyModel!.symbol}",
                                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextFieldWidget(
                                  title: 'Discounted Price',
                                  controller: controller.discountedPriceController.value,
                                  hintText: 'Enter Discounted Price',
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                  ],
                                  textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                  prefix: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    child: TranslatedText(
                                      "${Constant.currencyModel!.symbol}",
                                      style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.semiBold, fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              TranslatedText(
                                "Your item Price will be display like this. ",
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800, fontFamily: AppThemeData.medium, fontSize: 12),
                              ),
                              Row(
                                children: [
                                  Text(
                                    (controller.discountPrice.value == 0.0 ? Constant.amountShow(amount: "0.0") : Constant.amountShow(amount: controller.discountPrice.value.toString())),
                                    style: TextStyle(color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300, fontFamily: AppThemeData.medium, fontSize: 12),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    Constant.amountShow(amount: controller.regularPrice.value.toString()),
                                    style:
                                        TextStyle(color: themeChange.getThem() ? AppThemeData.grey500 : AppThemeData.grey400, fontFamily: AppThemeData.medium, decoration: TextDecoration.lineThrough),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFieldWidget(
                            title: 'Quantity',
                            controller: controller.productQuantityController.value,
                            hintText: 'Enter Quantity',
                            textInputAction: TextInputAction.done,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp('[0-9-.]')),
                            ],
                            textInputType: TextInputType.text,
                          ),
                          TranslatedText(
                            "-1 to your product quantity is unlimited",
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.danger300 : AppThemeData.danger300, fontFamily: AppThemeData.medium, fontSize: 14),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Divider(),
                          Constant.openAIStatus == false
                              ? SizedBox()
                              : InkWell(
                                  onTap: () {
                                    if (controller.productTitleController.value.text.trim().isEmpty) {
                                      ShowToastDialog.showToast("Please enter product title to generate");
                                      return;
                                    }
                                    if (controller.productDescriptionController.value.text.trim().isEmpty) {
                                      ShowToastDialog.showToast("Please enter product description to generate");
                                      return;
                                    }
                                    controller.generateIngredients();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: AppThemeData.primary300,
                                      ),
                                      TranslatedText(
                                        "Generate",
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300, fontFamily: AppThemeData.medium, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          AnimatedBorderContainer(
                            padding: controller.generateIngredientsGenerated.value
                                ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge)
                                : EdgeInsets.zero,
                            isLoading: controller.generateIngredientsGenerated.value,
                            color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TranslatedText(
                                  "About Cal., Grams, prot.& Fats",
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFieldWidget(
                                        title: 'Calories',
                                        controller: controller.caloriesController.value,
                                        hintText: 'Enter Calories',
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                        ],
                                        textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: TextFieldWidget(
                                        title: 'Grams',
                                        controller: controller.gramsController.value,
                                        hintText: 'Enter Grams',
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                        ],
                                        textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
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
                                      child: TextFieldWidget(
                                        title: 'Protein',
                                        controller: controller.proteinController.value,
                                        hintText: 'Enter Protein',
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                        ],
                                        textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: TextFieldWidget(
                                        title: 'Fats',
                                        controller: controller.fatsController.value,
                                        hintText: 'Enter Fats',
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                        ],
                                        textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          TranslatedText(
                            "Product Type and Takeaway options",
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TranslatedText(
                                        "Pure veg.",
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: CupertinoSwitch(
                                        activeTrackColor: AppThemeData.secondary300,
                                        value: controller.isPureVeg.value,
                                        onChanged: (value) {
                                          if (controller.isNonVeg.value == true) {
                                            controller.isPureVeg.value = value;
                                          }
                                          if (controller.isPureVeg.value == true) {
                                            controller.isNonVeg.value = false;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TranslatedText(
                                        "Non veg.",
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.8,
                                      child: CupertinoSwitch(
                                        activeTrackColor: AppThemeData.secondary300,
                                        value: controller.isNonVeg.value,
                                        onChanged: (value) {
                                          if (controller.isPureVeg.value == true) {
                                            controller.isNonVeg.value = value;
                                          }

                                          if (controller.isNonVeg.value == true) {
                                            controller.isPureVeg.value = false;
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TranslatedText(
                                  "Enable Takeaway option",
                                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                                ),
                              ),
                              Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  activeTrackColor: AppThemeData.secondary300,
                                  value: controller.takeAway.value,
                                  onChanged: (value) {
                                    controller.takeAway.value = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Divider(),
                          TranslatedText(
                            "Specifications and Addons",
                            style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Constant.openAIStatus == false
                              ? SizedBox()
                              : InkWell(
                                  onTap: () {
                                    if (controller.productTitleController.value.text.trim().isEmpty) {
                                      ShowToastDialog.showToast("Please enter product title to generate");
                                      return;
                                    }
                                    if (controller.productDescriptionController.value.text.trim().isEmpty) {
                                      ShowToastDialog.showToast("Please enter product description to generate");
                                      return;
                                    }
                                    controller.generateSpecification();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: AppThemeData.primary300,
                                      ),
                                      TranslatedText(
                                        "Generate",
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300, fontFamily: AppThemeData.medium, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          AnimatedBorderContainer(
                            padding: controller.generateSpecificationGenerated.value
                                ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge)
                                : EdgeInsets.zero,
                            isLoading: controller.generateSpecificationGenerated.value,
                            color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TranslatedText(
                                        "Specifications",
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 16),
                                      ),
                                    ),
                                    InkWell(
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          controller.specificationList.add(ProductSpecificationModel(lable: '', value: ''));
                                        },
                                        child: SvgPicture.asset("assets/icons/ic_add_one.svg"))
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  itemCount: controller.specificationList.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final item = controller.specificationList[index];
                                    return Padding(
                                      key: ValueKey(item), // 👈 ensures correct rebuild
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFieldWidget(
                                              key: ValueKey('label_$index'),
                                              // 👈 important
                                              initialValue: item.lable,
                                              title: 'Title',
                                              hintText: 'Enter Title',
                                              onchange: (value) {
                                                controller.specificationList[index].lable = value;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: TextFieldWidget(
                                              key: ValueKey('value_$index'),
                                              // 👈 important
                                              initialValue: item.value,
                                              title: 'Value',
                                              hintText: 'Enter Value',
                                              onchange: (value) {
                                                controller.specificationList[index].value = value;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                              onTap: () {
                                                controller.specificationList.removeAt(index);
                                              },
                                              child: Icon(Icons.remove_circle, color: AppThemeData.danger300)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(),
                          Constant.openAIStatus == false
                              ? SizedBox()
                              : InkWell(
                                  onTap: () {
                                    if (controller.productTitleController.value.text.trim().isEmpty) {
                                      ShowToastDialog.showToast("Please enter product title to generate");
                                      return;
                                    }
                                    if (controller.productDescriptionController.value.text.trim().isEmpty) {
                                      ShowToastDialog.showToast("Please enter product description to generate");
                                      return;
                                    }
                                    controller.generateAddOns();
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: AppThemeData.primary300,
                                      ),
                                      TranslatedText(
                                        "Generate",
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.primary300 : AppThemeData.primary300, fontFamily: AppThemeData.medium, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          AnimatedBorderContainer(
                            padding:
                                controller.generateAddOnsGenerated.value ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeLarge) : EdgeInsets.zero,
                            isLoading: controller.generateAddOnsGenerated.value,
                            color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: TranslatedText(
                                        "Addons",
                                        style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 16),
                                      ),
                                    ),
                                    InkWell(
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          controller.addonsList.add(ProductSpecificationModel(lable: '', value: ''));
                                        },
                                        child: SvgPicture.asset("assets/icons/ic_add_one.svg"))
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: controller.addonsList.length,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final addon = controller.addonsList[index];
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: TextFieldWidget(
                                              key: ValueKey('addon_label_$index'),
                                              // 👈 unique key per textfield
                                              title: 'Title',
                                              hintText: 'Enter Title',
                                              initialValue: addon.lable,
                                              onchange: (value) {
                                                controller.addonsList[index].lable = value;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: TextFieldWidget(
                                              key: ValueKey('addon_value_$index'),
                                              // 👈 unique key per textfield
                                              title: 'Price',
                                              hintText: 'Enter Price',
                                              initialValue: addon.value,
                                              prefix: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                                child: TranslatedText(
                                                  "${Constant.currencyModel!.symbol}",
                                                  style: TextStyle(
                                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                    fontFamily: AppThemeData.semiBold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                              textInputAction: TextInputAction.done,
                                              inputFormatters: [
                                                FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                                              ],
                                              textInputType: const TextInputType.numberWithOptions(signed: true, decimal: true),
                                              onchange: (value) {
                                                controller.addonsList[index].value = value;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                              onTap: () {
                                                print("Remove addon at index: $index");
                                                controller.addonsList.removeAt(index);
                                              },
                                              child: Icon(Icons.remove_circle, color: AppThemeData.danger300)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 10,
                          ),
                          if (controller.taxList.isNotEmpty && Constant.taxScope == 'product')
                            TranslatedText(
                              'Assign Tax',
                              style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.medium, fontSize: 18),
                            ),
                          if (controller.taxList.isNotEmpty && Constant.taxScope == 'product')
                            const SizedBox(
                              height: 10,
                            ),
                          if (controller.taxList.isNotEmpty && Constant.taxScope == 'product')
                            Obx(() => ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: controller.taxList.length,
                                  itemBuilder: (context, index) {
                                    final tax = controller.taxList[index];
                                    return CheckboxListTile(
                                      value: tax.isSelected,
                                      contentPadding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (value) {
                                        controller.toggleSelection(index, value!);
                                      },
                                      title: TranslatedText(
                                        "${tax.title} (${tax.type == "fix" ? Constant.amountShow(amount: tax.tax) : "${tax.tax}%"})",
                                      ),
                                    );
                                  },
                                )),

                          /// APPLY BUTTON
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
                          // if ((Constant.isSubscriptionModelApplied == true || Constant.adminCommission?.isEnabled == true) &&
                          //     Constant.userModel?.subscriptionPlan?.itemLimit != '-1' &&
                          //     int.parse(Constant.userModel?.subscriptionPlan?.itemLimit != null && Constant.userModel?.subscriptionPlan?.itemLimit.toString() != "null"
                          //             ? "${Constant.userModel?.subscriptionPlan?.itemLimit}"
                          //             ? "${Constant.userModel?.subscriptionPlan?.itemLimit}"
                          //             : '0') <=
                          //         controller.productList.length) {
                          //   ShowToastDialog.showToast("Your current subscription plan has reached its maximum product limit. Upgrade now to add more products.");
                          //   return;
                          // }

                          if (controller.itemAttributes.value != null) {
                            if (controller.itemAttributes.value!.attributes != null && controller.itemAttributes.value!.attributes!.isNotEmpty) {
                              for (var element in controller.itemAttributes.value!.attributes!) {
                                if (element.attributeOptions!.isEmpty) {
                                  ShowToastDialog.showToast(
                                      "${"Please add a attribute".tr} (${controller.selectedAttributesList.where((p0) => p0.id == element.attributeId).first.title}) ${"value".tr}");
                                  return;
                                }
                              }
                            }

                            if (controller.itemAttributes.value!.variants != null && controller.itemAttributes.value!.variants!.isNotEmpty) {
                              for (var element in controller.itemAttributes.value!.variants!) {
                                if (double.parse(element.variantPrice!.toString()) == 0) {
                                  ShowToastDialog.showToast("Please enter a valid variant price");
                                  return;
                                }
                              }
                            }
                          }

                          print("==> ${controller.itemAttributes.value!.toJson()}");

                          controller.saveDetails();
                          // if (controller.itemAttributes.value != null && controller.itemAttributes.value!.variants!.isNotEmpty) {
                          //   for (var i = 0; i < controller.itemAttributes.value!.variants!.length; i++) {
                          //     if (controller.itemAttributes.value!.variants![i].variantPrice.toString() != "0") {
                          //       // ShowToastDialog.showToast("Please enter attribute amount.");
                          //       if (i == controller.itemAttributes.value!.variants!.length - 1) {
                          //
                          //       }
                          //     } else {
                          //       ShowToastDialog.showToast("Please enter Variant amount");
                          //       break;
                          //     }
                          //   }
                          // } else {
                          //   controller.saveDetails();
                          // }
                        },
                      ),
                    ),
                  ),
                );
        });
  }

  Dialog addAttributeValueDialog(AddProductController controller, themeChange, int index, String attributeId) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.all(10),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: SizedBox(
          width: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFieldWidget(
                title: 'Add Attribute Value',
                controller: controller.attributesValueController.value,
                hintText: 'Add Attribute Value',
              ),
              RoundedButtonFill(
                title: "Add",
                color: AppThemeData.secondary300,
                textColor: AppThemeData.grey50,
                onPress: () async {
                  if (controller.attributesValueController.value.text.isEmpty) {
                    ShowToastDialog.showToast("Please enter attribute value");
                  } else {
                    Get.back();
                    controller.itemAttributes.value!.attributes![index].attributeOptions!.add(controller.attributesValueController.value.text);

                    List<List<dynamic>> listArary = [];
                    for (int i = 0; i < controller.itemAttributes.value!.attributes!.length; i++) {
                      if (controller.itemAttributes.value!.attributes![i].attributeOptions!.isNotEmpty) {
                        listArary.add(controller.itemAttributes.value!.attributes![i].attributeOptions!);
                      }
                    }

                    List<dynamic> list = getCombination(listArary);

                    for (var element in list) {
                      bool productIsInList = controller.itemAttributes.value!.variants!.any((product) => product.variantSku == element);
                      if (productIsInList) {
                      } else {
                        if (controller.itemAttributes.value!.attributes![index].attributeOptions!.length == 1) {
                          controller.itemAttributes.value!.variants!.clear();
                          Variants variantsModel = Variants(variantSku: element, variantId: Constant.getUuid(), variantImage: "", variantPrice: "0", variantQuantity: "-1");
                          controller.itemAttributes.value!.variants!.add(variantsModel);
                        } else {
                          Variants variantsModel = Variants(variantSku: element, variantId: Constant.getUuid(), variantImage: "", variantPrice: "0", variantQuantity: "-1");
                          controller.itemAttributes.value!.variants!.add(variantsModel);
                        }
                      }
                    }
                    setState(() {});
                    controller.attributesValueController.value.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future buildBottomSheet(BuildContext context, AddProductController controller, String type) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          final themeChange = Provider.of<DarkThemeProvider>(context);
          return StatefulBuilder(builder: (context, setState) {
            return SizedBox(
              height: Responsive.height(type == "Ai" ? 50 : 22, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  type == "Ai"
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 10,
                              ),
                              SvgPicture.asset(
                                "assets/icons/ai_assistant_ic.svg",
                                height: 90,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TranslatedText(
                                "Hi there,",
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600, fontFamily: AppThemeData.medium, fontSize: 16),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TranslatedText(
                                "I am here to help you,",
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900, fontFamily: AppThemeData.bold, fontSize: 22),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TranslatedText(
                                "I’m your personal AI assistant for this task. Choose how you’d like to give me instructions to generate your product’s AI data.,",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600, fontFamily: AppThemeData.regular, fontSize: 14),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              RoundedButtonFill(
                                title: "From Camera",
                                height: 5.5,
                                color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                textColor: AppThemeData.grey50,
                                fontSizes: 16,
                                onPress: () {
                                  controller.pickFileForAI(source: ImageSource.camera);
                                },
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              RoundedButtonFill(
                                title: "From Gallery",
                                height: 5.5,
                                color: themeChange.getThem() ? AppThemeData.secondary300 : AppThemeData.secondary300,
                                textColor: AppThemeData.grey50,
                                fontSizes: 16,
                                onPress: () {
                                  controller.pickFileForAI(source: ImageSource.gallery);
                                },
                              ),
                            ],
                          ),
                        )
                      : Column(
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
                                          onPressed: () => type == "Ai" ? controller.pickFileForAI(source: ImageSource.camera) : controller.pickFile(source: ImageSource.camera),
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
                                          onPressed: () => type == "Ai" ? controller.pickFileForAI(source: ImageSource.camera) : controller.pickFile(source: ImageSource.gallery),
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
                ],
              ),
            );
          });
        });
  }

  Widget _buildChip(themeChange, String label, int attributesIndex, int attributesOptionIndex) {
    return Container(
      decoration: ShapeDecoration(
        color: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
          borderRadius: BorderRadius.circular(120),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TranslatedText(
              label,
              style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700, fontFamily: AppThemeData.semiBold, fontSize: 14),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.clear,
              color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  List<dynamic> getCombination(List<List<dynamic>> listArray) {
    if (listArray.length == 1) {
      return listArray[0];
    } else {
      List<dynamic> result = [];
      var allCasesOfRest = getCombination(listArray.sublist(1));
      for (var i = 0; i < allCasesOfRest.length; i++) {
        for (var j = 0; j < listArray[0].length; j++) {
          result.add(listArray[0][j] + '-' + allCasesOfRest[i]);
        }
      }
      return result;
    }
  }

  void onCameraClick(BuildContext context, int index, AddProductController controller) {
    final action = CupertinoActionSheet(
      message: TranslatedText(
        'Upload image',
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          isDefaultAction: false,
          onPressed: () async {
            Get.back();
            XFile? singleImage = await ImagePicker().pickImage(source: ImageSource.gallery);
            if (singleImage != null) {
              ShowToastDialog.showLoader("Image Upload...");

              String image = await FireStoreUtils.uploadUserImageToFireStorage(File(singleImage.path), controller.itemAttributes.value!.variants![index].variantId.toString());
              ShowToastDialog.closeLoader();
              controller.itemAttributes.value!.variants![index].variantImage = image;
              setState(() {});
            }
          },
          child: TranslatedText('Choose image from gallery'),
        ),
        CupertinoActionSheetAction(
          isDestructiveAction: false,
          onPressed: () async {
            Get.back();
            final XFile? singleImage = await ImagePicker().pickImage(source: ImageSource.camera);
            if (singleImage != null) {
              ShowToastDialog.showLoader("Image Upload...");

              String image = await FireStoreUtils.uploadUserImageToFireStorage(File(singleImage.path), controller.itemAttributes.value!.variants![index].variantId.toString());
              ShowToastDialog.closeLoader();
              controller.itemAttributes.value!.variants![index].variantImage = image;
              setState(() {});
            }
          },
          child: TranslatedText('Take a picture'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: TranslatedText(
          'Cancel',
        ),
        onPressed: () {
          Get.back();
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }
}
