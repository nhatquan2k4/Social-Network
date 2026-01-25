import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/friend_entity.dart';
import 'package:frontend/data/services/local_storage_service.dart';
import 'package:frontend/presentation/widgets/common/state_widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ChatScreen extends StatefulWidget {
  final FriendEntity friend;
  final String? conversationId;

  const ChatScreen({super.key, required this.friend, this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final LocalStorageService _localStorage = LocalStorageService();
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
  }

  Future<void> _loadCurrentUser() async {
    final token = await _localStorage.getToken();
    if (token != null) {
      try {
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        setState(() {
          _currentUserId =
              decodedToken['userId'] ??
              decodedToken['_id'] ??
              decodedToken['id'];
        });
      } catch (e) {
        print('Error decoding token: $e');
      }
    }
  }

  void _loadMessages() {
    final chatProvider = context.read<ChatProvider>();
    chatProvider.setConversation(widget.conversationId, widget.friend.id);
    if (widget.conversationId != null) {
      chatProvider.loadMessages();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                widget.friend.displayName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.friend.displayName,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  '@${widget.friend.username}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Implement video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Implement voice call
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show chat info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Message list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return const LoadingIndicator(
                    message: 'Đang tải tin nhắn...',
                  );
                }

                if (chatProvider.error != null) {
                  return ErrorDisplay(
                    message: chatProvider.error!,
                    onRetry: () => chatProvider.loadMessages(),
                  );
                }

                final messages = chatProvider.allMessages;

                if (messages.isEmpty) {
                  return EmptyState.noMessages(
                    onAction: () {
                      // Focus on input field
                    },
                  );
                }

                // Scroll to bottom after messages load
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == _currentUserId;

                    return MessageBubble(
                      message: message,
                      isMe: isMe,
                      showAvatar: !isMe,
                      friendName: widget.friend.displayName,
                    );
                  },
                );
              },
            ),
          ),

          // Message input
          Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return MessageInput(
                controller: _messageController,
                isSending: chatProvider.isSending,
                onSend: (message) async {
                  await chatProvider.sendMessage(message);
                  _messageController.clear();
                  _scrollToBottom();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
