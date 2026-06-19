import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

@freezed
class Subscription with _$Subscription {
  const factory Subscription({
    required String id,
    required String userId,
    required SubscriptionTier tier,
    required DateTime startDate,
    required DateTime? endDate,
    required bool isActive,
    required String? googlePlaySubscriptionId,
  }) = _Subscription;

  factory Subscription.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionFromJson(json);
}

enum SubscriptionTier {
  @JsonValue('free')
  free,
  @JsonValue('gold')
  gold,
  @JsonValue('platinum')
  platinum,
}
