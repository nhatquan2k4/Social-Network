class ConversationEntity {
  final String id;
  final String type; // 'direct' or 'group'
  final List<String> participantIds;
  final String? groupName;
  final DateTime createdAt;

  ConversationEntity({
    required this.id,
    required this.type,
    required this.participantIds,
    this.groupName,
    required this.createdAt,
  });
}
