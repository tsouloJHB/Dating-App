// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interaction_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Interaction _$InteractionFromJson(Map<String, dynamic> json) {
  return _Interaction.fromJson(json);
}

/// @nodoc
mixin _$Interaction {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get targetUserId => throw _privateConstructorUsedError;
  InteractionType get type => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this Interaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Interaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $InteractionCopyWith<Interaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $InteractionCopyWith<$Res> {
  factory $InteractionCopyWith(
          Interaction value, $Res Function(Interaction) then) =
      _$InteractionCopyWithImpl<$Res, Interaction>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String targetUserId,
      InteractionType type,
      DateTime createdAt});
}

/// @nodoc
class _$InteractionCopyWithImpl<$Res, $Val extends Interaction>
    implements $InteractionCopyWith<$Res> {
  _$InteractionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Interaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? targetUserId = null,
    Object? type = null,
    Object? createdAt = null,
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
      targetUserId: null == targetUserId
          ? _value.targetUserId
          : targetUserId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InteractionType,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$InteractionImplCopyWith<$Res>
    implements $InteractionCopyWith<$Res> {
  factory _$$InteractionImplCopyWith(
          _$InteractionImpl value, $Res Function(_$InteractionImpl) then) =
      __$$InteractionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String targetUserId,
      InteractionType type,
      DateTime createdAt});
}

/// @nodoc
class __$$InteractionImplCopyWithImpl<$Res>
    extends _$InteractionCopyWithImpl<$Res, _$InteractionImpl>
    implements _$$InteractionImplCopyWith<$Res> {
  __$$InteractionImplCopyWithImpl(
      _$InteractionImpl _value, $Res Function(_$InteractionImpl) _then)
      : super(_value, _then);

  /// Create a copy of Interaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? targetUserId = null,
    Object? type = null,
    Object? createdAt = null,
  }) {
    return _then(_$InteractionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      targetUserId: null == targetUserId
          ? _value.targetUserId
          : targetUserId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as InteractionType,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$InteractionImpl implements _Interaction {
  const _$InteractionImpl(
      {required this.id,
      required this.userId,
      required this.targetUserId,
      required this.type,
      required this.createdAt});

  factory _$InteractionImpl.fromJson(Map<String, dynamic> json) =>
      _$$InteractionImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String targetUserId;
  @override
  final InteractionType type;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'Interaction(id: $id, userId: $userId, targetUserId: $targetUserId, type: $type, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InteractionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.targetUserId, targetUserId) ||
                other.targetUserId == targetUserId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, targetUserId, type, createdAt);

  /// Create a copy of Interaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InteractionImplCopyWith<_$InteractionImpl> get copyWith =>
      __$$InteractionImplCopyWithImpl<_$InteractionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$InteractionImplToJson(
      this,
    );
  }
}

abstract class _Interaction implements Interaction {
  const factory _Interaction(
      {required final String id,
      required final String userId,
      required final String targetUserId,
      required final InteractionType type,
      required final DateTime createdAt}) = _$InteractionImpl;

  factory _Interaction.fromJson(Map<String, dynamic> json) =
      _$InteractionImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get targetUserId;
  @override
  InteractionType get type;
  @override
  DateTime get createdAt;

  /// Create a copy of Interaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InteractionImplCopyWith<_$InteractionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
