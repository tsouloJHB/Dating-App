// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'interaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$InteractionImpl _$$InteractionImplFromJson(Map<String, dynamic> json) =>
    _$InteractionImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      targetUserId: json['targetUserId'] as String,
      type: $enumDecode(_$InteractionTypeEnumMap, json['type']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$InteractionImplToJson(_$InteractionImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'targetUserId': instance.targetUserId,
      'type': _$InteractionTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$InteractionTypeEnumMap = {
  InteractionType.like: 'like',
  InteractionType.pass: 'pass',
  InteractionType.view: 'view',
};
