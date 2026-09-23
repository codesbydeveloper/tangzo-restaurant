import 'package:get/get.dart';
import 'package:restaurant/app/dash_board_screens/app_not_access_screen.dart';
import 'package:restaurant/app/dash_board_screens/dash_board_screen.dart';
import 'package:restaurant/app/subscription_plan_screen/subscription_plan_screen.dart';
import 'package:restaurant/app/terms_and_condition/accept_terms_screen.dart';
import 'package:restaurant/constant/constant.dart';
import 'package:restaurant/models/user_model.dart';

class VendorNavigation {
  static bool hasAcceptedTerms(UserModel? user) => user?.isTermsAccepted == true;

  static bool _hasAppAccess(UserModel user) {
    return user.subscriptionPlan?.features?.restaurantMobileApp == true || user.subscriptionPlan?.type == 'free';
  }

  static bool _needsPlanSelection(UserModel user) {
    bool isPlanExpire = false;
    if (user.subscriptionPlan?.id != null) {
      if (user.subscriptionExpiryDate == null) {
        isPlanExpire = user.subscriptionPlan?.expiryDay != '-1';
      } else {
        isPlanExpire = user.subscriptionExpiryDate!.toDate().isBefore(DateTime.now());
      }
    } else {
      isPlanExpire = true;
    }
    return user.subscriptionPlanId == null || isPlanExpire == true;
  }

  static void goAfterAuth(UserModel user) {
    Constant.userModel = user;
    if (_needsPlanSelection(user)) {
      if (Constant.adminCommission?.isEnabled == false && Constant.isSubscriptionModelApplied == false) {
        goAfterPlan(user);
      } else {
        Get.offAll(const SubscriptionPlanScreen());
      }
      return;
    }
    goAfterPlan(user);
  }

  static void goAfterPlan(UserModel user, {bool isFromProfile = false}) {
    Constant.userModel = user;
    if (isFromProfile) {
      Get.back(result: true);
      return;
    }
    if (!hasAcceptedTerms(user)) {
      Get.offAll(const AcceptTermsScreen());
      return;
    }
    if (_hasAppAccess(user)) {
      Get.offAll(const DashBoardScreen());
    } else {
      Get.offAll(const AppNotAccessScreen());
    }
  }

  static void goAfterTermsAccepted(UserModel user) {
    Constant.userModel = user;
    if (_hasAppAccess(user)) {
      Get.offAll(const DashBoardScreen());
    } else {
      Get.offAll(const AppNotAccessScreen());
    }
  }
}
