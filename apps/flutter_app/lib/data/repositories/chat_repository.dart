import '../sources/chat_data_source.dart';
import '../../domain/models/message_model.dart';

abstract class ChatRepository {
  Future<List<MessageThread>> getMessageThreads();

  Future<List<Message>> getMessages(String threadId);

  Future<String> uploadAttachment(String filePath);

  Future<Message> sendMessage({
    required String recipientId,
    required String content,
  });
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatDataSource dataSource;

  ChatRepositoryImpl(this.dataSource);

  @override
  Future<List<MessageThread>> getMessageThreads() =>
      dataSource.getMessageThreads();

  @override
  Future<List<Message>> getMessages(String threadId) =>
      dataSource.getMessages(threadId);

    @override
    Future<String> uploadAttachment(String filePath) =>
      dataSource.uploadAttachment(filePath);

  @override
  Future<Message> sendMessage({
    required String recipientId,
    required String content,
  }) =>
      dataSource.sendMessage(recipientId: recipientId, content: content);
}
