import 'package:flutter/material.dart';

/// Reusable empty state widget
///
/// Usage:
/// ```dart
/// EmptyState(message: 'Không có dữ liệu')
/// EmptyState.noMessages()
/// EmptyState.noFriends(onAction: () => showAddFriendDialog())
/// ```
class EmptyState extends StatelessWidget {
  final String message;
  final String? description;
  final IconData icon;
  final String? actionButtonText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.message,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionButtonText,
    this.onAction,
  });

  /// No messages preset
  const EmptyState.noMessages({super.key, this.actionButtonText, this.onAction})
    : message = 'Chưa có tin nhắn nào',
      description = 'Tin nhắn của bạn sẽ xuất hiện ở đây',
      icon = Icons.chat_bubble_outline;

  /// No conversations preset
  const EmptyState.noConversations({
    super.key,
    this.actionButtonText = 'Bắt đầu trò chuyện',
    this.onAction,
  }) : message = 'Không có cuộc trò chuyện nào',
       description = 'Nhấn nút bên dưới để bắt đầu chat với bạn bè',
       icon = Icons.forum_outlined;

  /// No friends preset
  const EmptyState.noFriends({
    super.key,
    this.actionButtonText = 'Tìm bạn bè',
    this.onAction,
  }) : message = 'Chưa có bạn bè',
       description = 'Hãy kết nối với những người bạn mới',
       icon = Icons.people_outline;

  /// No notifications preset
  const EmptyState.noNotifications({
    super.key,
    this.actionButtonText,
    this.onAction,
  }) : message = 'Chưa có thông báo',
       description = 'Bạn sẽ nhận được thông báo ở đây',
       icon = Icons.notifications_none;

  /// Search no results preset
  const EmptyState.searchNoResults({
    super.key,
    this.actionButtonText,
    this.onAction,
  }) : message = 'Không tìm thấy kết quả',
       description = 'Hãy thử tìm kiếm với từ khóa khác',
       icon = Icons.search_off;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionButtonText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(actionButtonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
