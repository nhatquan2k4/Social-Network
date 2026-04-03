class NotificationActorEntity {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;

  NotificationActorEntity({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
  });
}

class NotificationEntity {
  final String id;
  final NotificationActorEntity actor;
  final String type;
  final String title;
  final String body;
  final String? entityType;
  final String? entityId;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;

  NotificationEntity({
    required this.id,
    required this.actor,
    required this.type,
    required this.title,
    required this.body,
    this.entityType,
    this.entityId,
    this.metadata,
    required this.isRead,
    required this.createdAt,
  });

  NotificationEntity copyWith({bool? isRead}) {
    return NotificationEntity(
      id: id,
      actor: actor,
      type: type,
      title: title,
      body: body,
      entityType: entityType,
      entityId: entityId,
      metadata: metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

class NotificationPageEntity {
  final List<NotificationEntity> items;
  final int page;
  final int limit;
  final int total;
  final int unreadCount;
  final bool hasMore;

  NotificationPageEntity({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.unreadCount,
    required this.hasMore,
  });
}
