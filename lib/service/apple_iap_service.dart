import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class AppleIapPurchaseException implements Exception {
  AppleIapPurchaseException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Handles StoreKit purchases for iOS subscription plans.
class AppleIapService {
  AppleIapService._();
  static final AppleIapService instance = AppleIapService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Completer<PurchaseDetails>? _activePurchaseCompleter;
  String? _activeProductId;
  bool _listening = false;

  Future<void> ensureListening() async {
    if (!Platform.isIOS || _listening) return;
    _purchaseSubscription = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (Object error) {
        debugPrint('Apple IAP stream error: $error');
        if (_activePurchaseCompleter != null && !_activePurchaseCompleter!.isCompleted) {
          _activePurchaseCompleter!.completeError(AppleIapPurchaseException(error.toString()));
        }
      },
    );
    _listening = true;
  }

  Future<bool> isAvailable() async {
    if (!Platform.isIOS) return false;
    return _iap.isAvailable();
  }

  Future<ProductDetails?> getProduct(String productId) async {
    await ensureListening();
    final response = await _iap.queryProductDetails({productId});
    if (response.error != null) {
      throw AppleIapPurchaseException(response.error!.message);
    }
    if (response.productDetails.isEmpty) {
      return null;
    }
    return response.productDetails.first;
  }

  /// Starts a StoreKit purchase and waits until it succeeds, is cancelled, or errors.
  Future<PurchaseDetails> buy(String productId) async {
    if (!Platform.isIOS) {
      throw AppleIapPurchaseException('Apple In-App Purchase is only available on iOS.');
    }

    await ensureListening();

    final available = await _iap.isAvailable();
    if (!available) {
      throw AppleIapPurchaseException('In-App Purchases are not available on this device.');
    }

    final product = await getProduct(productId);
    if (product == null) {
      throw AppleIapPurchaseException(
        'Product "$productId" was not found in App Store Connect. '
        'Create the Non-Renewing Subscription and wait until it is Ready to Submit.',
      );
    }

    if (_activePurchaseCompleter != null && !_activePurchaseCompleter!.isCompleted) {
      throw AppleIapPurchaseException('Another purchase is already in progress.');
    }

    _activeProductId = productId;
    _activePurchaseCompleter = Completer<PurchaseDetails>();

    final purchaseParam = PurchaseParam(productDetails: product);
    // App Store Connect products are Consumable so plans can be renewed/repurchased.
    final started = await _iap.buyConsumable(purchaseParam: purchaseParam, autoConsume: true);
    if (!started) {
      _activePurchaseCompleter = null;
      _activeProductId = null;
      throw AppleIapPurchaseException('Unable to start Apple purchase.');
    }

    try {
      return await _activePurchaseCompleter!.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          throw AppleIapPurchaseException('Purchase timed out. Please try again.');
        },
      );
    } finally {
      _activePurchaseCompleter = null;
      _activeProductId = null;
    }
  }

  Future<void> complete(PurchaseDetails purchase) async {
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      final matchesActive = _activeProductId == null || purchase.productID == _activeProductId;
      if (!matchesActive && _activePurchaseCompleter != null) {
        if (purchase.pendingCompletePurchase) {
          unawaited(complete(purchase));
        }
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (_activePurchaseCompleter != null && !_activePurchaseCompleter!.isCompleted) {
            _activePurchaseCompleter!.complete(purchase);
          } else {
            unawaited(complete(purchase));
          }
          break;
        case PurchaseStatus.error:
          final message = purchase.error?.message ?? 'Purchase failed.';
          if (_activePurchaseCompleter != null && !_activePurchaseCompleter!.isCompleted) {
            _activePurchaseCompleter!.completeError(AppleIapPurchaseException(message));
          }
          unawaited(complete(purchase));
          break;
        case PurchaseStatus.canceled:
          if (_activePurchaseCompleter != null && !_activePurchaseCompleter!.isCompleted) {
            _activePurchaseCompleter!.completeError(AppleIapPurchaseException('Purchase cancelled.'));
          }
          unawaited(complete(purchase));
          break;
      }
    }
  }

  Future<void> dispose() async {
    await _purchaseSubscription?.cancel();
    _purchaseSubscription = null;
    _listening = false;
  }
}
