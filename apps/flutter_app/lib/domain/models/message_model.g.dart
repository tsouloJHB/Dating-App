// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      recipientId: json['recipientId'] as String,
      content: json['content'] as String,
      sentAt: DateTime.parse(json['sentAt'] as String),
      isRead: json['isRead'] as bool,
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'recipientId': instance.recipientId,
      'content': instance.content,
      'sentAt': instance.sentAt.toIso8601String(),
      'isRead': instance.isRead,
    };

_$MessageThreadImpl _$$MessageThreadImplFromJson(Map<String, dynamic> json) =>
    _$MessageThreadImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      otherUserId: json['otherUserId'] as String,
      otherUserName: json['otherUserName'] as String,
      otherUserPhoto: json['otherUserPhoto'] as String?,
      lastMessage: json['lastMessage'] as String,
      lastMessageAt: DateTime.parse(json['lastMessageAt'] as String),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );

Map<String, dynamic> _$$MessageThreadImplToJson(_$MessageThreadImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'otherUserId': instance.otherUserId,
      'otherUserName': instance.otherUserName,
      'otherUserPhoto': instance.otherUserPhoto,
      'lastMessage': instance.lastMessage,
      'lastMessageAt': instance.lastMessageAt.toIso8601String(),
      'unreadCount': instance.unreadCount,
    };
