import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/notification_usecase.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this.notificationUsecase);

  final NotificationUsecase notificationUsecase;
  final List<NotificationEntity> _items = <NotificationEntity>[];
  final List<NotificationEntity> _mockPool = _buildMockNotifications();

  // Set to false when you want to use real backend notifications again.
  static const bool _useMockNotifications = true;

  static const int _pageSize = 20;

  bool isLoadingInitial = false;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? error;

  int _page = 1;
  int unreadCount = 0;

  UnmodifiableListView<NotificationEntity> get items =>
      UnmodifiableListView(_items);

  Future<void> syncUnreadCount() async {
    if (_useMockNotifications) {
      unreadCount = _mockPool.where((item) => !item.isRead).length;
      notifyListeners();
      return;
    }

    try {
      final result = await notificationUsecase.getNotifications(page: 1, limit: 1);
      unreadCount = result.unreadCount;
      notifyListeners();
    } catch (_) {
      // Keep current unread badge when sync fails.
    }
  }

  Future<void> loadInitial() async {
    if (isLoadingInitial) return;

    isLoadingInitial = true;
    error = null;
    notifyListeners();

    try {
      if (_useMockNotifications) {
        _loadMockPage(page: 1, reset: true);
        error = null;
        return;
      }

      final result = await notificationUsecase.getNotifications(
        page: 1,
        limit: _pageSize,
      );

      _items
        ..clear()
        ..addAll(result.items);
      _page = result.page;
      unreadCount = result.unreadCount;
      hasMore = result.hasMore;
      error = null;
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message']?.toString()
          : null;
      error = message ?? 'Khong the tai thong bao';
    } catch (_) {
      error = 'Khong the tai thong bao';
    } finally {
      isLoadingInitial = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (isRefreshing) return;

    isRefreshing = true;
    error = null;
    notifyListeners();

    try {
      if (_useMockNotifications) {
        _loadMockPage(page: 1, reset: true);
        error = null;
        return;
      }

      final result = await notificationUsecase.getNotifications(
        page: 1,
        limit: _pageSize,
      );

      _items
        ..clear()
        ..addAll(result.items);
      _page = result.page;
      unreadCount = result.unreadCount;
      hasMore = result.hasMore;
      error = null;
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message']?.toString()
          : null;
      error = message ?? 'Khong the lam moi thong bao';
    } catch (_) {
      error = 'Khong the lam moi thong bao';
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
      if (_useMockNotifications) {
        _loadMockPage(page: nextPage, reset: false);
        error = null;
        return;
      }

      final result = await notificationUsecase.getNotifications(
        page: nextPage,
        limit: _pageSize,
      );
      _items.addAll(result.items);
      _page = result.page;
      unreadCount = result.unreadCount;
      hasMore = result.hasMore;
      error = null;
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? e.response?.data['message']?.toString()
          : null;
      error = message ?? 'Khong the tai them thong bao';
    } catch (_) {
      error = 'Khong the tai them thong bao';
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _items.indexWhere((item) => item.id == notificationId);
    if (index == -1) return;
    if (_items[index].isRead) return;

    final oldItem = _items[index];
    _items[index] = oldItem.copyWith(isRead: true);
    if (unreadCount > 0) unreadCount -= 1;
    _replaceMockItem(_items[index]);
    notifyListeners();

    if (_useMockNotifications) {
      return;
    }

    try {
      final updated = await notificationUsecase.markAsRead(notificationId);
      _items[index] = updated;
      _replaceMockItem(updated);
      notifyListeners();
    } catch (_) {
      _items[index] = oldItem;
      unreadCount += 1;
      _replaceMockItem(oldItem);
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final hasUnread = _items.any((item) => !item.isRead);
    if (!hasUnread) return;

    final oldItems = List<NotificationEntity>.from(_items);
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
      _replaceMockItem(_items[i]);
    }
    unreadCount = 0;
    notifyListeners();

    if (_useMockNotifications) {
      return;
    }

    try {
      await notificationUsecase.markAllAsRead();
    } catch (_) {
      _items
        ..clear()
        ..addAll(oldItems);
      unreadCount = oldItems.where((item) => !item.isRead).length;
      for (final item in oldItems) {
        _replaceMockItem(item);
      }
      notifyListeners();
    }
  }

  void _replaceMockItem(NotificationEntity updated) {
    final index = _mockPool.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    _mockPool[index] = updated;
  }

  void _loadMockPage({required int page, required bool reset}) {
    if (reset) {
      _items.clear();
    }

    final start = (page - 1) * _pageSize;
    if (start >= _mockPool.length) {
      _page = page;
      hasMore = false;
      unreadCount = _mockPool.where((item) => !item.isRead).length;
      return;
    }

    final end = (start + _pageSize).clamp(0, _mockPool.length);
    final pageItems = _mockPool.sublist(start, end);
    _items.addAll(pageItems);
    _page = page;
    hasMore = end < _mockPool.length;
    unreadCount = _mockPool.where((item) => !item.isRead).length;
  }

  static List<NotificationEntity> _buildMockNotifications() {
    final now = DateTime.now();

    NotificationActorEntity actor(
      String id,
      String username,
      String displayName,
      String? avatarUrl,
    ) {
      return NotificationActorEntity(
        id: id,
        username: username,
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
    }

    return <NotificationEntity>[
      NotificationEntity(
        id: 'mock_noti_001',
        actor: actor('u_anna', 'anna.tran', 'Anna Tran', null),
        type: 'COMMENT_REPLIED',
        title: 'Tra loi binh luan',
        body: 'da tra loi binh luan cua ban',
        entityType: 'comment',
        entityId: 'comment_parent_11',
        metadata: {'postId': 'post_001', 'replyCommentId': 'comment_reply_77'},
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      NotificationEntity(
        id: 'mock_noti_002',
        actor: actor('u_minh', 'minh.nguyen', 'Minh Nguyen', null),
        type: 'POST_LIKED',
        title: 'Yeu thich bai viet',
        body: 'da thich bai viet cua ban',
        entityType: 'post',
        entityId: 'post_002',
        metadata: null,
        isRead: false,
        createdAt: now.subtract(const Duration(minutes: 22)),
      ),
      NotificationEntity(
        id: 'mock_noti_003',
        actor: actor('u_hoang', 'hoang.k', 'Hoang K', null),
        type: 'POST_COMMENTED',
        title: 'Binh luan moi',
        body: 'da binh luan bai viet cua ban',
        entityType: 'post',
        entityId: 'post_003',
        metadata: {'commentId': 'comment_301'},
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      NotificationEntity(
        id: 'mock_noti_004',
        actor: actor('u_lan', 'lanpham', 'Lan Pham', null),
        type: 'FRIEND_REQUEST',
        title: 'Loi moi ket ban',
        body: 'muon ket ban voi ban',
        entityType: null,
        entityId: null,
        metadata: null,
        isRead: false,
        createdAt: now.subtract(const Duration(hours: 7)),
      ),
      NotificationEntity(
        id: 'mock_noti_005',
        actor: actor('u_quynh', 'quynh.le', 'Quynh Le', null),
        type: 'FRIEND_ACCEPTED',
        title: 'Chap nhan ket ban',
        body: 'da chap nhan loi moi ket ban cua ban',
        entityType: null,
        entityId: null,
        metadata: null,
        isRead: true,
        createdAt: now.subtract(const Duration(hours: 18)),
      ),
      NotificationEntity(
        id: 'mock_noti_006',
        actor: actor('u_huy', 'huypham', 'Huy Pham', null),
        type: 'COMMENT_REPLIED',
        title: 'Tra loi binh luan',
        body: 'da tra loi binh luan cua ban',
        entityType: 'comment',
        entityId: 'comment_parent_21',
        metadata: {'postId': 'post_001', 'replyCommentId': 'comment_reply_88'},
        isRead: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      NotificationEntity(
        id: 'mock_noti_007',
        actor: actor('u_thao', 'thao.ng', 'Thao Nguyen', null),
        type: 'POST_LIKED',
        title: 'Yeu thich bai viet',
        body: 'da thich bai viet cua ban',
        entityType: 'post',
        entityId: 'post_004',
        metadata: null,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      NotificationEntity(
        id: 'mock_noti_008',
        actor: actor('u_tung', 'tung.tran', 'Tung Tran', null),
        type: 'POST_COMMENTED',
        title: 'Binh luan moi',
        body: 'da binh luan bai viet cua ban',
        entityType: 'post',
        entityId: 'post_003',
        metadata: {'commentId': 'comment_355'},
        isRead: false,
        createdAt: now.subtract(const Duration(days: 3, hours: 4)),
      ),
      NotificationEntity(
        id: 'mock_noti_009',
        actor: actor('u_my', 'my.vo', 'My Vo', null),
        type: 'FRIEND_REQUEST',
        title: 'Loi moi ket ban',
        body: 'muon ket ban voi ban',
        entityType: null,
        entityId: null,
        metadata: null,
        isRead: true,
        createdAt: now.subtract(const Duration(days: 6, hours: 2)),
      ),
      NotificationEntity(
        id: 'mock_noti_010',
        actor: actor('u_viet', 'viet.do', 'Viet Do', null),
        type: 'POST_LIKED',
        title: 'Yeu thich bai viet',
        body: 'da thich bai viet cua ban',
        entityType: 'post',
        entityId: 'post_006',
        metadata: null,
        isRead: false,
        createdAt: now.subtract(const Duration(days: 9)),
      ),
      NotificationEntity(
        id: 'mock_noti_011',
        actor: actor('u_phuc', 'phuc.luu', 'Phuc Luu', null),
        type: 'POST_COMMENTED',
        title: 'Binh luan moi',
        body: 'da binh luan bai viet cua ban',
        entityType: 'post',
        entityId: 'post_007',
        metadata: {'commentId': 'comment_401'},
        isRead: true,
        createdAt: now.subtract(const Duration(days: 15, hours: 5)),
      ),
      NotificationEntity(
        id: 'mock_noti_012',
        actor: actor('u_mai', 'mai.phan', 'Mai Phan', null),
        type: 'COMMENT_REPLIED',
        title: 'Tra loi binh luan',
        body: 'da tra loi binh luan cua ban',
        entityType: 'comment',
        entityId: 'comment_parent_71',
        metadata: {'postId': 'post_009', 'replyCommentId': 'comment_reply_501'},
        isRead: true,
        createdAt: now.subtract(const Duration(days: 35)),
      ),
    ];
  }
}
