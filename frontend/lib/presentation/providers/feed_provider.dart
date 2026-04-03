import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/data/services/local_storage_service.dart';

import '../../domain/entities/post_comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/post_usecase.dart';

class FeedProvider extends ChangeNotifier {
  FeedProvider(this.postUsecase);

  final PostUsecase postUsecase;
  final LocalStorageService _localStorage = LocalStorageService();
  final List<PostEntity> _posts = [];
  final Set<String> _commentingPostIds = <String>{};
  final Set<String> _hiddenPostIds = <String>{};
  final Set<String> _followingAuthorIds = <String>{};
  final int _limit = 10;
  static const String _hiddenPostsKey = 'hidden_post_ids';
  static const String _followingAuthorsKey = 'following_author_ids';

  bool isLoadingInitial = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isCreatingPost = false;
  bool hasMore = true;
  bool requiresAuth = false;
  String? error;

  int _page = 1;
  bool _hiddenPostsLoaded = false;
  bool _followingAuthorsLoaded = false;

  UnmodifiableListView<PostEntity> get posts => UnmodifiableListView(_posts);
  UnmodifiableListView<PostEntity> get visiblePosts => UnmodifiableListView(
    _posts.where((post) => !_hiddenPostIds.contains(post.id)).toList(),
  );
  int get followingAuthorsCount => _followingAuthorIds.length;

  bool isPostHidden(String postId) => _hiddenPostIds.contains(postId);

  bool isFollowingAuthor(String authorId, {String? currentUserId}) {
    final normalizedAuthorId = authorId.trim();
    if (normalizedAuthorId.isEmpty) return false;

    final normalizedCurrentUserId = currentUserId?.trim();
    if (normalizedCurrentUserId != null &&
        normalizedCurrentUserId.isNotEmpty &&
        normalizedCurrentUserId == normalizedAuthorId) {
      return true;
    }

    return _followingAuthorIds.contains(normalizedAuthorId);
  }

  Future<void> _ensureHiddenPostsLoaded() async {
    if (_hiddenPostsLoaded) return;

    final stored = await _localStorage.getStringList(_hiddenPostsKey);
    _hiddenPostIds
      ..clear()
      ..addAll(stored.where((id) => id.trim().isNotEmpty));
    _hiddenPostsLoaded = true;
  }

  Future<void> _ensureFollowingAuthorsLoaded() async {
    if (_followingAuthorsLoaded) return;

    final stored = await _localStorage.getStringList(_followingAuthorsKey);
    _followingAuthorIds
      ..clear()
      ..addAll(stored.where((id) => id.trim().isNotEmpty));
    _followingAuthorsLoaded = true;
  }

  Future<void> ensureLocalStateLoaded() async {
    await _ensureHiddenPostsLoaded();
    await _ensureFollowingAuthorsLoaded();
  }

  Future<void> toggleFollowAuthor({
    required String authorId,
    String? currentUserId,
  }) async {
    final normalizedAuthorId = authorId.trim();
    if (normalizedAuthorId.isEmpty) return;

    final normalizedCurrentUserId = currentUserId?.trim();
    if (normalizedCurrentUserId != null &&
        normalizedCurrentUserId.isNotEmpty &&
        normalizedCurrentUserId == normalizedAuthorId) {
      return;
    }

    await _ensureFollowingAuthorsLoaded();

    if (_followingAuthorIds.contains(normalizedAuthorId)) {
      _followingAuthorIds.remove(normalizedAuthorId);
    } else {
      _followingAuthorIds.add(normalizedAuthorId);
    }

    await _localStorage.saveStringList(
      _followingAuthorsKey,
      _followingAuthorIds.toList(),
    );
    notifyListeners();
  }

  Future<void> hidePost(String postId) async {
    final normalizedId = postId.trim();
    if (normalizedId.isEmpty || _hiddenPostIds.contains(normalizedId)) return;

    _hiddenPostIds.add(normalizedId);
    await _localStorage.saveStringList(_hiddenPostsKey, _hiddenPostIds.toList());
    notifyListeners();
  }

  Future<void> reportPost({required String postId, required String reason}) async {
    final normalizedReason = reason.trim();
    if (normalizedReason.isEmpty) {
      error = 'Ly do bao cao khong hop le';
      notifyListeners();
      return;
    }

    try {
      await postUsecase.reportPost(postId: postId, reason: normalizedReason);
      error = null;
      notifyListeners();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;

      if (status == 401 || status == 403) {
        requiresAuth = true;
        error =
            message ?? 'Phien dang nhap da het han. Vui long dang nhap lai.';
      } else {
        error = message ?? 'Khong the gui bao cao';
      }

      notifyListeners();
    } catch (e) {
      error = 'Khong the gui bao cao: $e';
      notifyListeners();
    }
  }

  bool isCommenting(String postId) => _commentingPostIds.contains(postId);

  PostEntity? postById(String postId) {
    for (final post in _posts) {
      if (post.id == postId) {
        return post;
      }
    }
    return null;
  }

  Future<void> loadInitial() async {
    if (isLoadingInitial) return;

    await _ensureHiddenPostsLoaded();
    await _ensureFollowingAuthorsLoaded();

    isLoadingInitial = true;
    error = null;
    requiresAuth = false;
    notifyListeners();

    try {
      final items = await postUsecase.fetchFeed(page: 1, limit: _limit);
      _posts
        ..clear()
        ..addAll(items);
      _page = 1;
      hasMore = items.length >= _limit;
      requiresAuth = false;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;

      if (status == 401 || status == 403) {
        requiresAuth = true;
        error =
            message ?? 'Phien dang nhap da het han. Vui long dang nhap lai.';
      } else {
        error = message ?? 'Khong the tai bang tin';
      }
    } catch (e) {
      error = 'Khong the tai bang tin: $e';
    } finally {
      isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (isRefreshing) return;

    await _ensureHiddenPostsLoaded();
    await _ensureFollowingAuthorsLoaded();

    isRefreshing = true;
    error = null;
    requiresAuth = false;
    notifyListeners();

    try {
      final items = await postUsecase.fetchFeed(page: 1, limit: _limit);
      _posts
        ..clear()
        ..addAll(items);
      _page = 1;
      hasMore = items.length >= _limit;
      requiresAuth = false;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;

      if (status == 401 || status == 403) {
        requiresAuth = true;
        error =
            message ?? 'Phien dang nhap da het han. Vui long dang nhap lai.';
      } else {
        error = message ?? 'Khong the lam moi bang tin';
      }
    } catch (e) {
      error = 'Khong the lam moi bang tin: $e';
    } finally {
      isRefreshing = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore || isLoadingInitial || isRefreshing || !hasMore) {
      return;
    }

    await _ensureHiddenPostsLoaded();
    await _ensureFollowingAuthorsLoaded();

    isLoadingMore = true;
    notifyListeners();

    final nextPage = _page + 1;

    try {
      final items = await postUsecase.fetchFeed(page: nextPage, limit: _limit);

      if (items.isEmpty) {
        hasMore = false;
      } else {
        _posts.addAll(items);
        _page = nextPage;
        hasMore = items.length >= _limit;
      }
      requiresAuth = false;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;

      if (status == 401 || status == 403) {
        requiresAuth = true;
        error =
            message ?? 'Phien dang nhap da het han. Vui long dang nhap lai.';
      } else {
        error = message ?? 'Khong the tai them bai viet';
      }
    } catch (e) {
      error = 'Khong the tai them bai viet: $e';
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike({
    required String postId,
    required bool isCurrentlyLiked,
  }) async {
    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;

    try {
      final updatedPost = isCurrentlyLiked
          ? await postUsecase.unlikePost(postId)
          : await postUsecase.likePost(postId);

      _posts[index] = updatedPost;
      error = null;
      notifyListeners();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;

      if (status == 401 || status == 403) {
        requiresAuth = true;
        error =
            message ?? 'Phien dang nhap da het han. Vui long dang nhap lai.';
      } else {
        error = message ?? 'Khong the cap nhat trang thai thich bai viet';
      }

      notifyListeners();
    } catch (e) {
      error = 'Khong the cap nhat trang thai thich bai viet: $e';
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String content,
    List<String> imagePaths = const [],
  }) async {
    final normalizedContent = content.trim();
    final normalizedPaths = imagePaths
        .map((path) => path.trim())
        .where((path) => path.isNotEmpty)
        .toList(growable: false);

    if (normalizedContent.isEmpty && normalizedPaths.isEmpty) {
      error = 'Hay them noi dung hoac anh cho bai viet';
      notifyListeners();
      return false;
    }

    if (isCreatingPost) {
      return false;
    }

    isCreatingPost = true;
    error = null;
    notifyListeners();

    try {
      final createdPost = await postUsecase.createPost(
        normalizedContent,
        imagePaths: normalizedPaths,
      );
      _posts.insert(0, createdPost);
      error = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;

      if (status == 401 || status == 403) {
        requiresAuth = true;
        error =
            message ?? 'Phien dang nhap da het han. Vui long dang nhap lai.';
      } else {
        error = message ?? 'Khong the dang bai viet';
      }

      notifyListeners();
      return false;
    } catch (e) {
      error = 'Khong the dang bai viet: $e';
      notifyListeners();
      return false;
    } finally {
      isCreatingPost = false;
      notifyListeners();
    }
  }

  Future<bool> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    final normalizedContent = content.trim();
    if (normalizedContent.isEmpty) {
      error = 'Noi dung binh luan khong duoc de trong';
      notifyListeners();
      return false;
    }

    final index = _posts.indexWhere((post) => post.id == postId);
    if (index == -1) {
      error = 'Khong tim thay bai viet';
      notifyListeners();
      return false;
    }

    if (_commentingPostIds.contains(postId)) {
      return false;
    }

    _commentingPostIds.add(postId);
    error = null;
    notifyListeners();

    try {
      final createdComment = await postUsecase.addComment(
        postId,
        normalizedContent,
        parentCommentId: parentCommentId,
      );

      final post = _posts[index];
      final updatedComments = List<PostCommentEntity>.from(post.comments)
        ..add(createdComment);

      _posts[index] = PostEntity(
        id: post.id,
        authorId: post.authorId,
        authorUsername: post.authorUsername,
        authorDisplayName: post.authorDisplayName,
        authorAvatarUrl: post.authorAvatarUrl,
        content: post.content,
        media: post.media,
        likes: post.likes,
        comments: updatedComments,
        commentsCount: post.commentsCount + 1,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
      );

      error = null;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;

      if (status == 401 || status == 403) {
        requiresAuth = true;
        error =
            message ?? 'Phien dang nhap da het han. Vui long dang nhap lai.';
      } else {
        error = message ?? 'Khong the gui binh luan';
      }

      notifyListeners();
      return false;
    } catch (e) {
      error = 'Khong the gui binh luan: $e';
      notifyListeners();
      return false;
    } finally {
      _commentingPostIds.remove(postId);
      notifyListeners();
    }
  }

  void clearError() {
    error = null;
    notifyListeners();
  }
}
