import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/app/subscription_plan_screen/subscription_plan_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:flutter/material.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';

import 'package:restaurant/widget/translated_text.dart';

class AppNotAccessScreen extends StatelessWidget {
  const AppNotAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                child: SvgPicture.asset("assets/icons/ic_payment_card.svg"),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TranslatedText(
              "Access denied",
              style: TextStyle(
                color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
                fontFamily: AppThemeData.semiBold,
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Constant.showEmptyView(message: "Your current subscription plan doesn't include access to this app. Upgrade to get access now."),
            const SizedBox(
              height: 40,
            ),
            RoundedButtonFill(
              width: 60,
              title: "Upgrade Plan",
              color: AppThemeData.secondary300,
              textColor: AppThemeData.grey50,
              onPress: () async {
                Get.to(const SubscriptionPlanScreen());
              },
            ),
          ],
        ),
      ),
    ));
  }
}
