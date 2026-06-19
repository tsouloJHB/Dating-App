import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/chat_repository.dart';
import '../../data/sources/chat_data_source.dart';
import '../../domain/models/message_model.dart';
import '../../core/network/dio_provider.dart';

// Chat Repository Providers
final chatDataSourceProvider = Provider((ref) {
  final dio = ref.watch(dioProvider).maybeWhen(
        data: (dio) => dio,
        orElse: () => throw Exception('Dio not initialized'),
      );
  return ChatDataSourceImpl(dio);
});

final chatRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(chatDataSourceProvider);
  return ChatRepositoryImpl(dataSource);
});

// Chat Providers
final messageThreadsProvider =
    FutureProvider<List<MessageThread>>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessageThreads();
});

final messagesProvider =
    FutureProvider.family<List<Message>, String>((ref, threadId) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.getMessages(threadId);
});

// Chat State Providers
final chatStateProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ChatNotifier(repository);
});

class ChatState {
  final bool isSending;
  final String? error;
  final List<Message> messages;

  ChatState({
    this.isSending = false,
    this.error,
    this.messages = const [],
  });

  ChatState copyWith({
    bool? isSending,
    String? error,
    List<Message>? messages,
  }) {
    return ChatState(
      isSending: isSending ?? this.isSending,
      error: error ?? this.error,
      messages: messages ?? this.messages,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository repository;

  ChatNotifier(this.repository) : super(ChatState());

  Future<void> sendMessage({
    required String recipientId,
    required String content,
  }) async {
    state = state.copyWith(isSending: true, error: null);
    try {
      final message = await repository.sendMessage(
        recipientId: recipientId,
        content: content,
      );
      state = state.copyWith(
        isSending: false,
        messages: [...state.messages, message],
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendAttachment({
    required String recipientId,
    required String filePath,
  }) async {
    state = state.copyWith(isSending: true, error: null);
    try {
      final url = await repository.uploadAttachment(filePath);
      final message = await repository.sendMessage(
        recipientId: recipientId,
        content: url,
      );
      state = state.copyWith(
        isSending: false,
        messages: [...state.messages, message],
      );
    } catch (e) {
      state = state.copyWith(
        isSending: false,
        error: e.toString(),
      );
    }
  }

  void clearMessages() {
    state = ChatState();
  }
}
