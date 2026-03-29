import '../entities/post_comment_entity.dart';
import '../entities/post_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> fetchFeed({int page = 1, int limit = 10});

  Future<PostEntity> createPost(
    String content, {
    List<Map<String, dynamic>> media = const [],
    List<String> imagePaths = const [],
  });

  Future<PostEntity> likePost(String postId);

  Future<PostEntity> unlikePost(String postId);

  Future<PostCommentEntity> addComment(
    String postId,
    String content, {
    String? parentCommentId,
  });

  Future<void> deleteComment(String postId, String commentId);
}
