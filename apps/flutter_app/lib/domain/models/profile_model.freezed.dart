// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return _Profile.fromJson(json);
}

/// @nodoc
mixin _$Profile {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get bio => throw _privateConstructorUsedError;
  int get minAgeRange => throw _privateConstructorUsedError;
  int get maxAgeRange => throw _privateConstructorUsedError;
  int get discoveryRadius => throw _privateConstructorUsedError;
  String get preferredGender => throw _privateConstructorUsedError;
  List<String> get interests => throw _privateConstructorUsedError;

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileCopyWith<Profile> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCopyWith<$Res> {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) then) =
      _$ProfileCopyWithImpl<$Res, Profile>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String bio,
      int minAgeRange,
      int maxAgeRange,
      int discoveryRadius,
      String preferredGender,
      List<String> interests});
}

/// @nodoc
class _$ProfileCopyWithImpl<$Res, $Val extends Profile>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bio = null,
    Object? minAgeRange = null,
    Object? maxAgeRange = null,
    Object? discoveryRadius = null,
    Object? preferredGender = null,
    Object? interests = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      minAgeRange: null == minAgeRange
          ? _value.minAgeRange
          : minAgeRange // ignore: cast_nullable_to_non_nullable
              as int,
      maxAgeRange: null == maxAgeRange
          ? _value.maxAgeRange
          : maxAgeRange // ignore: cast_nullable_to_non_nullable
              as int,
      discoveryRadius: null == discoveryRadius
          ? _value.discoveryRadius
          : discoveryRadius // ignore: cast_nullable_to_non_nullable
              as int,
      preferredGender: null == preferredGender
          ? _value.preferredGender
          : preferredGender // ignore: cast_nullable_to_non_nullable
              as String,
      interests: null == interests
          ? _value.interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileImplCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$$ProfileImplCopyWith(
          _$ProfileImpl value, $Res Function(_$ProfileImpl) then) =
      __$$ProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String bio,
      int minAgeRange,
      int maxAgeRange,
      int discoveryRadius,
      String preferredGender,
      List<String> interests});
}

/// @nodoc
class __$$ProfileImplCopyWithImpl<$Res>
    extends _$ProfileCopyWithImpl<$Res, _$ProfileImpl>
    implements _$$ProfileImplCopyWith<$Res> {
  __$$ProfileImplCopyWithImpl(
      _$ProfileImpl _value, $Res Function(_$ProfileImpl) _then)
      : super(_value, _then);

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? bio = null,
    Object? minAgeRange = null,
    Object? maxAgeRange = null,
    Object? discoveryRadius = null,
    Object? preferredGender = null,
    Object? interests = null,
  }) {
    return _then(_$ProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      minAgeRange: null == minAgeRange
          ? _value.minAgeRange
          : minAgeRange // ignore: cast_nullable_to_non_nullable
              as int,
      maxAgeRange: null == maxAgeRange
          ? _value.maxAgeRange
          : maxAgeRange // ignore: cast_nullable_to_non_nullable
              as int,
      discoveryRadius: null == discoveryRadius
          ? _value.discoveryRadius
          : discoveryRadius // ignore: cast_nullable_to_non_nullable
              as int,
      preferredGender: null == preferredGender
          ? _value.preferredGender
          : preferredGender // ignore: cast_nullable_to_non_nullable
              as String,
      interests: null == interests
          ? _value._interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileImpl implements _Profile {
  const _$ProfileImpl(
      {required this.id,
      required this.userId,
      required this.bio,
      required this.minAgeRange,
      required this.maxAgeRange,
      required this.discoveryRadius,
      required this.preferredGender,
      required final List<String> interests})
      : _interests = interests;

  factory _$ProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String bio;
  @override
  final int minAgeRange;
  @override
  final int maxAgeRange;
  @override
  final int discoveryRadius;
  @override
  final String preferredGender;
  final List<String> _interests;
  @override
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  @override
  String toString() {
    return 'Profile(id: $id, userId: $userId, bio: $bio, minAgeRange: $minAgeRange, maxAgeRange: $maxAgeRange, discoveryRadius: $discoveryRadius, preferredGender: $preferredGender, interests: $interests)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.minAgeRange, minAgeRange) ||
                other.minAgeRange == minAgeRange) &&
            (identical(other.maxAgeRange, maxAgeRange) ||
                other.maxAgeRange == maxAgeRange) &&
            (identical(other.discoveryRadius, discoveryRadius) ||
                other.discoveryRadius == discoveryRadius) &&
            (identical(other.preferredGender, preferredGender) ||
                other.preferredGender == preferredGender) &&
            const DeepCollectionEquality()
                .equals(other._interests, _interests));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      bio,
      minAgeRange,
      maxAgeRange,
      discoveryRadius,
      preferredGender,
      const DeepCollectionEquality().hash(_interests));

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      __$$ProfileImplCopyWithImpl<_$ProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileImplToJson(
      this,
    );
  }
}

abstract class _Profile implements Profile {
  const factory _Profile(
      {required final String id,
      required final String userId,
      required final String bio,
      required final int minAgeRange,
      required final int maxAgeRange,
      required final int discoveryRadius,
      required final String preferredGender,
      required final List<String> interests}) = _$ProfileImpl;

  factory _Profile.fromJson(Map<String, dynamic> json) = _$ProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get bio;
  @override
  int get minAgeRange;
  @override
  int get maxAgeRange;
  @override
  int get discoveryRadius;
  @override
  String get preferredGender;
  @override
  List<String> get interests;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
