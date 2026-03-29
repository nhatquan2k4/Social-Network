class PostCommentEntity {
  final String id;
  final String? parentCommentId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostCommentEntity({
    required this.id,
    this.parentCommentId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
}