import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class NotificationUsecase {
  final NotificationRepository repository;

  NotificationUsecase(this.repository);

  Future<NotificationPageEntity> getNotifications({
    int page = 1,
    int limit = 20,
    bool unreadOnly = false,
  }) {
    return repository.getNotifications(
      page: page,
      limit: limit,
      unreadOnly: unreadOnly,
    );
  }

  Future<NotificationEntity> markAsRead(String notificationId) {
    return repository.markAsRead(notificationId);
  }

  Future<int> markAllAsRead() {
    return repository.markAllAsRead();
  }
}
