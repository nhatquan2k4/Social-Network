import '../../core/constants/api_constants.dart';
import '../../core/utils/logger.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../services/api_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final ApiService apiService;

  NotificationRepositoryImpl(this.apiService);

  @override
  Future<NotificationPageEntity> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await apiService.get(
        ApiConstants.notifications,
        queryParameters: {
          'page': page,
          'limit': limit,
          'unreadOnly': unreadOnly,
        },
      );

      final data = (response.data['data'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final rawItems = (data['items'] as List<dynamic>?) ?? const [];

      final items = rawItems
          .whereType<Map<dynamic, dynamic>>()
          .map((raw) => _mapNotification(Map<String, dynamic>.from(raw)))
          .toList(growable: false);

      return NotificationPageEntity(
        items: items,
        page: (data['page'] as num?)?.toInt() ?? page,
        limit: (data['limit'] as num?)?.toInt() ?? limit,
        total: (data['total'] as num?)?.toInt() ?? items.length,
        unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
        hasMore: data['hasMore'] == true,
      );
    } catch (e) {
      logger.e('Failed to fetch notifications: $e');
      rethrow;
    }
  }

  @override
  Future<NotificationEntity> markAsRead(String notificationId) async {
    try {
      final response = await apiService.patch(
        ApiConstants.notificationRead(notificationId),
        const {},
      );
      final raw = (response.data['data'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      return _mapNotification(raw);
    } catch (e) {
      logger.e('Failed to mark notification as read: $e');
      rethrow;
    }
  }

  @override
  Future<int> markAllAsRead() async {
    try {
      final response = await apiService.patch(
        ApiConstants.notificationsReadAll,
        const {},
      );
      return (response.data['modifiedCount'] as num?)?.toInt() ?? 0;
    } catch (e) {
      logger.e('Failed to mark all notifications as read: $e');
      rethrow;
    }
  }

  NotificationEntity _mapNotification(Map<String, dynamic> raw) {
    final actorRaw = (raw['actorId'] as Map<String, dynamic>?) ??
        const <String, dynamic>{};
    final actorId = actorRaw['_id']?.toString() ?? '';
    final username = actorRaw['username']?.toString() ?? '';
    final displayName = actorRaw['displayName']?.toString() ?? username;

    return NotificationEntity(
      id: raw['_id']?.toString() ?? '',
      actor: NotificationActorEntity(
        id: actorId,
        username: username,
        displayName: displayName,
        avatarUrl: actorRaw['avatarUrl']?.toString(),
      ),
      type: raw['type']?.toString() ?? 'UNKNOWN',
      title: raw['title']?.toString() ?? '',
      body: raw['body']?.toString() ?? '',
      entityType: raw['entityType']?.toString(),
      entityId: raw['entityId']?.toString(),
      metadata: raw['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(raw['metadata'] as Map<String, dynamic>)
          : null,
      isRead: raw['isRead'] == true,
      createdAt: DateTime.tryParse(raw['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
