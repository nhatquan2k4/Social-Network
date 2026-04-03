import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/presentation/controllers/common/bottom_nav_route_controller.dart';
import 'package:frontend/domain/entities/friend_entity.dart';
import 'package:frontend/presentation/widgets/common/bottom_nav.dart';
import 'package:frontend/presentation/widgets/common/loading_indicator.dart';
import 'package:frontend/presentation/widgets/common/error_display.dart';
import 'package:frontend/presentation/widgets/common/empty_state.dart';
import 'package:provider/provider.dart';
import 'package:frontend/presentation/providers/friend_provider.dart';
import 'package:frontend/presentation/providers/chat_provider.dart';
import 'package:frontend/presentation/screens/chat/chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _currentIndex = 3;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        context.read<MessagesProvider>().fetchFriends();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'hoangtu_1',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black,
              size: 20,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_box_outlined,
              color: Colors.black,
              size: 28,
            ),
            onPressed: () {
              // TODO: Handle new message
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.friendsSearchHint,
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tin nhắn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to pending messages
                  },
                  child: const Text(
                    'Tin nhắn đang chờ',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF3797EF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Conversations list
          Consumer<MessagesProvider>(
            builder: (context, provider, _) {
              // Loading state
              if (provider.isLoading) {
                return const LoadingIndicator(message: 'Đang tải danh sách...');
              }

              // Error state
              if (provider.error != null) {
                return ErrorDisplay(
                  message: provider.error!,
                  onRetry: () => provider.fetchFriends(),
                );
              }

              // Empty state
              if (provider.friends.isEmpty) {
                return const EmptyState.noConversations();
              }

              // Success state - show list
              return Expanded(
                child: ListView.builder(
                  itemCount: provider.friends.length,
                  itemBuilder: (context, index) {
                    final friend = provider.friends[index];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade300,
                        child: Text(
                          friend.displayName.isNotEmpty
                              ? friend.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      title: Text(
                        friend.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        l10n.placeholderLastMessage,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      trailing: const Text(
                        '2:45 PM',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      onTap: () {
                        _openChatWithFriend(context, friend);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;

          setState(() => _currentIndex = index);

          final targetRoute = BottomNavRouteController.routeForIndex(index);
          if (targetRoute == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.pageNotImplemented)),
            );
            return;
          }

          Navigator.pushReplacementNamed(context, targetRoute);
        },
      ),
    );
  }

  // Mở chat với friend (tạo conversation trước)
  Future<void> _openChatWithFriend(
    BuildContext context,
    FriendEntity friend,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chatProvider = context.read<ChatProvider>();

      // Tạo conversation
      await chatProvider.createAndLoadConversation(friend.id);

      // Close loading
      if (!context.mounted) return;
      Navigator.pop(context);

      // Navigate to chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            friend: friend,
            conversationId: chatProvider.currentConversationId,
          ),
        ),
      );
    } catch (e) {
      // Close loading
      if (!context.mounted) return;
      Navigator.pop(context);

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.cannotOpenChat(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
