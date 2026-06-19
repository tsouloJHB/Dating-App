import '../sources/premium_data_source.dart';
import '../../domain/models/subscription_model.dart';

abstract class PremiumRepository {
  Future<Subscription> getSubscriptionStatus();

  Future<Subscription> createSubscription(
    String googlePlaySubscriptionId, {
    String platform = 'dev',
  });

  Future<Subscription> cancelSubscription();
}

class PremiumRepositoryImpl implements PremiumRepository {
  final PremiumDataSource dataSource;

  PremiumRepositoryImpl(this.dataSource);

  @override
  Future<Subscription> getSubscriptionStatus() =>
      dataSource.getSubscriptionStatus();

  @override
  Future<Subscription> createSubscription(
    String googlePlaySubscriptionId, {
    String platform = 'dev',
  }) =>
      dataSource.createSubscription(googlePlaySubscriptionId, platform: platform);

  @override
  Future<Subscription> cancelSubscription() => dataSource.cancelSubscription();
}
