import 'package:flutter/material.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';
import 'package:frontend/presentation/screens/profile/widgets/chat_block_bottom_sheet.dart';
import 'package:frontend/presentation/screens/profile/widgets/chat_unblock_dialog.dart';

class ChatSafetyScreen extends StatelessWidget {
  final String displayName;
  final String avatarAssetPath;
  final Color avatarColor;
  final String conversationId;
  final MockChatStore chatStore;

  const ChatSafetyScreen({
    super.key,
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
                const Row(
                  children: [
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
        return ChatBlockBottomSheet(
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
        return ChatUnblockDialog(
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
