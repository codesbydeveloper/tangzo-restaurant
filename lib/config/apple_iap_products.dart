import 'package:restaurant/models/subscription_plan_model.dart';

/// Apple In-App Purchase product IDs for Tangzo Restaurant subscriptions.
///
/// Create matching Non-Renewing Subscription products in App Store Connect
/// (Monetization → In-App Purchases) with these exact Product IDs, then submit
/// them for review with the app.
class AppleIapProducts {
  AppleIapProducts._();

  static const String bronze = 'com.tangzo.restaurant.subscription.bronze';
  static const String silver = 'com.tangzo.restaurant.subscription.silver';
  static const String gold = 'com.tangzo.restaurant.subscription.gold';

  static const Set<String> allProductIds = {bronze, silver, gold};

  /// Optional Firestore plan document ID → Apple product ID overrides.
  /// Fill these in if plan names ever change but IDs stay stable.
  static const Map<String, String> planIdOverrides = <String, String>{
    // 'yourFirestorePlanDocId': bronze,
    // 'yourSilverPlanDocId': silver,
    // 'yourGoldPlanDocId': gold,
  };

  static String? productIdForPlan(SubscriptionPlanModel plan) {
    final planId = plan.id?.trim();
    if (planId != null && planIdOverrides.containsKey(planId)) {
      return planIdOverrides[planId];
    }

    final name = (plan.name ?? '').toLowerCase().trim();
    if (name.contains('bronze')) return bronze;
    if (name.contains('silver')) return silver;
    if (name.contains('gold')) return gold;
    return null;
  }
}
