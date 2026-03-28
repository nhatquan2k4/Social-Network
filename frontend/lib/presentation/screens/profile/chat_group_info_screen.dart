import 'package:flutter/material.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';
import 'package:frontend/presentation/screens/profile/chat_group_add_members_screen.dart';
import 'package:frontend/presentation/screens/profile/chat_group_avatar_picker_screen.dart';

class ChatGroupInfoScreen extends StatefulWidget {
  final String conversationId;
  final MockChatStore chatStore;

  const ChatGroupInfoScreen({
    super.key,
    required this.conversationId,
    required this.chatStore,
  });

  @override
  State<ChatGroupInfoScreen> createState() => _ChatGroupInfoScreenState();
}

class _ChatGroupInfoScreenState extends State<ChatGroupInfoScreen> {
  static const List<String> _avatarPool = [
    'assets/images/image 74.png',
    'assets/images/image 75.png',
    'assets/images/image 76.png',
    'assets/images/image 77.png',
    'assets/images/image 78.png',
    'assets/images/image 79.png',
    'assets/images/image 80.png',
    'assets/images/image 81.png',
    'assets/images/image 82.png',
    'assets/images/image 83.png',
    'assets/images/image 84.png',
    'assets/images/image 85.png',
    'assets/images/image 86.png',
    'assets/images/image 87.png',
    'assets/images/image 88.png',
    'assets/images/image 89.png',
    'assets/images/image 90.png',
    'assets/images/image 92.png',
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.chatStore,
      builder: (context, _) {
        final group = widget.chatStore.conversationById(widget.conversationId);
        if (group == null || !group.isGroup) {
          return Scaffold(
            backgroundColor: const Color(0xFFF2F2F4),
            appBar: AppBar(
              backgroundColor: const Color(0xFFF2F2F4),
              elevation: 0,
            ),
            body: const Center(
              child: Text(
                'Không tìm thấy thông tin nhóm',
                style: TextStyle(color: Color(0xFF7D7D84)),
              ),
            ),
          );
        }

        final memberConversations = group.memberIds
            .map(widget.chatStore.conversationById)
            .whereType<MockConversation>()
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F4),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF2F2F4),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 17),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Thông tin nhóm',
              style: TextStyle(
                color: Color(0xFF1F1F23),
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  foregroundImage: AssetImage(group.avatarAssetPath),
                  backgroundColor: group.avatarColor,
                ),
                const SizedBox(height: 10),
                Text(
                  group.username,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F23),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${group.memberNames.length + 1} thành viên',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7C7C84),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _actionTile(
                  icon: Icons.edit_outlined,
                  label: 'Đổi tên nhóm',
                  onTap: () => _showRenameSheet(group.username),
                ),
                _actionTile(
                  icon: Icons.photo_camera_back_outlined,
                  label: 'Đổi ảnh nhóm',
                  onTap: () => _changeAvatar(group.avatarAssetPath),
                ),
                _actionTile(
                  icon: Icons.person_add_alt_1,
                  label: 'Thêm thành viên',
                  onTap: _openAddMembers,
                ),
                const SizedBox(height: 6),
                const Divider(height: 1, color: Color(0xFFD8D8DD)),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Danh sách thành viên',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F1F23),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _memberTile(
                  avatarAssetPath: MockChatStore.currentUserAvatarAssetPath,
                  title: '${MockChatStore.currentUserDisplayName} (bạn)',
                  subtitle: MockChatStore.currentUserUsername,
                ),
                ...memberConversations.map(
                  (member) => _memberTile(
                    avatarAssetPath: member.avatarAssetPath,
                    title: _toDisplayName(member.username),
                    subtitle: member.username,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmLeaveGroup,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFFE9EA),
                      foregroundColor: const Color(0xFFE60000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Rời nhóm',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
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

  Widget _actionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF26262A)),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F1F23),
          fontSize: 14.5,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFF8A8A91)),
      onTap: onTap,
    );
  }

  Widget _memberTile({
    required String avatarAssetPath,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: CircleAvatar(
        radius: 19,
        foregroundImage: AssetImage(avatarAssetPath),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF26262B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A91)),
      ),
    );
  }

  Future<void> _showRenameSheet(String currentName) async {
    final controller = TextEditingController(text: currentName);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF2F2F4),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 14,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Đổi tên nhóm',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F1F23),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Nhập tên nhóm',
                  filled: true,
                  fillColor: const Color(0xFFE8E8EC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.chatStore.renameGroup(
                      widget.conversationId,
                      controller.text,
                    );
                    Navigator.pop(sheetContext);
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF1689F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _changeAvatar(String currentAvatar) async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => ChatGroupAvatarPickerScreen(
          avatarAssets: _avatarPool,
          selectedAsset: currentAvatar,
        ),
      ),
    );

    if (!mounted || selected == null) return;
    widget.chatStore.changeGroupAvatar(widget.conversationId, selected);
  }

  Future<void> _openAddMembers() async {
    final selected = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => ChatGroupAddMembersScreen(
          conversationId: widget.conversationId,
          chatStore: widget.chatStore,
        ),
      ),
    );

    if (!mounted || selected == null || selected.isEmpty) return;
    widget.chatStore.addMembersToGroup(widget.conversationId, selected);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã thêm thành viên vào nhóm')),
    );
  }

  Future<void> _confirmLeaveGroup() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF4F4F6),
          title: const Text('Rời nhóm?'),
          content: const Text(
            'Bạn sẽ không nhận được tin nhắn mới từ nhóm này nữa.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Rời nhóm',
                style: TextStyle(color: Color(0xFFE60000)),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLeave != true || !mounted) return;

    widget.chatStore.leaveGroup(widget.conversationId);
    Navigator.of(context).popUntil((route) => route.isFirst);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bạn đã rời nhóm')));
  }

  String _toDisplayName(String username) {
    final normalized = username.replaceAll(RegExp(r'[._]'), ' ').trim();
    final parts = normalized.split(RegExp(r'\s+'));
    return parts
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }
}
