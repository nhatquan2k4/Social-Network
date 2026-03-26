class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String content;
  final String? imgUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.content,
    this.imgUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}
