// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      gender: json['gender'] as String,
      sexualOrientation: json['sexualOrientation'] as String,
      age: (json['age'] as num).toInt(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      photoUrls:
          (json['photoUrls'] as List<dynamic>).map((e) => e as String).toList(),
      bio: json['bio'] as String?,
      isPremium: json['isPremium'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'gender': instance.gender,
      'sexualOrientation': instance.sexualOrientation,
      'age': instance.age,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'photoUrls': instance.photoUrls,
      'bio': instance.bio,
      'isPremium': instance.isPremium,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
