import 'package:cloud_firestore/cloud_firestore.dart' hide Constant;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/constant/food_safety_agreement.dart';
import 'package:restaurant/constant/show_toast_dialog.dart';
import 'package:restaurant/service/terms_acceptance_service.dart';
import 'package:restaurant/themes/app_them_data.dart';
import 'package:restaurant/themes/round_button_fill.dart';
import 'package:restaurant/utils/dark_theme_provider.dart';
import 'package:restaurant/utils/fire_store_utils.dart';
import 'package:restaurant/utils/vendor_navigation.dart';
import 'package:restaurant/widget/translated_text.dart';

class AcceptTermsScreen extends StatefulWidget {
  const AcceptTermsScreen({super.key});

  @override
  State<AcceptTermsScreen> createState() => _AcceptTermsScreenState();
}

class _AcceptTermsScreenState extends State<AcceptTermsScreen> {
  bool _isSubmitting = false;
  bool _hasAgreed = false;

  Future<void> _acceptTerms() async {
    if (_isSubmitting) return;
    if (!_hasAgreed) {
      ShowToastDialog.showToast('Please confirm that you agree to this Agreement.');
      return;
    }

    final user = Constant.userModel;
    if (user == null) {
      ShowToastDialog.showToast('Unable to load your account. Please login again.');
      return;
    }

    setState(() => _isSubmitting = true);
    ShowToastDialog.showLoader('Please wait');
    try {
      final pdfFile = await TermsAcceptanceService.getAgreementPdfFile();
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
      ShowToastDialog.showToast('Agreement accepted.');
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
    final isDark = themeChange.getThem();
    final textColor = isDark ? AppThemeData.grey50 : AppThemeData.grey900;
    final mutedColor = isDark ? AppThemeData.grey300 : AppThemeData.grey600;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.surface,
        appBar: AppBar(
          backgroundColor: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
          centerTitle: false,
          automaticallyImplyLeading: false,
          titleSpacing: 16,
          title: TranslatedText(
            'Food Safety Agreement',
            style: TextStyle(
              color: isDark ? AppThemeData.grey100 : AppThemeData.grey800,
              fontFamily: AppThemeData.bold,
              fontSize: 18,
            ),
          ),
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
              height: 4.0,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppThemeData.grey900 : AppThemeData.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppThemeData.grey700 : AppThemeData.grey200,
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      FoodSafetyAgreement.displayText.trim(),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13.5,
                        height: 1.45,
                        fontFamily: AppThemeData.medium,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _isSubmitting
                    ? null
                    : () => setState(() => _hasAgreed = !_hasAgreed),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _hasAgreed,
                      activeColor: AppThemeData.secondary300,
                      onChanged: _isSubmitting
                          ? null
                          : (value) => setState(() => _hasAgreed = value ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'I Agree — I have read and unconditionally accept this Food Safety, FSSAI Compliance, Indemnity & Delivery Responsibility Agreement (${FoodSafetyAgreement.ref}).',
                          style: TextStyle(
                            fontSize: 13,
                            fontFamily: AppThemeData.medium,
                            color: mutedColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              TranslatedText(
                'You must accept this Agreement to continue using Tangzo Restaurant.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: AppThemeData.medium,
                  color: mutedColor,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: RoundedButtonFill(
              title: _isSubmitting ? 'Please wait' : 'I Agree',
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
