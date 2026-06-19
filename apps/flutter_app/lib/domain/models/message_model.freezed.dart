// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get recipientId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get sentAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String id,
      String senderId,
      String recipientId,
      String content,
      DateTime sentAt,
      bool isRead});
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? recipientId = null,
    Object? content = null,
    Object? sentAt = null,
    Object? isRead = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      recipientId: null == recipientId
          ? _value.recipientId
          : recipientId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sentAt: null == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String senderId,
      String recipientId,
      String content,
      DateTime sentAt,
      bool isRead});
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? recipientId = null,
    Object? content = null,
    Object? sentAt = null,
    Object? isRead = null,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      recipientId: null == recipientId
          ? _value.recipientId
          : recipientId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      sentAt: null == sentAt
          ? _value.sentAt
          : sentAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {required this.id,
      required this.senderId,
      required this.recipientId,
      required this.content,
      required this.sentAt,
      required this.isRead});

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  final String senderId;
  @override
  final String recipientId;
  @override
  final String content;
  @override
  final DateTime sentAt;
  @override
  final bool isRead;

  @override
  String toString() {
    return 'Message(id: $id, senderId: $senderId, recipientId: $recipientId, content: $content, sentAt: $sentAt, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.recipientId, recipientId) ||
                other.recipientId == recipientId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.sentAt, sentAt) || other.sentAt == sentAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, senderId, recipientId, content, sentAt, isRead);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {required final String id,
      required final String senderId,
      required final String recipientId,
      required final String content,
      required final DateTime sentAt,
      required final bool isRead}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  String get senderId;
  @override
  String get recipientId;
  @override
  String get content;
  @override
  DateTime get sentAt;
  @override
  bool get isRead;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageThread _$MessageThreadFromJson(Map<String, dynamic> json) {
  return _MessageThread.fromJson(json);
}

/// @nodoc
mixin _$MessageThread {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get otherUserId => throw _privateConstructorUsedError;
  String get otherUserName => throw _privateConstructorUsedError;
  String? get otherUserPhoto => throw _privateConstructorUsedError;
  String get lastMessage => throw _privateConstructorUsedError;
  DateTime get lastMessageAt => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;

  /// Serializes this MessageThread to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageThread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageThreadCopyWith<MessageThread> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageThreadCopyWith<$Res> {
  factory $MessageThreadCopyWith(
          MessageThread value, $Res Function(MessageThread) then) =
      _$MessageThreadCopyWithImpl<$Res, MessageThread>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String otherUserId,
      String otherUserName,
      String? otherUserPhoto,
      String lastMessage,
      DateTime lastMessageAt,
      int unreadCount});
}

/// @nodoc
class _$MessageThreadCopyWithImpl<$Res, $Val extends MessageThread>
    implements $MessageThreadCopyWith<$Res> {
  _$MessageThreadCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageThread
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? otherUserId = null,
    Object? otherUserName = null,
    Object? otherUserPhoto = freezed,
    Object? lastMessage = null,
    Object? lastMessageAt = null,
    Object? unreadCount = null,
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
      otherUserId: null == otherUserId
          ? _value.otherUserId
          : otherUserId // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserName: null == otherUserName
          ? _value.otherUserName
          : otherUserName // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserPhoto: freezed == otherUserPhoto
          ? _value.otherUserPhoto
          : otherUserPhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: null == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessageAt: null == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageThreadImplCopyWith<$Res>
    implements $MessageThreadCopyWith<$Res> {
  factory _$$MessageThreadImplCopyWith(
          _$MessageThreadImpl value, $Res Function(_$MessageThreadImpl) then) =
      __$$MessageThreadImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String otherUserId,
      String otherUserName,
      String? otherUserPhoto,
      String lastMessage,
      DateTime lastMessageAt,
      int unreadCount});
}

/// @nodoc
class __$$MessageThreadImplCopyWithImpl<$Res>
    extends _$MessageThreadCopyWithImpl<$Res, _$MessageThreadImpl>
    implements _$$MessageThreadImplCopyWith<$Res> {
  __$$MessageThreadImplCopyWithImpl(
      _$MessageThreadImpl _value, $Res Function(_$MessageThreadImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageThread
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? otherUserId = null,
    Object? otherUserName = null,
    Object? otherUserPhoto = freezed,
    Object? lastMessage = null,
    Object? lastMessageAt = null,
    Object? unreadCount = null,
  }) {
    return _then(_$MessageThreadImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserId: null == otherUserId
          ? _value.otherUserId
          : otherUserId // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserName: null == otherUserName
          ? _value.otherUserName
          : otherUserName // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserPhoto: freezed == otherUserPhoto
          ? _value.otherUserPhoto
          : otherUserPhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: null == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String,
      lastMessageAt: null == lastMessageAt
          ? _value.lastMessageAt
          : lastMessageAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      unreadCount: null == unreadCount
          ? _value.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageThreadImpl implements _MessageThread {
  const _$MessageThreadImpl(
      {required this.id,
      required this.userId,
      required this.otherUserId,
      required this.otherUserName,
      required this.otherUserPhoto,
      required this.lastMessage,
      required this.lastMessageAt,
      required this.unreadCount});

  factory _$MessageThreadImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageThreadImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String otherUserId;
  @override
  final String otherUserName;
  @override
  final String? otherUserPhoto;
  @override
  final String lastMessage;
  @override
  final DateTime lastMessageAt;
  @override
  final int unreadCount;

  @override
  String toString() {
    return 'MessageThread(id: $id, userId: $userId, otherUserId: $otherUserId, otherUserName: $otherUserName, otherUserPhoto: $otherUserPhoto, lastMessage: $lastMessage, lastMessageAt: $lastMessageAt, unreadCount: $unreadCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageThreadImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.otherUserId, otherUserId) ||
                other.otherUserId == otherUserId) &&
            (identical(other.otherUserName, otherUserName) ||
                other.otherUserName == otherUserName) &&
            (identical(other.otherUserPhoto, otherUserPhoto) ||
                other.otherUserPhoto == otherUserPhoto) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageAt, lastMessageAt) ||
                other.lastMessageAt == lastMessageAt) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, otherUserId,
      otherUserName, otherUserPhoto, lastMessage, lastMessageAt, unreadCount);

  /// Create a copy of MessageThread
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageThreadImplCopyWith<_$MessageThreadImpl> get copyWith =>
      __$$MessageThreadImplCopyWithImpl<_$MessageThreadImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageThreadImplToJson(
      this,
    );
  }
}

abstract class _MessageThread implements MessageThread {
  const factory _MessageThread(
      {required final String id,
      required final String userId,
      required final String otherUserId,
      required final String otherUserName,
      required final String? otherUserPhoto,
      required final String lastMessage,
      required final DateTime lastMessageAt,
      required final int unreadCount}) = _$MessageThreadImpl;

  factory _MessageThread.fromJson(Map<String, dynamic> json) =
      _$MessageThreadImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get otherUserId;
  @override
  String get otherUserName;
  @override
  String? get otherUserPhoto;
  @override
  String get lastMessage;
  @override
  DateTime get lastMessageAt;
  @override
  int get unreadCount;

  /// Create a copy of MessageThread
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageThreadImplCopyWith<_$MessageThreadImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
