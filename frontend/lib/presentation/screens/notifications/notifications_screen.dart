import 'package:flutter/material.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/domain/entities/notification_entity.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';
import 'package:frontend/presentation/providers/notification_provider.dart';
import 'package:frontend/presentation/screens/feed/post_detail_screen.dart';
import 'package:frontend/presentation/screens/profile/friend_profile_screen.dart';
import 'package:frontend/presentation/widgets/common/empty_state.dart';
import 'package:frontend/presentation/widgets/common/error_display.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<FeedProvider>().ensureLocalStateLoaded();
      context.read<NotificationProvider>().loadInitial();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      context.read<NotificationProvider>().loadMore();
    }
  }

  Future<void> _openActorProfile(NotificationEntity notification) async {
    final username = notification.actor.username.trim().isNotEmpty
        ? notification.actor.username.trim()
        : notification.actor.id;

    await Navigator.of(context).pushNamed(
      AppRoutes.profileFriend,
      arguments: FriendProfileArgs(
        userId: notification.actor.id,
        username: username,
        displayName: notification.actor.displayName,
        avatarUrl: notification.actor.avatarUrl,
      ),
    );
  }

  Future<void> _openNotificationContext(
    NotificationEntity notification,
  ) async {
    final entityType = (notification.entityType ?? '').trim().toLowerCase();
    final postId = _resolvePostId(notification);

    if ((entityType == 'post' || entityType == 'comment') &&
        postId != null &&
        postId.isNotEmpty) {
      final highlightCommentId = _resolveHighlightCommentId(notification);

      if (!mounted) return;

      await Navigator.of(context).pushNamed(
        AppRoutes.postDetail,
        arguments: PostDetailArgs(
          postId: postId,
          highlightCommentId: highlightCommentId,
          autoReplyCommentId: _resolveAutoReplyCommentId(notification),
          openCommentsOnLoad: highlightCommentId != null,
        ),
      );
      return;
    }

    await _openActorProfile(notification);
  }

  String? _resolvePostId(NotificationEntity notification) {
    final entityType = (notification.entityType ?? '').trim().toLowerCase();
    if (entityType == 'post') {
      return notification.entityId?.trim();
    }

    if (entityType == 'comment') {
      final metadata = notification.metadata;
      final postId = metadata?['postId']?.toString().trim();
      if (postId != null && postId.isNotEmpty) {
        return postId;
      }
    }

    return null;
  }

  String? _resolveHighlightCommentId(NotificationEntity notification) {
    final entityType = (notification.entityType ?? '').trim().toLowerCase();
    final metadata = notification.metadata;

    if (entityType == 'comment') {
      final replyCommentId = metadata?['replyCommentId']?.toString().trim();
      if (replyCommentId != null && replyCommentId.isNotEmpty) {
        return replyCommentId;
      }

      final parentCommentId = notification.entityId?.trim();
      if (parentCommentId != null && parentCommentId.isNotEmpty) {
        return parentCommentId;
      }
    }

    if (entityType == 'post') {
      final commentId = metadata?['commentId']?.toString().trim();
      if (commentId != null && commentId.isNotEmpty) {
        return commentId;
      }
    }

    return null;
  }

  String? _resolveAutoReplyCommentId(NotificationEntity notification) {
    if (notification.type != 'COMMENT_REPLIED') {
      return null;
    }

    final entityType = (notification.entityType ?? '').trim().toLowerCase();
    if (entityType != 'comment') {
      return null;
    }

    final parentCommentId = notification.entityId?.trim();
    if (parentCommentId == null || parentCommentId.isEmpty) {
      return null;
    }

    return parentCommentId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F4),
        surfaceTintColor: const Color(0xFFF2F2F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: const Text(
          'Thông báo',
          style: TextStyle(
            color: Color(0xFF1E1E23),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              return TextButton(
                onPressed: provider.unreadCount > 0
                    ? () => provider.markAllAsRead()
                    : null,
                child: Text(
                  'Đánh dấu đã đọc',
                  style: TextStyle(
                    color: provider.unreadCount > 0
                        ? const Color(0xFF1689F6)
                        : const Color(0xFF9A9AA1),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer2<NotificationProvider, FeedProvider>(
        builder: (context, notificationProvider, feedProvider, _) {
          if (notificationProvider.isLoadingInitial &&
              notificationProvider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationProvider.error != null &&
              notificationProvider.items.isEmpty) {
            return ErrorDisplay(
              message: notificationProvider.error!,
              onRetry: () => notificationProvider.loadInitial(),
            );
          }

          if (notificationProvider.items.isEmpty) {
            return const EmptyState.noNotifications();
          }

          final sections = _buildSections(notificationProvider.items);

          return RefreshIndicator(
            onRefresh: () => notificationProvider.refresh(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(0, 2, 0, 14),
              itemCount:
                  sections.length + (notificationProvider.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= sections.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }

                final section = sections[index];
                return _NotificationSection(
                  section: section,
                  isFollowing: (actorId) =>
                      feedProvider.isFollowingAuthor(actorId),
                  onToggleFollow: (actorId) {
                    feedProvider.toggleFollowAuthor(authorId: actorId);
                  },
                  onTapNotification: (notification) async {
                    await notificationProvider.markAsRead(notification.id);
                    if (!mounted) return;
                    await _openNotificationContext(notification);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<_NotificationSectionData> _buildSections(
    List<NotificationEntity> notifications,
  ) {
    final now = DateTime.now();
    final map = <String, List<NotificationEntity>>{};

    for (final item in notifications) {
      final localCreated = item.createdAt.toLocal();
      final dayDiff = now
          .difference(DateTime(localCreated.year, localCreated.month, localCreated.day))
          .inDays;

      final key = switch (dayDiff) {
        0 => 'Hôm nay',
        1 => 'Hôm qua',
        <= 7 => '7 ngày qua',
        <= 30 => '30 ngày qua',
        _ => 'Cũ hơn',
      };

      map.putIfAbsent(key, () => <NotificationEntity>[]).add(item);
    }

    const order = <String>['Hôm nay', 'Hôm qua', '7 ngày qua', '30 ngày qua', 'Cũ hơn'];

    return order
        .where(map.containsKey)
        .map((key) => _NotificationSectionData(title: key, items: map[key]!))
        .toList(growable: false);
  }
}

class _NotificationSectionData {
  const _NotificationSectionData({required this.title, required this.items});

  final String title;
  final List<NotificationEntity> items;
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({
    required this.section,
    required this.isFollowing,
    required this.onToggleFollow,
    required this.onTapNotification,
  });

  final _NotificationSectionData section;
  final bool Function(String actorId) isFollowing;
  final ValueChanged<String> onToggleFollow;
  final ValueChanged<NotificationEntity> onTapNotification;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Text(
            section.title,
            style: const TextStyle(
              color: Color(0xFF17171C),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ),
        ...section.items.map((notification) {
          return _NotificationTile(
            notification: notification,
            isFollowing: isFollowing(notification.actor.id),
            onToggleFollow: () => onToggleFollow(notification.actor.id),
            onTap: () => onTapNotification(notification),
          );
        }),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isFollowing,
    required this.onToggleFollow,
    required this.onTap,
  });

  final NotificationEntity notification;
  final bool isFollowing;
  final VoidCallback onToggleFollow;
  final VoidCallback onTap;

  bool get _showFollowButton {
    return notification.type == 'FRIEND_REQUEST' ||
        notification.type == 'FRIEND_ACCEPTED';
  }

  @override
  Widget build(BuildContext context) {
    final actorName = notification.actor.username.trim().isNotEmpty
        ? notification.actor.username.trim()
        : notification.actor.displayName.trim();

    final timeLabel = _timeAgo(notification.createdAt);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 14, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _ActorAvatar(notification: notification),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: const Color(0xFF2C2C31),
                        fontSize: 15,
                        fontWeight: notification.isRead
                            ? FontWeight.w400
                            : FontWeight.w500,
                        height: 1.18,
                      ),
                      children: [
                        TextSpan(
                          text: actorName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' ${notification.body}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeLabel,
                    style: const TextStyle(
                      color: Color(0xFF787880),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_showFollowButton) ...[
              const SizedBox(width: 10),
              _FollowActionButton(
                isFollowing: isFollowing,
                onTap: onToggleFollow,
              ),
            ] else if (!notification.isRead) ...[
              const SizedBox(width: 10),
              const Icon(
                Icons.circle,
                color: Color(0xFF1689F6),
                size: 9,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime.toLocal());

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes} phút';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours} giờ';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} ngày';
    }
    if (diff.inDays < 30) {
      return '${diff.inDays ~/ 7} tuần';
    }
    return '${diff.inDays ~/ 30} tháng';
  }
}

class _ActorAvatar extends StatelessWidget {
  const _ActorAvatar({required this.notification});

  final NotificationEntity notification;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = (notification.actor.avatarUrl ?? '').trim();
    final fallbackText = notification.actor.displayName.trim().isNotEmpty
        ? notification.actor.displayName.trim()[0].toUpperCase()
        : '?';

    return CircleAvatar(
      radius: 21,
      backgroundColor: const Color(0xFFD8D8DE),
      foregroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
      child: avatarUrl.isEmpty
          ? Text(
              fallbackText,
              style: const TextStyle(
                color: Color(0xFF2B2B30),
                fontWeight: FontWeight.w700,
              ),
            )
          : null,
    );
  }
}

class _FollowActionButton extends StatelessWidget {
  const _FollowActionButton({required this.isFollowing, required this.onTap});

  final bool isFollowing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isFollowing ? const Color(0xFFECECEF) : const Color(0xFF1689F6),
          foregroundColor:
              isFollowing ? const Color(0xFF1F1F23) : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        child: Text(isFollowing ? 'Đang theo dõi' : 'Theo dõi'),
      ),
    );
  }
}
