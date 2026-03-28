import 'package:flutter/material.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';
import 'package:frontend/presentation/widgets/common/bell_status_icon.dart';

class ChatUserProfileScreen extends StatefulWidget {
  final String displayName;
  final String avatarAssetPath;
  final Color avatarColor;
  final List<String> mediaAssets;
  final int extraMediaCount;
  final String conversationId;

  const ChatUserProfileScreen({
    super.key,
    required this.displayName,
    required this.conversationId,
    this.avatarAssetPath = 'assets/images/logo1.jpg',
    this.avatarColor = const Color(0xFF7A6256),
    this.mediaAssets = const [],
    this.extraMediaCount = 0,
  });

  @override
  State<ChatUserProfileScreen> createState() => _ChatUserProfileScreenState();
}

class _ChatUserProfileScreenState extends State<ChatUserProfileScreen> {
  final MockChatStore _chatStore = MockChatStore.instance;
  final GlobalKey _optionAnchorKey = GlobalKey();

  MockConversation? get _conversation {
    return _chatStore.conversationById(widget.conversationId);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _chatStore,
      builder: (context, _) {
        final conversation = _conversation;
        final isBlocked = conversation?.isBlocked ?? false;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F4),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 17),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 2),
                  _buildHeaderAvatar(),
                  const SizedBox(height: 12),
                  _buildMainActionRow(),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFD8D8DD)),
                  _optionTile(icon: Icons.edit_outlined, label: 'Biệt danh'),
                  _optionTile(
                    icon: Icons.group_add_outlined,
                    label: 'Tạo nhóm chat',
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Ảnh và Video',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF242428),
                    ),
                  ),
                  const SizedBox(height: 7),
                  if (!isBlocked)
                    _buildMediaGrid()
                  else
                    _buildBlockedMediaHint(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderAvatar() {
    return Column(
      children: [
        Center(
          child: Container(
            width: 90,
            height: 90,
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFCACAD0)),
            ),
            child: CircleAvatar(
              backgroundColor: widget.avatarColor,
              foregroundImage: AssetImage(widget.avatarAssetPath),
              child: Text(
                widget.displayName.isNotEmpty
                    ? widget.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            widget.displayName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF222225),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionRow() {
    final conversation = _conversation;
    final isBlocked = conversation?.isBlocked ?? false;
    final isMuted = conversation?.isMuted ?? false;

    return Row(
      children: [
        Expanded(
          child: _actionIcon(
            icon: Icons.person_outline,
            label: 'Trang cá nhân',
            onTap: () {},
          ),
        ),
        Expanded(
          child: _actionIcon(
            icon: Icons.search,
            label: 'Tìm kiếm',
            onTap: _openSearchInChat,
          ),
        ),
        Expanded(
          child: _actionIcon(
            iconWidget: BellStatusIcon(
              isMuted: isMuted,
              size: 20,
              color: const Color(0xFF1D1D21),
            ),
            label: isMuted ? 'Đang tắt' : 'Tắt',
            onTap: _showMuteOptionsSheet,
          ),
        ),
        Expanded(
          child: _actionIcon(
            key: _optionAnchorKey,
            icon: Icons.more_horiz,
            label: 'Lựa chọn',
            onTap: () => _showOptionsMenu(isBlocked: isBlocked),
          ),
        ),
      ],
    );
  }

  Widget _actionIcon({
    Key? key,
    IconData? icon,
    Widget? iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          iconWidget ?? Icon(icon, size: 20, color: const Color(0xFF1D1D21)),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF3A3A3F)),
          ),
        ],
      ),
    );
  }

  Widget _optionTile({required IconData icon, required String label}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, size: 18, color: const Color(0xFF222225)),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F1F23),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFF86868C),
        size: 20,
      ),
      onTap: () {},
    );
  }

  Widget _buildMediaGrid() {
    final gridMedia = widget.mediaAssets.isNotEmpty
        ? widget.mediaAssets
        : const ['assets/images/logo1.jpg'];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 16,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final tile = ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: Image.asset(
            gridMedia[index % gridMedia.length],
            fit: BoxFit.cover,
          ),
        );

        if (index == 11) {
          return Stack(
            fit: StackFit.expand,
            children: [
              tile,
              Container(color: Colors.black.withValues(alpha: 0.34)),
              Center(
                child: Text(
                  '+${widget.extraMediaCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          );
        }

        return tile;
      },
    );
  }

  Widget _buildBlockedMediaHint() {
    return const Padding(
      padding: EdgeInsets.only(top: 10, bottom: 12),
      child: Center(
        child: Text(
          'Nội dung ảnh và video bị ẩn do bạn đã chặn tài khoản này.',
          style: TextStyle(color: Color(0xFF7D7D82), fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _showOptionsMenu({required bool isBlocked}) async {
    final contextObj = _optionAnchorKey.currentContext;
    if (contextObj == null) return;

    final renderBox = contextObj.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final rect = RelativeRect.fromRect(
      Rect.fromLTWH(offset.dx - 110, offset.dy + 26, 140, 80),
      Offset.zero & overlay.size,
    );

    final selected = await showMenu<String>(
      context: context,
      position: rect,
      color: const Color(0xFFF1F1F3),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      items: [
        PopupMenuItem<String>(
          value: 'restrict',
          child: Row(
            children: const [
              Icon(Icons.people_alt_outlined, size: 20),
              SizedBox(width: 10),
              Text('Hạn chế', style: TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: isBlocked ? 'unblock' : 'block',
          child: Row(
            children: [
              Icon(
                isBlocked ? Icons.person_remove_alt_1_outlined : Icons.block,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                isBlocked ? 'Bỏ chặn' : 'Chặn',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );

    if (!mounted || selected == null) return;

    if (selected == 'restrict') {
      _openSafetySettings();
      return;
    }

    if (selected == 'block') {
      await _showBlockBottomSheet(context);
      return;
    }

    if (selected == 'unblock') {
      await _showUnblockDialog(context);
    }
  }

  void _openSearchInChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChatSearchScreen(
          displayName: widget.displayName,
          conversationId: widget.conversationId,
          chatStore: _chatStore,
        ),
      ),
    );
  }

  Future<void> _showMuteOptionsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF4F4F6),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final conversation = _chatStore.conversationById(widget.conversationId);
        final isMuted = conversation?.isMuted ?? false;

        final options = <_MuteOption>[
          const _MuteOption(label: '10 phút', duration: Duration(minutes: 10)),
          const _MuteOption(label: '30 phút', duration: Duration(minutes: 30)),
          const _MuteOption(label: '1 giờ', duration: Duration(hours: 1)),
          const _MuteOption(label: '2 giờ', duration: Duration(hours: 2)),
          const _MuteOption(label: '12 giờ', duration: Duration(hours: 12)),
          const _MuteOption(label: '24 giờ', duration: Duration(hours: 24)),
          const _MuteOption(label: '48 giờ', duration: Duration(hours: 48)),
        ];

        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Tắt thông báo đoạn chat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isMuted) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _chatStore.clearMuteState(widget.conversationId);
                          Navigator.pop(sheetContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1689F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        child: const Text(
                          'Bật thông báo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Ưu tiên cao nhất: Hủy toàn bộ trạng thái tắt thông báo hiện tại.',
                      style: TextStyle(
                        color: Color(0xFF6C6C73),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  ...options.map(
                    (option) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        option.label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF222227),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Color(0xFF8B8B91),
                      ),
                      onTap: () {
                        if (option.duration != null) {
                          _chatStore.muteFor(
                            widget.conversationId,
                            option.duration!,
                          );
                        }
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _chatStore.muteUntilTurnedOn(widget.conversationId);
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF10D0D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text(
                        'Cho đến khi bật lại',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openSafetySettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChatSafetyScreen(
          displayName: widget.displayName,
          avatarAssetPath: widget.avatarAssetPath,
          avatarColor: widget.avatarColor,
          conversationId: widget.conversationId,
          chatStore: _chatStore,
        ),
      ),
    );
  }

  Future<void> _showBlockBottomSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _BlockBottomSheet(
          displayName: widget.displayName,
          avatarAssetPath: widget.avatarAssetPath,
          onConfirm: () {
            _chatStore.setBlocked(widget.conversationId, true);
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
      builder: (context) {
        return _UnblockDialog(
          displayName: widget.displayName,
          onConfirm: () {
            _chatStore.setBlocked(widget.conversationId, false);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _ChatSearchScreen extends StatefulWidget {
  final String displayName;
  final String conversationId;
  final MockChatStore chatStore;

  const _ChatSearchScreen({
    required this.displayName,
    required this.conversationId,
    required this.chatStore,
  });

  @override
  State<_ChatSearchScreen> createState() => _ChatSearchScreenState();
}

class _ChatSearchScreenState extends State<_ChatSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: widget.chatStore,
          builder: (context, _) {
            final results = _searchResults();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 12, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, size: 17),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            decoration: const InputDecoration(
                              hintText: 'Tìm trong cuộc trò chuyện',
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _query.trim().isEmpty
                      ? const Center(
                          child: Text(
                            'Nhập từ khóa để tìm tin nhắn',
                            style: TextStyle(
                              color: Color(0xFF7D7D84),
                              fontSize: 14,
                            ),
                          ),
                        )
                      : results.isEmpty
                      ? const Center(
                          child: Text(
                            'Không tìm thấy kết quả phù hợp',
                            style: TextStyle(
                              color: Color(0xFF7D7D84),
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                          itemCount: results.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final message = results[index];
                            final sender = message.isMe
                                ? 'Bạn'
                                : widget.displayName;

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              leading: const Icon(
                                Icons.chat_bubble_outline,
                                size: 18,
                                color: Color(0xFF6B6B71),
                              ),
                              title: _buildHighlightedContent(
                                message.content,
                                _query.trim(),
                              ),
                              subtitle: Text(
                                sender,
                                style: const TextStyle(
                                  color: Color(0xFF8A8A91),
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<MockChatMessage> _searchResults() {
    final normalized = _query.trim().toLowerCase();
    if (normalized.isEmpty) return const [];

    final allMessages = widget.chatStore
        .conversationMessages(widget.conversationId)
        .reversed
        .toList();

    return allMessages.where((m) {
      return m.content.toLowerCase().contains(normalized);
    }).toList();
  }

  Widget _buildHighlightedContent(String text, String keyword) {
    final normalizedText = text.toLowerCase();
    final normalizedKeyword = keyword.toLowerCase();
    final matchStart = normalizedText.indexOf(normalizedKeyword);

    if (keyword.isEmpty || matchStart < 0) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F1F23),
        ),
      );
    }

    final matchEnd = matchStart + keyword.length;
    final before = text.substring(0, matchStart);
    final matched = text.substring(matchStart, matchEnd);
    final after = text.substring(matchEnd);

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F1F23),
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: matched,
            style: const TextStyle(
              color: Color(0xFF1689F6),
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}

class _MuteOption {
  final String label;
  final Duration? duration;

  const _MuteOption({required this.label, this.duration});
}

class _ChatSafetyScreen extends StatelessWidget {
  final String displayName;
  final String avatarAssetPath;
  final Color avatarColor;
  final String conversationId;
  final MockChatStore chatStore;

  const _ChatSafetyScreen({
    required this.displayName,
    required this.avatarAssetPath,
    required this.avatarColor,
    required this.conversationId,
    required this.chatStore,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: chatStore,
      builder: (context, _) {
        final conversation = chatStore.conversationById(conversationId);
        final isBlocked = conversation?.isBlocked ?? false;
        final isRestricted = conversation?.isRestricted ?? false;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F4),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 17),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFCACAD0)),
                    ),
                    child: CircleAvatar(
                      backgroundColor: avatarColor,
                      foregroundImage: AssetImage(avatarAssetPath),
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(
                      child: _MiniAction(
                        icon: Icons.person_outline,
                        label: 'Trang cá nhân',
                      ),
                    ),
                    Expanded(
                      child: _MiniAction(icon: Icons.search, label: 'Tìm kiếm'),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 22),
                  child: Text(
                    'Người có thể liên hệ với bạn',
                    style: TextStyle(
                      fontSize: 32 / 1.78,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (!isBlocked)
                  _safetyTile(
                    icon: Icons.people_alt_outlined,
                    iconColor: const Color(0xFF1E1E22),
                    label: isRestricted ? 'Bỏ hạn chế' : 'Hạn chế',
                    labelColor: const Color(0xFF222227),
                    onTap: () =>
                        chatStore.setRestricted(conversationId, !isRestricted),
                  ),
                _safetyTile(
                  icon: Icons.block,
                  iconColor: const Color(0xFFE60000),
                  label: isBlocked ? 'Bỏ chặn tài khoản' : 'Chặn tài khoản',
                  labelColor: const Color(0xFFE60000),
                  onTap: () async {
                    if (isBlocked) {
                      await _showUnblockDialog(context);
                    } else {
                      await _showBlockBottomSheet(context);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _safetyTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color labelColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, size: 28, color: iconColor),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 31 / 2.0,
          color: labelColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        size: 30,
        color: Color(0xFF84848A),
      ),
      onTap: onTap,
    );
  }

  Future<void> _showBlockBottomSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _BlockBottomSheet(
          displayName: displayName,
          avatarAssetPath: avatarAssetPath,
          onConfirm: () {
            chatStore.setBlocked(conversationId, true);
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
        return _UnblockDialog(
          displayName: displayName,
          onConfirm: () {
            chatStore.setBlocked(conversationId, false);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 35 / 1.7),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class _BlockBottomSheet extends StatelessWidget {
  final String displayName;
  final String avatarAssetPath;
  final VoidCallback onConfirm;

  const _BlockBottomSheet({
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
            style: const TextStyle(
              fontSize: 39 / 2,
              fontWeight: FontWeight.w700,
            ),
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
          const _BlockPoint(
            icon: Icons.hide_source,
            text:
                'Họ sẽ không thể nhắn tin cho bạn hay tìm thấy\nđược trang cá nhân/nội dung của bạn.',
          ),
          const SizedBox(height: 12),
          const _BlockPoint(
            icon: Icons.notifications_off_outlined,
            text: 'Họ sẽ không được thông báo là bạn đã chặn họ.',
          ),
          const SizedBox(height: 18),
          _sheetButton(
            color: const Color(0xFF1689F6),
            text: 'Chặn',
            textColor: Colors.white,
            onTap: onConfirm,
          ),
          const SizedBox(height: 10),
          _sheetButton(
            color: const Color(0xFFF10D0D),
            text: 'Hủy',
            textColor: Colors.white,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _sheetButton({
    required Color color,
    required String text,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        child: Text(
          text,
          style: TextStyle(color: textColor, fontSize: 27 / 2),
        ),
      ),
    );
  }
}

class _BlockPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BlockPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 28 / 1.2),
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

class _UnblockDialog extends StatelessWidget {
  final String displayName;
  final VoidCallback onConfirm;

  const _UnblockDialog({required this.displayName, required this.onConfirm});

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
                fontSize: 33 / 1.7,
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
