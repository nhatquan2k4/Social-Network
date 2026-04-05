import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/domain/entities/friend_entity.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';
import 'package:frontend/presentation/screens/chat/chat_screen.dart';

class PendingMessagesScreen extends StatefulWidget {
  const PendingMessagesScreen({super.key});

  @override
  State<PendingMessagesScreen> createState() => _PendingMessagesScreenState();
}

class _PendingMessagesScreenState extends State<PendingMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MockChatStore _chatStore = MockChatStore.instance;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F8),
        elevation: 0,
        title: Text(
          l10n.pendingMessages,
          style: const TextStyle(
            color: Color(0xFF171717),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.messagesSearchHint,
                hintStyle: const TextStyle(
                  color: Color(0xFF9A9AA1),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9A9AA1),
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xFFEDEDEF),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _chatStore,
              builder: (context, _) {
                final items = _chatStore.pendingConversations(
                  _searchController.text,
                );

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noConversationFound,
                      style: const TextStyle(
                        color: Color(0xFF7B7B80),
                        fontSize: 14,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: items.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final friendDisplayName = item.isGroup
                        ? item.username
                        : _chatStore.nicknameForFriend(item.id, item.username);
                    final timeLabel = _chatStore.formatRelativeTime(
                      item.lastMessageAt,
                    );

                    return Slidable(
                      key: ValueKey('pending_${item.id}'),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.42,
                        children: [
                          SlidableAction(
                            onPressed: (_) => _restoreConversation(item.id),
                            backgroundColor: const Color(0xFF34C759),
                            foregroundColor: Colors.white,
                            icon: Icons.undo_rounded,
                            label: 'Khôi phục',
                          ),
                          SlidableAction(
                            onPressed: (_) async {
                              final shouldDelete = await _confirmDeleteConversation();
                              if (!shouldDelete) return;
                              _chatStore.deleteConversation(item.id);
                              _showToast(l10n.chatDeleted);
                            },
                            backgroundColor: const Color(0xFFFF3B30),
                            foregroundColor: Colors.white,
                            icon: Icons.delete_outline,
                            label: l10n.deleteAction,
                          ),
                        ],
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _openChatFromPending(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          child: Row(
                            children: [
                              _conversationAvatar(item),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      friendDisplayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.2,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1C1C1C),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.lastPreviewText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Color(0xFF7B7B80),
                                        height: 1.25,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                timeLabel,
                                style: const TextStyle(
                                  color: Color(0xFF9B9BA1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _restoreConversation(String conversationId) {
    _chatStore.restoreConversation(conversationId);
  }

  void _openChatFromPending(MockConversation conversation) {
    _chatStore.markConversationRead(conversation.id);

    final friendDisplayName = conversation.isGroup
        ? conversation.username
        : _chatStore.nicknameForFriend(conversation.id, conversation.username);

    final friend = FriendEntity(
      id: conversation.id,
      username: conversation.username,
      displayName: friendDisplayName,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(friend: friend, conversationId: null),
      ),
    );
  }

  Future<bool> _confirmDeleteConversation() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.deleteAction),
          content: const Text('Bạn có chắc muốn xóa đoạn chat này không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(
                l10n.deleteAction,
                style: const TextStyle(color: Color(0xFFFF3B30)),
              ),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Widget _conversationAvatar(MockConversation conversation) {
    if (!conversation.isGroup) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: conversation.avatarColor,
        foregroundImage: AssetImage(conversation.avatarAssetPath),
        child: Text(
          conversation.username[0].toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
      );
    }

    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            child: CircleAvatar(
              radius: 17,
              backgroundColor: conversation.avatarColor,
              foregroundImage: AssetImage(conversation.avatarAssetPath),
            ),
          ),
          const Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFD8D8DE),
              child: Icon(Icons.group, size: 16, color: Color(0xFF66666C)),
            ),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}
