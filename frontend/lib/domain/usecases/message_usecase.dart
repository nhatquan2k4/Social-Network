import '../entities/message_entity.dart';
import '../repositories/message_repository.dart';

class GetMessagesUseCase {
  final MessageRepository repository;

  GetMessagesUseCase(this.repository);

  Future<List<MessageEntity>> call(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) {
    return repository.getMessages(conversationId, page: page, limit: limit);
  }
}

class SendMessageUseCase {
  final MessageRepository repository;

  SendMessageUseCase(this.repository);

  Future<MessageEntity> call(
    String recipientId,
    String content, {
    String? conversationId,
  }) {
    return repository.sendMessage(
      recipientId,
      content,
      conversationId: conversationId,
    );
  }
}
