// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionImpl _$$SubscriptionImplFromJson(Map<String, dynamic> json) =>
    _$SubscriptionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      tier: $enumDecode(_$SubscriptionTierEnumMap, json['tier']),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
      googlePlaySubscriptionId: json['googlePlaySubscriptionId'] as String?,
    );

Map<String, dynamic> _$$SubscriptionImplToJson(_$SubscriptionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'tier': _$SubscriptionTierEnumMap[instance.tier]!,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'isActive': instance.isActive,
      'googlePlaySubscriptionId': instance.googlePlaySubscriptionId,
    };

const _$SubscriptionTierEnumMap = {
  SubscriptionTier.free: 'free',
  SubscriptionTier.gold: 'gold',
  SubscriptionTier.platinum: 'platinum',
};
