import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/controller/subscription_history_controller.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';

import 'package:restaurant/utils/network_image_widget.dart';
import 'package:restaurant/widget/translated_text.dart';

class SubscriptionHistoryScreen extends StatelessWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX(
        init: SubscriptionHistoryController(),
        builder: (controller) {
          return Scaffold(
              appBar: AppBar(
                title: TranslatedText(
                  "Purchase History",
                  style: TextStyle(color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50, fontSize: 18, fontFamily: AppThemeData.medium),
                ),
                backgroundColor: AppThemeData.secondary300,
                centerTitle: false,
                titleSpacing: 0,
                iconTheme: IconThemeData(color: AppThemeData.grey50, size: 20),
              ),
              body: controller.isLoading.value
                  ? Constant.loader()
                  : controller.subscriptionHistoryList.isEmpty
                      ? Constant.showEmptyView(message: "Purchase History Not found")
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.subscriptionHistoryList.length,
                          itemBuilder: (context, index) {
                            final subscriptionHistoryModel = controller.subscriptionHistoryList[index];
                            return Container(
                              margin: const EdgeInsets.only(left: 16, right: 16, top: 20),
                              decoration: ShapeDecoration(
                                color: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadows: const [
                                  BoxShadow(
                                    color: Color(0x07000000),
                                    blurRadius: 20,
                                    offset: Offset(0, 0),
                                    spreadRadius: 0,
                                  )
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              NetworkImageWidget(
                                                imageUrl: subscriptionHistoryModel.subscriptionPlan?.image ?? '',
                                                fit: BoxFit.cover,
                                                width: 45,
                                                height: 45,
                                              ),
                                              const SizedBox(width: 10),
                                              TranslatedText(
                                                subscriptionHistoryModel.subscriptionPlan?.name ?? '',
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: AppThemeData.medium,
                                                  fontSize: 16,
                                                  color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (index == 0)
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Icon(
                                                  Icons.check_circle_outlined,
                                                  color: AppThemeData.success400,
                                                ),
                                                SizedBox(width: 5),
                                                TranslatedText(
                                                  'Active',
                                                  textAlign: TextAlign.start,
                                                  style: TextStyle(
                                                    fontFamily: AppThemeData.medium,
                                                    fontSize: 16,
                                                    color: AppThemeData.success400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Divider(color: themeChange.getThem() ? AppThemeData.grey800 : AppThemeData.grey100),
                                    const SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              TranslatedText('Validity',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.regular,
                                                    color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey900,
                                                  )),
                                              TranslatedText(
                                                  subscriptionHistoryModel.subscriptionPlan?.expiryDay == '-1' ? "Unlimited" : '${subscriptionHistoryModel.subscriptionPlan?.expiryDay ?? '0'}  Days',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.medium,
                                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey800,
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              TranslatedText('Price',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.regular,
                                                    color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey900,
                                                  )),
                                              Text(Constant.amountShow(amount: subscriptionHistoryModel.subscriptionPlan?.price ?? '0'),
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.medium,
                                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey800,
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              TranslatedText('Payment Type',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.regular,
                                                    color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey900,
                                                  )),
                                              TranslatedText((subscriptionHistoryModel.paymentType ?? '').capitalizeString(),
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.medium,
                                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey800,
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              TranslatedText('Purchase Date',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.regular,
                                                    color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey900,
                                                  )),
                                              TranslatedText(Constant.timestampToDateTime(subscriptionHistoryModel.createdAt!),
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.medium,
                                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey800,
                                                  )),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              TranslatedText('Expiry Date',
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.regular,
                                                    color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey900,
                                                  )),
                                              TranslatedText(subscriptionHistoryModel.expiryDate == null ? "Unlimited" : Constant.timestampToDateTime(subscriptionHistoryModel.expiryDate!),
                                                  textAlign: TextAlign.end,
                                                  maxLines: 2,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: AppThemeData.medium,
                                                    color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey800,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }));
        });
  }
}
