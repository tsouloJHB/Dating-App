import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String senderId,
    required String recipientId,
    required String content,
    required DateTime sentAt,
    required bool isRead,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

@freezed
class MessageThread with _$MessageThread {
  const factory MessageThread({
    required String id,
    required String userId,
    required String otherUserId,
    required String otherUserName,
    required String? otherUserPhoto,
    required String lastMessage,
    required DateTime lastMessageAt,
    required int unreadCount,
  }) = _MessageThread;

  factory MessageThread.fromJson(Map<String, dynamic> json) =>
      _$MessageThreadFromJson(json);
}
