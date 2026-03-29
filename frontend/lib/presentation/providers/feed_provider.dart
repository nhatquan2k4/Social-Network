import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/post_comment_entity.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/usecases/post_usecase.dart';

class FeedProvider extends ChangeNotifier {
  FeedProvider(this.postUsecase);

  final PostUsecase postUsecase;
  final List<PostEntity> _posts = [];
  final Set<String> _commentingPostIds = <String>{};
  final int _limit = 10;

  bool isLoadingInitial = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isCreatingPost = false;
  bool hasMore = true;
  bool requiresAuth = false;
  String? error;

  int _page = 1;

  UnmodifiableListView<PostEntity> get posts => UnmodifiableListView(_posts);

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
