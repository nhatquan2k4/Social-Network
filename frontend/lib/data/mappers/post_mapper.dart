import '../../domain/entities/post_comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/entities/post_media_entity.dart';
import '../models/post/post_model.dart';

class PostMapper {
  static PostEntity toEntity(PostModel model) {
    return PostEntity(
      id: model.id,
      authorId: model.authorId,
      authorUsername: model.authorUsername,
      authorDisplayName: model.authorDisplayName,
      authorAvatarUrl: model.authorAvatarUrl,
      content: model.content,
      media: model.media
          .map(
            (item) => PostMediaEntity(
              bucket: item.bucket,
              objectKey: item.objectKey,
              mediaUrl: item.mediaUrl,
              mimeType: item.mimeType,
              size: item.size,
            ),
          )
          .toList(),
      likes: List<String>.from(model.likes),
      comments: model.comments
          .map(
            (item) => PostCommentEntity(
              id: item.id,
              parentCommentId: item.parentCommentId,
              authorId: item.authorId,
              content: item.content,
              createdAt: item.createdAt,
              updatedAt: item.updatedAt,
            ),
          )
          .toList(),
      commentsCount: model.commentsCount,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  static List<PostEntity> toEntityList(List<PostModel> models) {
    return models.map(toEntity).toList();
  }
}
