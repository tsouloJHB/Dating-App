// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchImpl _$$MatchImplFromJson(Map<String, dynamic> json) => _$MatchImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      matchedUserId: json['matchedUserId'] as String,
      matchedAt: DateTime.parse(json['matchedAt'] as String),
    );

Map<String, dynamic> _$$MatchImplToJson(_$MatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'matchedUserId': instance.matchedUserId,
      'matchedAt': instance.matchedAt.toIso8601String(),
    };
