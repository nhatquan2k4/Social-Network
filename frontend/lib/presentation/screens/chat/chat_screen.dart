import 'package:flutter/material.dart';
import 'package:frontend/data/services/local_storage_service.dart';
import 'package:frontend/domain/entities/friend_entity.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';
import 'package:frontend/presentation/widgets/common/state_widgets.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/logger.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/message_input.dart';
import '../profile/chat_user_profile_screen.dart';

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
  final MockChatStore _chatStore = MockChatStore.instance;

  String? _currentUserId;

  MockConversation? get _conversation {
    return _chatStore.conversationById(widget.friend.id);
  }

  bool get _isGroup {
    return _conversation?.isGroup ?? false;
  }

  String get _avatarAssetPath {
    return _conversation?.avatarAssetPath ?? 'assets/images/logo1.jpg';
  }

  Color get _avatarBgColor {
    return _conversation?.avatarColor ?? const Color(0xFF7A6256);
  }

  bool get _isBlocked {
    if (_isGroup) return false;
    return _conversation?.isBlocked ?? false;
  }

  bool get _isRestricted {
    if (_isGroup) return false;
    return _conversation?.isRestricted ?? false;
  }

  String get _friendDisplayName {
    return _chatStore.nicknameForFriend(
      widget.friend.id,
      widget.friend.displayName,
    );
  }

  String get _subtitleText {
    if (_isGroup) {
      final count = (_conversation?.memberNames.length ?? 0) + 1;
      return '$count thành viên';
    }
    return 'Đang hoạt động';
  }

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
        final decodedToken = JwtDecoder.decode(token);
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
    _chatStore.markConversationRead(widget.friend.id);

    if (widget.conversationId != null) {
      chatProvider.loadMessages();
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
                backgroundColor: _avatarBgColor,
                foregroundImage: AssetImage(_avatarAssetPath),
                child: Text(
                  _friendDisplayName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 9),
            GestureDetector(
              onTap: _isGroup ? _showGroupMembersSheet : _openUserProfile,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _friendDisplayName,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF222225),
                      height: 1.05,
                    ),
                  ),
                  Text(
                    _subtitleText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF87878D),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, size: 28, color: Color(0xFF2F2F34)),
            onPressed: () {},
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _chatStore,
        builder: (context, _) {
          final isBlocked = _isBlocked;
          final isRestricted = _isRestricted;

          return Column(
            children: [
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
                                  isSystem: false,
                                ),
                              )
                              .toList()
                        : _chatStore
                              .conversationMessages(widget.friend.id)
                              .map(
                                (m) => _DisplayMessage(
                                  content: m.content,
                                  isMe: m.isMe,
                                  isSystem: m.isSystem,
                                ),
                              )
                              .toList();

                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                      itemCount: displayMessages.length + (_isGroup ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_isGroup && index == 0) {
                          return _buildGroupIntroCard();
                        }

                        final messageIndex = _isGroup ? index - 1 : index;
                        final message = displayMessages[messageIndex];

                        return MessageBubble(
                          content: message.content,
                          isMe: message.isMe,
                          isSystem: message.isSystem,
                          showAvatar: !message.isMe && !message.isSystem,
                          friendName: _friendDisplayName,
                          friendAvatarAssetPath: _avatarAssetPath,
                          friendAvatarColor: _avatarBgColor,
                        );
                      },
                    );
                  },
                ),
              ),
              Consumer<ChatProvider>(
                builder: (context, chatProvider, child) {
                  return MessageInput(
                    controller: _messageController,
                    isSending: chatProvider.isSending,
                    onSend: (message) async {
                      if (widget.conversationId == null) {
                        _chatStore.appendOutgoingMessage(
                          conversationId: widget.friend.id,
                          content: message,
                        );
                        setState(() {});
                      } else {
                        await chatProvider.sendMessage(message);
                      }
                      _messageController.clear();
                      _scrollToBottom();
                    },
                  );
                },
              ),
              if (isBlocked || isRestricted)
                _buildSafetyBanner(
                  isBlocked: isBlocked,
                  isRestricted: isRestricted,
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGroupIntroCard() {
    final conversation = _conversation;
    final members = conversation?.memberNames ?? const <String>[];
    final createdAt = conversation?.createdAt ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: _avatarBgColor,
            foregroundImage: AssetImage(_avatarAssetPath),
          ),
          const SizedBox(height: 10),
          Text(
            members.join(', '),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF222225),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Đã tạo vào ${_formatClock(createdAt)} hôm nay',
            style: const TextStyle(fontSize: 11, color: Color(0xFF7F7F84)),
          ),
          const SizedBox(height: 9),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _miniAction(
                icon: Icons.link,
                label: 'Liên kết mời',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã sao chép liên kết mời nhóm'),
                    ),
                  );
                },
              ),
              const SizedBox(width: 18),
              _miniAction(
                icon: Icons.person_add_alt_1,
                label: 'Thêm người',
                onTap: _showGroupMembersSheet,
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _miniAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1C1D22)),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF1F1F23),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBanner({
    required bool isBlocked,
    required bool isRestricted,
  }) {
    final title = isBlocked
        ? 'Bạn đã chặn $_friendDisplayName'
        : 'Bạn đã hạn chế $_friendDisplayName';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F4),
        border: Border(top: BorderSide(color: Color(0xFFD8D8DD))),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1D22),
            ),
          ),
          const SizedBox(height: 3),
          const Text(
            'Họ sẽ không biết khi nào bạn online hoặc đọc tin nhắn của họ',
            style: TextStyle(fontSize: 12, color: Color(0xFF7A7A80)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isBlocked)
                _pillAction(
                  label: 'Chặn',
                  textColor: const Color(0xFFE60000),
                  onTap: () => _showBlockBottomSheet(context),
                ),
              if (!isBlocked) const SizedBox(width: 10),
              _pillAction(
                label: isBlocked ? 'Bỏ chặn' : 'Bỏ hạn chế',
                onTap: () {
                  if (isBlocked) {
                    _showUnblockDialog(context);
                  } else {
                    _chatStore.setRestricted(widget.friend.id, false);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pillAction({
    required String label,
    Color textColor = const Color(0xFF1D1D22),
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: const Color(0xFFE9E9EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 9),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatClock(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _showGroupMembersSheet() async {
    final members = _conversation?.memberNames ?? const <String>[];
    if (members.isEmpty) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF4F4F6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCFCFD4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thành viên nhóm (${members.length + 1})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F23),
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: const CircleAvatar(
                    radius: 18,
                    foregroundImage: AssetImage(
                      MockChatStore.currentUserAvatarAssetPath,
                    ),
                  ),
                  title: Text(
                    '${MockChatStore.currentUserDisplayName} (bạn)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ...members.map(
                  (name) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFD5D5DA),
                      child: Text(
                        name.isNotEmpty ? name[0] : '?',
                        style: const TextStyle(color: Color(0xFF3A3A40)),
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openUserProfile() {
    final media = _chatStore.mediaForConversation(widget.friend.id);
    final extraMedia = _chatStore.extraMediaCountForConversation(
      widget.friend.id,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatUserProfileScreen(
          displayName: _friendDisplayName,
          conversationId: widget.friend.id,
          avatarAssetPath: _avatarAssetPath,
          avatarColor: _avatarBgColor,
          mediaAssets: media,
          extraMediaCount: extraMedia,
        ),
      ),
    );
  }

  Future<void> _showBlockBottomSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _ChatBlockBottomSheet(
          displayName: _friendDisplayName,
          avatarAssetPath: _avatarAssetPath,
          onConfirm: () {
            _chatStore.setBlocked(widget.friend.id, true);
            Navigator.pop(context);
          },
        );
      },
    );
  }

  Future<void> _showUnblockDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (_) {
        return _ChatUnblockDialog(
          displayName: _friendDisplayName,
          onConfirm: () {
            _chatStore.setBlocked(widget.friend.id, false);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _DisplayMessage {
  final String content;
  final bool isMe;
  final bool isSystem;

  const _DisplayMessage({
    required this.content,
    required this.isMe,
    required this.isSystem,
  });
}

class _ChatBlockBottomSheet extends StatelessWidget {
  final String displayName;
  final String avatarAssetPath;
  final VoidCallback onConfirm;

  const _ChatBlockBottomSheet({
    required this.displayName,
    required this.avatarAssetPath,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
      decoration: const BoxDecoration(
        color: Color(0xFFF4F4F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 3,
            decoration: BoxDecoration(
              color: const Color(0xFFCCCCD1),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          CircleAvatar(
            radius: 44,
            foregroundImage: AssetImage(avatarAssetPath),
          ),
          const SizedBox(height: 14),
          Text(
            'Chặn $displayName?',
            style: const TextStyle(fontSize: 19.5, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          const Text(
            'Mọi tài khoản khác mà họ có thể sở hữu hoặc tạo trong tương lai\nđều bị chặn. Bạn có thể bỏ chặn họ bất cứ lúc nào.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF737378),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          const _ChatBlockPoint(
            icon: Icons.hide_source,
            text:
                'Họ sẽ không thể nhắn tin cho bạn hay tìm thấy\nđược trang cá nhân/nội dung của bạn.',
          ),
          const SizedBox(height: 12),
          const _ChatBlockPoint(
            icon: Icons.notifications_off_outlined,
            text: 'Họ sẽ không được thông báo là bạn đã chặn họ.',
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1689F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Chặn', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF10D0D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
              child: const Text('Hủy', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBlockPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ChatBlockPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 23),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16.5, height: 1.45),
          ),
        ),
      ],
    );
  }
}

class _ChatUnblockDialog extends StatelessWidget {
  final String displayName;
  final VoidCallback onConfirm;

  const _ChatUnblockDialog({
    required this.displayName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFF4F4F6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bỏ chặn $displayName?',
              style: const TextStyle(
                fontSize: 19.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Từ giờ, $displayName và các tài khoản khác mà\nhọ sở hữu hoặc tạo có thể yêu cầu theo dõi và nhắn tin\ncho bạn trên Mochi. Họ sẽ không được thông báo là bạn\nđã bỏ chặn họ.',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF707077),
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onConfirm,
              child: const Text(
                'Bỏ chặn',
                style: TextStyle(
                  color: Color(0xFFE60000),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: Color(0xFF1E1E23),
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
