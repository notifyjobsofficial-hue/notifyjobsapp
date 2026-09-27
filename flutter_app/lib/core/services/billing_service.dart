import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'storage_service.dart';
import '../../features/providers/storage_provider.dart';

/// Product IDs for Google Play Store In-App Purchases
class BillingProductIds {
  BillingProductIds._();

  /// Lifetime Pro: Ad-Free Experience + Instant Downloads (Non-consumable)
  static const String proLifetime = 'notify_jobs_pro_lifetime';

  /// Developer Support Tiers (Consumable)
  static const String support29 = 'notify_jobs_support_29';
  static const String support59 = 'notify_jobs_support_59';
  static const String support99 = 'notify_jobs_support_99';
  static const String support199 = 'notify_jobs_support_199';
  static const String support499 = 'notify_jobs_support_499';

  static const Set<String> all = {
    proLifetime,
    support29,
    support59,
    support99,
    support199,
    support499,
  };
}

/// State of Google Play Billing and Pro Membership
class BillingState {
  final bool isPro;
  final bool isAvailable;
  final bool isLoading;
  final List<ProductDetails> products;
  final String? errorMessage;
  final String? successMessage;

  const BillingState({
    this.isPro = false,
    this.isAvailable = false,
    this.isLoading = false,
    this.products = const [],
    this.errorMessage,
    this.successMessage,
  });

  BillingState copyWith({
    bool? isPro,
    bool? isAvailable,
    bool? isLoading,
    List<ProductDetails>? products,
    String? errorMessage,
    String? successMessage,
  }) {
    return BillingState(
      isPro: isPro ?? this.isPro,
      isAvailable: isAvailable ?? this.isAvailable,
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  ProductDetails? get proProduct {
    try {
      return products.firstWhere((p) => p.id == BillingProductIds.proLifetime);
    } catch (_) {
      return null;
    }
  }

  List<ProductDetails> get tipProducts {
    return products
        .where((p) => p.id != BillingProductIds.proLifetime)
        .toList();
  }
}

/// Riverpod StateNotifier for Google Play In-App Billing
class BillingNotifier extends StateNotifier<BillingState> {
  final InAppPurchase _iap = InAppPurchase.instance;
  final StorageService _storage;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  BillingNotifier(this._storage)
      : super(BillingState(isPro: _storage.isProUser())) {
    _initBilling();
  }

  Future<void> _initBilling() async {
    state = state.copyWith(isLoading: true);

    try {
      final isAvailable = await _iap.isAvailable();
      if (!isAvailable) {
        state = state.copyWith(
          isAvailable: false,
          isLoading: false,
        );
        return;
      }

      // Listen to purchase streams from Google Play
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdated,
        onDone: () => _subscription?.cancel(),
        onError: (err) {
          debugPrint('Billing purchaseStream error: $err');
        },
      );

      // Query products from Google Play
      final response = await _iap.queryProductDetails(BillingProductIds.all);

      state = state.copyWith(
        isAvailable: true,
        isLoading: false,
        products: response.productDetails,
      );
    } catch (e) {
      debugPrint('Billing initialization failed: $e');
      state = state.copyWith(
        isAvailable: false,
        isLoading: false,
        errorMessage: 'Google Play Billing could not be initialized.',
      );
    }
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        state = state.copyWith(isLoading: true);
      } else if (purchase.status == PurchaseStatus.error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: purchase.error?.message ?? 'Purchase failed.',
        );
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Verify and deliver product
        if (purchase.productID == BillingProductIds.proLifetime) {
          await _storage.setProUser(true);
          state = state.copyWith(
            isPro: true,
            isLoading: false,
            successMessage:
                'Welcome to Notify Jobs Pro! All ads removed forever.',
          );
        } else {
          // Consumable support tip
          state = state.copyWith(
            isLoading: false,
            successMessage: 'Thank you for supporting Notify Jobs development!',
          );
        }

        // Complete the transaction with Google Play
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  /// Initiates purchase of Notify Jobs Pro (non-consumable)
  Future<void> buyPro() async {
    final proProduct = state.proProduct;
    if (proProduct == null) {
      state =
          state.copyWith(errorMessage: 'Pro product details not loaded yet.');
      return;
    }

    final purchaseParam = PurchaseParam(productDetails: proProduct);
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, errorMessage: 'Purchase request failed.');
    }
  }

  /// Initiates support tip purchase (consumable)
  Future<void> buyTip(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      state =
          state.copyWith(isLoading: false, errorMessage: 'Tip request failed.');
    }
  }

  /// Restores previous purchases
  Future<void> restorePurchases() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _iap.restorePurchases();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Unable to restore purchases. Please check your Google account.',
      );
    }
  }

  void clearStatusMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Global provider for Google Play Billing & Pro status
final billingProvider =
    StateNotifierProvider<BillingNotifier, BillingState>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return BillingNotifier(storage);
});
