import '../entities/conversation_entity.dart';

abstract class ConversationRepository {
  Future<ConversationEntity> createConversation({
    required String recipientId,
    String type = 'direct',
  });

  Future<List<ConversationEntity>> getConversations();
}
