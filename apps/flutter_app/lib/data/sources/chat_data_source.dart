import 'package:dio/dio.dart';
import '../../domain/models/message_model.dart';
import '../../core/constants/api_constants.dart';

abstract class ChatDataSource {
  Future<List<MessageThread>> getMessageThreads();

  Future<List<Message>> getMessages(String threadId);

  Future<String> uploadAttachment(String filePath);

  Future<Message> sendMessage({
    required String recipientId,
    required String content,
  });
}

class ChatDataSourceImpl implements ChatDataSource {
  final Dio dio;

  ChatDataSourceImpl(this.dio);

  @override
  Future<List<MessageThread>> getMessageThreads() async {
    try {
      final response = await dio.get(ApiConstants.messagesThreads);

      final raw = response.data['threads'];
      final threads = (raw is List ? raw : const <dynamic>[])
          .map((t) {
            final json = Map<String, dynamic>.from(t as Map);
            return MessageThread(
              id: (json['id'] ?? '').toString(),
              userId: '',
              otherUserId: (json['otherId'] ?? json['id'] ?? '').toString(),
              otherUserName: (json['otherName'] ?? '').toString(),
              otherUserPhoto: json['avatarUrl']?.toString(),
              lastMessage: (json['lastMessage'] ?? '').toString(),
              lastMessageAt: DateTime.tryParse(
                    (json['lastMessageAt'] ?? '').toString(),
                  ) ??
                  DateTime.now(),
              unreadCount: 0,
            );
          })
          .toList();

      threads.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

      return threads;
    } on DioException catch (e) {
      throw Exception('Failed to fetch message threads: ${e.message}');
    }
  }

  @override
  Future<List<Message>> getMessages(String threadId) async {
    try {
      final response = await dio.get(ApiConstants.messagesHistory(threadId));

      final raw = response.data['messages'];
      final messages = (raw is List ? raw : const <dynamic>[])
          .map((m) {
            final json = Map<String, dynamic>.from(m as Map);
            return Message(
              id: (json['id'] ?? '').toString(),
              senderId: (json['senderId'] ?? '').toString(),
              recipientId: (json['recipientId'] ?? '').toString(),
              content: (json['content'] ?? '').toString(),
              sentAt: DateTime.tryParse((json['sentAt'] ?? '').toString()) ??
                  DateTime.now(),
              isRead: (json['isRead'] ?? false) == true,
            );
          })
          .toList();

      return messages;
    } on DioException catch (e) {
      throw Exception('Failed to fetch messages: ${e.message}');
    }
  }

  @override
  Future<String> uploadAttachment(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await dio.post(
        ApiConstants.mediaUpload,
        data: formData,
      );

      final media = response.data['media'];
      if (media is Map && media['url'] != null) {
        return media['url'].toString();
      }
      throw Exception('Upload response missing media URL');
    } on DioException catch (e) {
      throw Exception('Failed to upload attachment: ${e.message}');
    }
  }

  @override
  Future<Message> sendMessage({
    required String recipientId,
    required String content,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.messagesSend(recipientId),
        data: {
          'recipientId': recipientId,
          'content': content,
        },
      );

      final messageRaw = response.data['message'];
      return Message.fromJson(
        Map<String, dynamic>.from(messageRaw as Map),
      );
    } on DioException catch (e) {
      throw Exception('Failed to send message: ${e.message}');
    }
  }
}
