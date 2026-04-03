import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/notification_usecase.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this.notificationUsecase);

  final NotificationUsecase notificationUsecase;
  final List<NotificationEntity> _items = <NotificationEntity>[];

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
    notifyListeners();

    try {
      final updated = await notificationUsecase.markAsRead(notificationId);
      _items[index] = updated;
      notifyListeners();
    } catch (_) {
      _items[index] = oldItem;
      unreadCount += 1;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final hasUnread = _items.any((item) => !item.isRead);
    if (!hasUnread) return;

    final oldItems = List<NotificationEntity>.from(_items);
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    unreadCount = 0;
    notifyListeners();

    try {
      await notificationUsecase.markAllAsRead();
    } catch (_) {
      _items
        ..clear()
        ..addAll(oldItems);
      unreadCount = oldItems.where((item) => !item.isRead).length;
      notifyListeners();
    }
  }
}
