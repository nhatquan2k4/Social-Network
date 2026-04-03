import '../entities/conversation_entity.dart';
import '../repositories/conversation_repository.dart';

class CreateConversationUseCase {
  final ConversationRepository repository;

  CreateConversationUseCase(this.repository);

  Future<ConversationEntity> call({required String recipientId}) {
    return repository.createConversation(recipientId: recipientId);
  }
}

class GetConversationsUseCase {
  final ConversationRepository repository;

  GetConversationsUseCase(this.repository);

  Future<List<ConversationEntity>> call() {
    return repository.getConversations();
  }
}
