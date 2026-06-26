import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../auth/auth_provider.dart';
import 'premium_provider.dart';

/// The subscription product ID — must match the subscription created in
/// Google Play Console under your app's "Subscriptions" section.
const kGoldSubscriptionId = 'casual_dates_monthly';

/// The base plan ID for the monthly subscription.
const kBasePlanId = 'casual-dates-monthly';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class BillingState {
  const BillingState({
    this.isAvailable = false,
    this.isLoading = false,
    this.goldProduct,
    this.purchasePending = false,
    this.error,
  });

  final bool isAvailable;
  final bool isLoading;

  /// Populated once the product has been fetched from Google Play.
  final ProductDetails? goldProduct;

  /// True while waiting for the Play billing flow to complete.
  final bool purchasePending;

  final String? error;

  BillingState copyWith({
    bool? isAvailable,
    bool? isLoading,
    ProductDetails? goldProduct,
    bool? purchasePending,
    String? error,
    bool clearError = false,
    bool clearProduct = false,
  }) {
    return BillingState(
      isAvailable: isAvailable ?? this.isAvailable,
      isLoading: isLoading ?? this.isLoading,
      goldProduct: clearProduct ? null : (goldProduct ?? this.goldProduct),
      purchasePending: purchasePending ?? this.purchasePending,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class GooglePlayBillingNotifier extends StateNotifier<BillingState> {
  GooglePlayBillingNotifier(this._ref) : super(const BillingState()) {
    if (Platform.isAndroid) _initialize();
  }

  final Ref _ref;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  // ---- Lifecycle ----------------------------------------------------------

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final isAvailable = await InAppPurchase.instance.isAvailable();
    if (!isAvailable) {
      state = state.copyWith(
        isAvailable: false,
        isLoading: false,
        error: 'Google Play Billing is not available on this device.',
      );
      return;
    }

    // Subscribe to purchase updates BEFORE querying products so we don't miss
    // any pending purchases from a previous session.
    _purchaseSub = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object e) {
        if (mounted) state = state.copyWith(error: 'Billing stream error: $e');
      },
    );

    await _loadProduct();
  }

  Future<void> _loadProduct() async {
    final response = await InAppPurchase.instance
        .queryProductDetails({kGoldSubscriptionId});

    if (!mounted) return;

    if (response.error != null) {
      state = state.copyWith(
        isAvailable: true,
        isLoading: false,
        error: 'Could not load subscription details: ${response.error!.message}',
      );
      return;
    }

    final product = response.productDetails.isNotEmpty
        ? response.productDetails.first
        : null;

    state = state.copyWith(
      isAvailable: true,
      isLoading: false,
      goldProduct: product,
      clearError: true,
    );
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  // ---- Public actions -----------------------------------------------------

  /// Open the Google Play subscription purchase sheet.
  Future<void> buy() async {
    final product = state.goldProduct;
    if (product == null) {
      state = state.copyWith(error: 'Subscription details not loaded. Please try again.');
      return;
    }
    if (state.purchasePending) return;

    state = state.copyWith(purchasePending: true, clearError: true);

    try {
      PurchaseParam param;

      // On Android, select the offer matching our base plan ID so Google Play
      // shows the correct pricing. Falls back to the first offer if not found.
      if (Platform.isAndroid && product is GooglePlayProductDetails) {
        final offers = product.subscriptionOfferDetails ?? [];
        final offer = offers.firstWhere(
          (o) => o.basePlanId == kBasePlanId,
          orElse: () => offers.first,
        );
        param = GooglePlayPurchaseParam(
          productDetails: product,
          changeSubscriptionParam: null,
          offerToken: offer.offerToken,
        );
      } else {
        param = PurchaseParam(productDetails: product);
      }

      await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      if (mounted) {
        state = state.copyWith(purchasePending: false, error: e.toString());
      }
    }
  }

  /// Restore any previous Google Play subscription (e.g. after reinstall).
  Future<void> restorePurchases() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await InAppPurchase.instance.restorePurchases();
      // Restored purchases come through _onPurchaseUpdates.
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isLoading: false, error: 'Restore failed: $e');
      }
    }
  }

  // ---- Purchase stream handler -------------------------------------------

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyAndDeliver(purchase);
          break;

        case PurchaseStatus.pending:
          if (mounted) state = state.copyWith(purchasePending: true);
          break;

        case PurchaseStatus.error:
          if (mounted) {
            state = state.copyWith(
              purchasePending: false,
              isLoading: false,
              error: purchase.error?.message ?? 'Purchase failed.',
            );
          }
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
          break;

        case PurchaseStatus.canceled:
          if (mounted) {
            state = state.copyWith(purchasePending: false, isLoading: false);
          }
          break;
      }
    }
  }

  /// Send the purchase token to our backend, then complete the purchase on
  /// the Play Store side (required within 3 days to avoid auto-refund).
  Future<void> _verifyAndDeliver(PurchaseDetails purchase) async {
    try {
      final token = purchase.verificationData.serverVerificationData;

      // Backend verification — updates profile.tier to PREMIUM.
      await _ref
          .read(premiumStateProvider.notifier)
          .createSubscription(token, platform: 'android');

      // Acknowledge the purchase so Play Store doesn't auto-refund it.
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }

      // Refresh subscription UI and user tier badge.
      _ref.invalidate(subscriptionProvider);
      await _ref.read(authStateProvider.notifier).getCurrentUser();

      if (mounted) {
        state = state.copyWith(purchasePending: false, isLoading: false, clearError: true);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          purchasePending: false,
          isLoading: false,
          error: 'Could not activate subscription: $e',
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final googlePlayBillingProvider =
    StateNotifierProvider<GooglePlayBillingNotifier, BillingState>(
  (ref) => GooglePlayBillingNotifier(ref),
);
