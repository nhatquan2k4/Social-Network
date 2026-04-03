import '../../core/constants/api_constants.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/post_comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/repositories/post_repository.dart';
import 'package:dio/dio.dart';
import '../models/post/post_comment_model.dart';
import '../models/post/post_model.dart';
import '../mappers/post_mapper.dart';
import '../services/api_service.dart';

class PostRepositoryImpl implements PostRepository {
  final ApiService apiService;

  PostRepositoryImpl(this.apiService);

  @override
  Future<List<PostEntity>> fetchFeed({int page = 1, int limit = 10}) async {
    try {
      final response = await apiService.get(
        ApiConstants.postsFeed,
        queryParameters: {'page': page, 'limit': limit},
      );

      final data = response.data['data'];
      final items =
          (data is Map<String, dynamic> ? data['items'] : null)
              as List<dynamic>? ??
          const [];

      final models = items
          .map((item) => PostModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
      return PostMapper.toEntityList(models);
    } catch (e) {
      logger.e('Failed to fetch feed: $e');
      rethrow;
    }
  }

  @override
  Future<PostEntity> createPost(
    String content, {
    List<Map<String, dynamic>> media = const [],
    List<String> imagePaths = const [],
  }) async {
    try {
      final normalizedContent = content.trim();

      final dynamic payload;
      if (imagePaths.isNotEmpty) {
        final files = <MultipartFile>[];
        for (final path in imagePaths) {
          final trimmed = path.trim();
          if (trimmed.isEmpty) continue;

          final segments = trimmed.split(RegExp(r'[\\/]'));
          final fileName = segments.isNotEmpty ? segments.last : 'image.jpg';
          files.add(await MultipartFile.fromFile(trimmed, filename: fileName));
        }

        payload = FormData.fromMap({
          if (normalizedContent.isNotEmpty) 'content': normalizedContent,
          if (files.isNotEmpty) 'files': files,
          if (media.isNotEmpty) 'media': media,
        });
      } else {
        payload = {
          'content': normalizedContent,
          if (media.isNotEmpty) 'media': media,
        };
      }

      final response = await apiService.post(ApiConstants.posts, payload);

      final raw = response.data['data'];
      try {
        final model = PostModel.fromJson(Map<String, dynamic>.from(raw));
        return PostMapper.toEntity(model);
      } catch (parseError) {
        logger.w('Create post parse fallback triggered: $parseError');
        final latestFeed = await fetchFeed(page: 1, limit: 1);
        if (latestFeed.isNotEmpty) {
          return latestFeed.first;
        }
        rethrow;
      }
    } catch (e) {
      logger.e('Failed to create post: $e');
      rethrow;
    }
  }

  @override
  Future<PostEntity> likePost(String postId) async {
    try {
      final response = await apiService.post(ApiConstants.postLike(postId), {});
      final raw = response.data['data'];
      final model = PostModel.fromJson(Map<String, dynamic>.from(raw));
      return PostMapper.toEntity(model);
    } catch (e) {
      logger.e('Failed to like post: $e');
      rethrow;
    }
  }

  @override
  Future<PostEntity> unlikePost(String postId) async {
    try {
      // Backend exposes like/unlike as a single toggle endpoint.
      final response = await apiService.post(ApiConstants.postLike(postId), {});
      final raw = response.data['data'];
      final model = PostModel.fromJson(Map<String, dynamic>.from(raw));
      return PostMapper.toEntity(model);
    } catch (e) {
      logger.e('Failed to unlike post: $e');
      rethrow;
    }
  }

  @override
  Future<void> reportPost({required String postId, required String reason}) async {
    try {
      await apiService.post(ApiConstants.postReport(postId), {
        'reason': reason,
      });
    } catch (e) {
      logger.e('Failed to report post: $e');
      rethrow;
    }
  }

  @override
  Future<PostCommentEntity> addComment(
    String postId,
    String content, {
    String? parentCommentId,
  }) async {
    try {
      final response = await apiService
          .post(ApiConstants.postComments(postId), {
            'content': content,
            if (parentCommentId != null) 'parentCommentId': parentCommentId,
          });

      final raw = response.data['data'];
      final comment = PostCommentModel.fromJson(Map<String, dynamic>.from(raw));
      return comment.toEntity();
    } catch (e) {
      logger.e('Failed to add comment: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      await apiService.delete(ApiConstants.postCommentById(postId, commentId));
    } catch (e) {
      logger.e('Failed to delete comment: $e');
      rethrow;
    }
  }
}
