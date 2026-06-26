import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/premium_repository.dart';
import '../../data/sources/premium_data_source.dart';
import '../../domain/models/subscription_model.dart';
import '../../core/network/dio_provider.dart';

// Premium Repository Providers
final premiumDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider).maybeWhen(
        data: (dio) => dio,
        orElse: () => throw Exception('Dio not initialized'),
      );
  return PremiumDataSourceImpl(dio);
});

final premiumRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(premiumDataSourceProvider);
  return PremiumRepositoryImpl(dataSource);
});

// Subscription Status Provider
final subscriptionProvider = FutureProvider<Subscription>((ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return repository.getSubscriptionStatus();
});

final isPremiumProvider = Provider<bool>((ref) {
  final subscription = ref.watch(subscriptionProvider).maybeWhen(
        data: (value) => value,
        orElse: () => null,
      );
  return subscription?.isActive == true &&
      subscription?.tier != SubscriptionTier.free;
});

// Premium State Provider
final premiumStateProvider =
    StateNotifierProvider<PremiumNotifier, PremiumState>((ref) {
  final repository = ref.watch(premiumRepositoryProvider);
  return PremiumNotifier(repository);
});

class PremiumState {
  final Subscription? subscription;
  final bool isLoading;
  final String? error;

  PremiumState({
    this.subscription,
    this.isLoading = false,
    this.error,
  });

  PremiumState copyWith({
    Subscription? subscription,
    bool? isLoading,
    String? error,
  }) {
    return PremiumState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isPremiumMember =>
      subscription != null &&
      subscription!.tier == SubscriptionTier.gold &&
      subscription!.isActive;

  bool get isPlatinumMember =>
      subscription != null &&
      subscription!.tier == SubscriptionTier.platinum &&
      subscription!.isActive;
}

class PremiumNotifier extends StateNotifier<PremiumState> {
  final PremiumRepository repository;

  PremiumNotifier(this.repository) : super(PremiumState());

  Future<void> loadSubscription() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final subscription = await repository.getSubscriptionStatus();
      state = state.copyWith(
        subscription: subscription,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createSubscription(
    String googlePlaySubscriptionId, {
    String platform = 'dev',
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final subscription = await repository.createSubscription(
        googlePlaySubscriptionId,
        platform: platform,
      );
      state = state.copyWith(subscription: subscription, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> cancelSubscription() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final subscription = await repository.cancelSubscription();
      state = state.copyWith(
        subscription: subscription,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
