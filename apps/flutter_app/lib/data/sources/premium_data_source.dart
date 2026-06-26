import 'package:dio/dio.dart';
import '../../domain/models/subscription_model.dart';
import '../../core/constants/api_constants.dart';

abstract class PremiumDataSource {
  Future<Subscription> getSubscriptionStatus();

  Future<Subscription> createSubscription(
    String googlePlaySubscriptionId, {
    String platform = 'dev',
  });

  Future<Subscription> cancelSubscription();
}

class PremiumDataSourceImpl implements PremiumDataSource {
  final Dio dio;

  PremiumDataSourceImpl(this.dio);

  @override
  Future<Subscription> getSubscriptionStatus() async {
    try {
      final response = await dio.get(ApiConstants.billingSubscriptions);

      return Subscription.fromJson(response.data['subscription']);
    } on DioException catch (e) {
      throw Exception('Failed to fetch subscription: ${e.message}');
    }
  }

  @override
  Future<Subscription> createSubscription(
    String googlePlaySubscriptionId, {
    String platform = 'dev',
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.billingVerify,
        data: {
          'purchaseToken': googlePlaySubscriptionId,
          'productId': 'casual_dates_monthly',
          'platform': platform,
        },
      );

      return Subscription.fromJson(response.data['subscription']);
    } on DioException catch (e) {
      throw Exception('Failed to create subscription: ${e.message}');
    }
  }

  @override
  Future<Subscription> cancelSubscription() async {
    try {
      final response = await dio.delete(ApiConstants.billingSubscriptions);
      return Subscription.fromJson(response.data['subscription']);
    } on DioException catch (e) {
      throw Exception('Failed to cancel subscription: ${e.message}');
    }
  }
}
