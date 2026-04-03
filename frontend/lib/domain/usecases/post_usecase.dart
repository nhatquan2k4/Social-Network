import '../repositories/post_repository.dart';
import '../entities/post_comment_entity.dart';
import '../entities/post_entity.dart';

class PostUsecase {
  final PostRepository repository;

  PostUsecase(this.repository);

  Future<List<PostEntity>> fetchFeed({int page = 1, int limit = 10}) {
    return repository.fetchFeed(page: page, limit: limit);
  }

  Future<PostEntity> getPostById(String postId) {
    return repository.getPostById(postId);
  }

  Future<PostEntity> createPost(
    String content, {
    List<Map<String, dynamic>> media = const [],
    List<String> imagePaths = const [],
  }) {
    return repository.createPost(content, media: media, imagePaths: imagePaths);
  }

  Future<PostEntity> likePost(String postId) {
    return repository.likePost(postId);
  }

  Future<PostEntity> unlikePost(String postId) {
    return repository.unlikePost(postId);
  }

  Future<void> reportPost({required String postId, required String reason}) {
    return repository.reportPost(postId: postId, reason: reason);
  }

  Future<PostCommentEntity> addComment(
    String postId,
    String content, {
    String? parentCommentId,
  }) {
    return repository.addComment(
      postId,
      content,
      parentCommentId: parentCommentId,
    );
  }

  Future<void> deleteComment(String postId, String commentId) {
    return repository.deleteComment(postId, commentId);
  }
}
