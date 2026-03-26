import '../../domain/entities/message_entity.dart';
import '../models/message/message_model.dart';

class MessageMapper {
  static MessageEntity toEntity(MessageModel model) {
    return MessageEntity(
      id: model.id,
      conversationId: model.conversationId,
      senderId: model.senderId,
      content: model.content,
      imgUrl: model.imgUrl,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static List<MessageEntity> toEntityList(List<MessageModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }
}
