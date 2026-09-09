import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/widget/translated_text.dart';

class SelectPaymentScreen extends StatelessWidget {
  const SelectPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return Scaffold(
      backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
      appBar: AppBar(
        backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        centerTitle: false,
        titleSpacing: 0,
        title: TranslatedText(
          "Payment Option",
          textAlign: TextAlign.start,
          style: TextStyle(
            fontFamily: AppThemeData.medium,
            fontSize: 16,
            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: TranslatedText(
            'Only the free plan is available. Paid subscriptions have been removed.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppThemeData.regular,
              fontSize: 16,
              color: themeChange.getThem() ? AppThemeData.grey200 : AppThemeData.grey700,
            ),
          ),
        ),
      ),
    );
  }
}
