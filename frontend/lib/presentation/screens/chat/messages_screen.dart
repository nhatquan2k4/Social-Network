import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:frontend/domain/entities/friend_entity.dart';
import 'package:frontend/presentation/controllers/common/bottom_nav_route_controller.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';
import 'package:frontend/presentation/screens/chat/chat_screen.dart';
import 'package:frontend/presentation/screens/chat/group/chat_group_create_screen.dart';
import 'package:frontend/presentation/widgets/common/bottom_nav.dart';
import 'package:frontend/presentation/widgets/common/bell_status_icon.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _currentIndex = 3;
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
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'hoangtu_1',
              style: TextStyle(
                color: Color(0xFF171717),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, color: Color(0xFF1F1F1F), size: 18),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1F1F1F), size: 22),
            onPressed: _openQuickGroupCreate,
          ),
        ],
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.messagesTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191919),
                  ),
                ),
                Text(
                  l10n.pendingMessages,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3797EF),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _chatStore,
              builder: (context, _) {
                final items = _chatStore.visibleConversations(
                  _searchController.text,
                );

                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.noConversationFound,
                      style: const TextStyle(color: Color(0xFF7B7B80), fontSize: 14),
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
                    final muteStartedLabel = _formatMuteMoment(
                      item.mutedStartedAt,
                    );
                    final muteEndsLabel = item.muteUntilTurnedOn
                        ? 'đến khi bật lại'
                        : _formatMuteMoment(item.mutedUntil);

                    return Slidable(
                      key: ValueKey(item.id),
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        extentRatio: 0.62,
                        children: [
                          SlidableAction(
                            onPressed: (_) {
                              _chatStore.togglePin(item.id);
                              _showToast(
                                item.isPinned
                                    ? l10n.chatPinned
                                    : l10n.chatUnpinned,
                              );
                            },
                            backgroundColor: const Color(0xFF4A8BFF),
                            foregroundColor: Colors.white,
                            icon: item.isPinned
                                ? Icons.push_pin
                                : Icons.push_pin_outlined,
                            label: item.isPinned ? l10n.unpinAction : l10n.pinAction,
                          ),
                          SlidableAction(
                            onPressed: (_) {
                              _chatStore.hideConversation(item.id);
                              _showToast(l10n.chatHidden);
                            },
                            backgroundColor: const Color(0xFF8E8E93),
                            foregroundColor: Colors.white,
                            icon: Icons.visibility_off_outlined,
                            label: l10n.hideAction,
                          ),
                          SlidableAction(
                            onPressed: (_) {
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
                        onTap: () => _openChat(item),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
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
                                        ),
                                        if (item.isPinned)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Icon(
                                              Icons.push_pin,
                                              size: 13,
                                              color: Color(0xFF8D8D93),
                                            ),
                                          ),
                                        if (item.isOnline && !item.isGroup)
                                          Container(
                                            width: 7,
                                            height: 7,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF34C759),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    timeLabel,
                                    style: const TextStyle(
                                      color: Color(0xFF9B9BA1),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  if (item.isMuted)
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 6),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF3F8),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              BellStatusIcon(
                                                isMuted: true,
                                                size: 12,
                                                color: Color(0xFF5F6F82),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                l10n.mutedNow,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF4B5D73),
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (muteStartedLabel != null)
                                            Text(
                                              'BĐ: $muteStartedLabel',
                                              style: const TextStyle(
                                                fontSize: 9.5,
                                                color: Color(0xFF6C7A8A),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          if (muteEndsLabel != null)
                                            Text(
                                              'KT: $muteEndsLabel',
                                              style: const TextStyle(
                                                fontSize: 9.5,
                                                color: Color(0xFF6C7A8A),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  if (item.unreadCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF3797EF),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        item.unreadCount > 99
                                            ? '99+'
                                            : item.unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    )
                                  else
                                    const SizedBox(height: 16),
                                ],
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
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => BottomNavRouteController.handleTabSelection(
          context: context,
          currentIndex: _currentIndex,
          nextIndex: index,
          onIndexChanged: (next) => setState(() => _currentIndex = next),
          onUnsupportedDestination: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.pageNotImplemented)),
            );
          },
        ),
      ),
    );
  }

  void _openChat(MockConversation conversation) {
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

  void _openQuickGroupCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatGroupCreateScreen(chatStore: _chatStore),
      ),
    );
  }

  String? _formatMuteMoment(DateTime? moment) {
    if (moment == null) return null;
    final day = moment.day.toString().padLeft(2, '0');
    final month = moment.month.toString().padLeft(2, '0');
    final hour = moment.hour.toString().padLeft(2, '0');
    final minute = moment.minute.toString().padLeft(2, '0');
    return '$hour:$minute $day/$month';
  }
}
