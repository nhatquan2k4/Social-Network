import '../../domain/entities/conversation_entity.dart';
import '../models/conversation/conversation_model.dart';

class ConversationMapper {
  static ConversationEntity toEntity(ConversationModel model) {
    return model.toEntity();
  }

  static List<ConversationEntity> toEntityList(List<ConversationModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
