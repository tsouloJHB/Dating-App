// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(Map<String, dynamic> json) =>
    _$ProfileImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      bio: json['bio'] as String,
      minAgeRange: (json['minAgeRange'] as num).toInt(),
      maxAgeRange: (json['maxAgeRange'] as num).toInt(),
      discoveryRadius: (json['discoveryRadius'] as num).toInt(),
      preferredGender: json['preferredGender'] as String,
      interests:
          (json['interests'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'bio': instance.bio,
      'minAgeRange': instance.minAgeRange,
      'maxAgeRange': instance.maxAgeRange,
      'discoveryRadius': instance.discoveryRadius,
      'preferredGender': instance.preferredGender,
      'interests': instance.interests,
    };
