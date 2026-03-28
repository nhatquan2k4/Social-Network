import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/friend_entity.dart';
import 'package:frontend/data/services/local_storage_service.dart';
import 'package:frontend/presentation/widgets/common/state_widgets.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../../../core/utils/logger.dart';

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

  static const List<String> _topics = [
    'đi cafe',
    'đi ăn tối',
    'làm đồ án',
    'tập gym',
    'xem phim',
    'đi dạo',
    'học nhóm',
    'chụp ảnh',
    'đi biển',
    'test app',
    'review code',
    'deploy bản mới',
    'đi mua đồ',
    'ăn khuya',
    'đổi lịch họp',
    'sắp xếp công việc',
    'đặt vé xe',
    'lên kế hoạch tuần',
    'update task',
    'đi chơi cuối tuần',
  ];

  static const List<String> _openers = [
    'nay rảnh không',
    'tối nay ổn không',
    'mình bàn chút nha',
    'mai mình gặp nhau nhé',
    'có kế hoạch gì chưa',
    'mình vừa nghĩ ra cái này',
  ];

  static const List<String> _responses = [
    'ok luôn nè',
    'được đó, nghe hợp lý á',
    'để mình sắp xếp tí nha',
    'quá ổn, chốt luôn',
    'mình thích ý này',
    'nghe vui ghê đó',
  ];

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
        logger.e('Error decoding token: $e', error: e);
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
      backgroundColor: const Color(0xFFF2F2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFCFCFD3), width: 1),
              ),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF7A6256),
                child: Text(
                  widget.friend.displayName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 9),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.friend.displayName,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF222225),
                    height: 1.05,
                  ),
                ),
                const Text(
                  'Đang hoạt động',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF87878D),
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28, color: Color(0xFF2F2F34)),
            onPressed: () {
              // TODO: Show add actions
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
                final hasServerMessages = messages.isNotEmpty;
                final displayMessages = hasServerMessages
                    ? messages
                          .map(
                            (m) => _DisplayMessage(
                              content: m.content,
                              isMe: m.senderId == _currentUserId,
                            ),
                          )
                          .toList()
                    : _buildMockMessagesForFriend(widget.friend)
                          .map(
                            (m) => _DisplayMessage(
                              content: m.content,
                              isMe: m.isMe,
                            ),
                          )
                          .toList();

                // Scroll to bottom after messages load
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                  itemCount: displayMessages.length,
                  itemBuilder: (context, index) {
                    final message = displayMessages[index];

                    return MessageBubble(
                      content: message.content,
                      isMe: message.isMe,
                      showAvatar: !message.isMe,
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

  List<_MockChatMessage> _buildMockMessagesForFriend(FriendEntity friend) {
    final index = _friendIndex(friend.id);
    final topic = _topics[index % _topics.length];
    final opener = _openers[index % _openers.length];
    final response = _responses[(index + 2) % _responses.length];
    final altResponse = _responses[(index + 4) % _responses.length];

    return [
      _MockChatMessage('$opener, mình $topic nha?', false),
      _MockChatMessage('$response ${friend.displayName}', true),
      _MockChatMessage('mình tính khoảng ${18 + (index % 4)}h bắt đầu', false),
      _MockChatMessage(
        'ok, để mình chuẩn bị trước\nrồi nhắn lại cho $topic nhé',
        true,
      ),
      _MockChatMessage('nhớ mang thêm nước nha :))', false),
      _MockChatMessage('yên tâm, mình có mang rồi nè', true),
      _MockChatMessage('nếu mưa thì mình đổi sang kế hoạch B', false),
      _MockChatMessage('được luôn, $altResponse', true),
      _MockChatMessage('thế mình chốt vậy nha', false),
      _MockChatMessage('ok chốt! gặp bạn sau nha', true),
    ];
  }

  int _friendIndex(String id) {
    final value = id.replaceFirst('mock_', '');
    return int.tryParse(value) ?? 0;
  }
}

class _MockChatMessage {
  final String content;
  final bool isMe;

  const _MockChatMessage(this.content, this.isMe);
}

class _DisplayMessage {
  final String content;
  final bool isMe;

  const _DisplayMessage({required this.content, required this.isMe});
}
