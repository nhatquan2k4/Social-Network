import '../entities/message_entity.dart';

abstract class MessageRepository {
  Future<List<MessageEntity>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  });
  Future<MessageEntity> sendMessage(
    String recipientId,
    String content, {
    String? conversationId,
  });
}
