import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/app/terms_and_condition/terms_and_condition_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/service/terms_acceptance_service.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/translation_notifier.dart';
import 'package:restaurant/utils/vendor_navigation.dart';
import 'package:restaurant/widget/translated_text.dart';

class AcceptTermsScreen extends StatefulWidget {
  const AcceptTermsScreen({super.key});

  @override
  State<AcceptTermsScreen> createState() => _AcceptTermsScreenState();
}

class _AcceptTermsScreenState extends State<AcceptTermsScreen> {
  bool _isSubmitting = false;

  Future<void> _acceptTerms() async {
    if (_isSubmitting) return;
    final user = Constant.userModel;
    if (user == null) {
      ShowToastDialog.showToast('Unable to load your account. Please login again.');
      return;
    }

    setState(() => _isSubmitting = true);
    ShowToastDialog.showLoader('Please wait');
    try {
      final pdfFile = await TermsAcceptanceService.generateTermsPdf(user: user);
      try {
        await TermsAcceptanceService.sendAcceptanceEmails(user: user, pdfFile: pdfFile);
      } catch (e) {
        debugPrint('Terms acceptance email failed: $e');
      }

      user.isTermsAccepted = true;
      user.termsAcceptedAt = Timestamp.now();
      await FireStoreUtils.updateUser(user);
      Constant.userModel = user;

      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast('Terms & Conditions accepted.');
      VendorNavigation.goAfterTermsAccepted(user);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast(e.toString());
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: themeChange.getThem() ? AppThemeData.surfaceDark : AppThemeData.surface,
        appBar: AppBar(
          backgroundColor: themeChange.getThem() ? AppThemeData.grey900 : AppThemeData.grey50,
          centerTitle: false,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: TranslatedText(
            'Terms & Conditions',
            style: TextStyle(
              color: themeChange.getThem() ? AppThemeData.grey100 : AppThemeData.grey800,
              fontFamily: AppThemeData.bold,
              fontSize: 18,
            ),
          ),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: themeChange.getThem() ? AppThemeData.grey700 : AppThemeData.grey200,
              height: 4.0,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: ValueListenableBuilder(
                    valueListenable: TranslationNotifier.refresh,
                    builder: (_, __, ___) {
                      return Html(
                        shrinkWrap: true,
                        data: cleanHtml(Constant.termsAndConditions.tr),
                        style: {
                          "body": Style(
                            margin: Margins.zero,
                            padding: HtmlPaddings.zero,
                            color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900,
                            fontSize: FontSize(14),
                            fontFamily: AppThemeData.medium,
                          ),
                          "p": Style(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
                          "li": Style(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
                          "h1": Style(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
                          "h2": Style(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
                          "h3": Style(color: themeChange.getThem() ? AppThemeData.grey50 : AppThemeData.grey900),
                          "a": Style(color: AppThemeData.primary300),
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TranslatedText(
                'You must accept the Terms & Conditions to continue using Tangzo Restaurant.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: AppThemeData.medium,
                  color: themeChange.getThem() ? AppThemeData.grey300 : AppThemeData.grey600,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: RoundedButtonFill(
              title: _isSubmitting ? 'Please wait' : 'Accept',
              color: AppThemeData.secondary300,
              textColor: AppThemeData.grey50,
              onPress: _isSubmitting ? () {} : _acceptTerms,
            ),
          ),
        ),
      ),
    );
  }
}
