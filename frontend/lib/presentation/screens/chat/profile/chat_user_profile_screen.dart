import 'package:flutter/material.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';
import 'package:frontend/presentation/screens/chat/group/chat_group_create_screen.dart';
import 'package:frontend/presentation/screens/chat/media/chat_media_gallery_screen.dart';
import 'package:frontend/presentation/screens/chat/media/chat_media_viewer_screen.dart';
import 'package:frontend/presentation/screens/chat/profile/chat_nickname_screen.dart';
import 'package:frontend/presentation/screens/chat/profile/chat_safety_screen.dart';
import 'package:frontend/presentation/screens/chat/search/chat_search_screen.dart';
import 'package:frontend/presentation/screens/chat/profile/widgets/chat_block_bottom_sheet.dart';
import 'package:frontend/presentation/screens/chat/profile/widgets/chat_unblock_dialog.dart';
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

  List<String> get _effectiveMediaAssets {
    if (widget.mediaAssets.isNotEmpty) return widget.mediaAssets;
    final fromStore = _chatStore.mediaForConversation(widget.conversationId);
    if (fromStore.isNotEmpty) return fromStore;
    return const ['assets/images/logo1.jpg'];
  }

  String get _friendUsername {
    return _conversation?.username ?? widget.displayName;
  }

  String get _friendDisplayNameForNickname {
    const map = {
      'thuytrng_04': 'Nguyễn Thùy Trang',
      'keociiu': 'Hoàng Tú',
      'dimhu27th4': 'Linh Trg',
    };
    return map[_friendUsername] ?? widget.displayName;
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
                  _optionTile(
                    icon: Icons.edit_outlined,
                    label: 'Biệt danh',
                    onTap: _openNicknameScreen,
                  ),
                  _optionTile(
                    icon: Icons.group_add_outlined,
                    label: 'Tạo nhóm chat',
                    onTap: _openCreateGroupScreen,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text(
                        'Ảnh và Video',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF242428),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: _openMediaGallery,
                        child: const Text(
                          'Xem tất cả',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1689F6),
                          ),
                        ),
                      ),
                    ],
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

  Widget _optionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
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
      onTap: onTap,
    );
  }

  Widget _buildMediaGrid() {
    final gridMedia = _effectiveMediaAssets;

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
          child: Hero(
            tag: mediaHeroTag(
              gridMedia[index % gridMedia.length],
              index % gridMedia.length,
            ),
            child: Image.asset(
              gridMedia[index % gridMedia.length],
              fit: BoxFit.cover,
            ),
          ),
        );

        if (index == 11) {
          return GestureDetector(
            onTap: _openMediaGallery,
            child: Stack(
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
            ),
          );
        }

        return GestureDetector(
          onTap: () => _openMediaViewerAt(index),
          child: tile,
        );
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

  void _openNicknameScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatNicknameScreen(
          conversationId: widget.conversationId,
          friendDisplayName: _friendDisplayNameForNickname,
          friendUsername: _friendUsername,
          friendAvatarAssetPath: widget.avatarAssetPath,
          chatStore: _chatStore,
        ),
      ),
    );
  }

  void _openCreateGroupScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatGroupCreateScreen(
          conversationId: widget.conversationId,
          currentFriendId: widget.conversationId,
          chatStore: _chatStore,
        ),
      ),
    );
  }

  void _openMediaGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatMediaGalleryScreen(
          displayName: widget.displayName,
          avatarAssetPath: widget.avatarAssetPath,
          mediaAssets: _effectiveMediaAssets,
        ),
      ),
    );
  }

  void _openMediaViewerAt(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatMediaViewerScreen(
          displayName: widget.displayName,
          avatarAssetPath: widget.avatarAssetPath,
          mediaAssets: _effectiveMediaAssets,
          initialIndex: index,
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
        builder: (_) => ChatSearchScreen(
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
        builder: (_) => ChatSafetyScreen(
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
        return ChatBlockBottomSheet(
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
        return ChatUnblockDialog(
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

class _MuteOption {
  final String label;
  final Duration? duration;

  const _MuteOption({required this.label, this.duration});
}
