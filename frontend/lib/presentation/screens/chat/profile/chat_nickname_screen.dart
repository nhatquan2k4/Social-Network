import 'package:flutter/material.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';

class ChatNicknameScreen extends StatelessWidget {
  final String conversationId;
  final String friendDisplayName;
  final String friendUsername;
  final String friendAvatarAssetPath;
  final MockChatStore chatStore;

  const ChatNicknameScreen({
    super.key,
    required this.conversationId,
    required this.friendDisplayName,
    required this.friendUsername,
    required this.friendAvatarAssetPath,
    required this.chatStore,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: chatStore,
      builder: (context, _) {
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
              'Biệt danh',
              style: TextStyle(
                color: Color(0xFF1F1F23),
                fontWeight: FontWeight.w700,
                fontSize: 30 / 2,
              ),
            ),
          ),
          body: Column(
            children: [
              _nicknameTile(
                context: context,
                avatarAssetPath: MockChatStore.currentUserAvatarAssetPath,
                title: chatStore.nicknameForSelf(conversationId),
                subtitle: MockChatStore.currentUserUsername,
                onTap: () => _showEditSheet(
                  context: context,
                  avatarAssetPath: MockChatStore.currentUserAvatarAssetPath,
                  targetName: MockChatStore.currentUserDisplayName,
                  initialValue: chatStore.nicknameForSelf(conversationId),
                  onDone: (value) => chatStore.setNicknameForSelf(
                    conversationId,
                    value,
                    actorName: MockChatStore.currentUserDisplayName,
                  ),
                ),
              ),
              _nicknameTile(
                context: context,
                avatarAssetPath: friendAvatarAssetPath,
                title: chatStore.nicknameForFriend(
                  conversationId,
                  friendDisplayName,
                ),
                subtitle: friendUsername,
                onTap: () => _showEditSheet(
                  context: context,
                  avatarAssetPath: friendAvatarAssetPath,
                  targetName: friendDisplayName,
                  initialValue: chatStore.nicknameForFriend(
                    conversationId,
                    friendDisplayName,
                  ),
                  onDone: (value) => chatStore.setNicknameForFriend(
                    conversationId,
                    value,
                    actorName: MockChatStore.currentUserDisplayName,
                    friendDisplayName: friendDisplayName,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _nicknameTile({
    required BuildContext context,
    required String avatarAssetPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 31 / 2,
              foregroundImage: AssetImage(avatarAssetPath),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF252529),
                      fontSize: 33 / 2,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8A8A90),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF8B8B90), size: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditSheet({
    required BuildContext context,
    required String avatarAssetPath,
    required String targetName,
    required String initialValue,
    required ValueChanged<String> onDone,
  }) async {
    final controller = TextEditingController(text: initialValue);

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
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(sheetContext),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 32 / 2,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E1E23),
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Chỉnh sửa biệt danh',
                      style: TextStyle(
                        fontSize: 32 / 2,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E1E23),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        final newValue = controller.text.trim();
                        final oldValue = initialValue.trim();
                        final hasChanged = newValue != oldValue;

                        onDone(controller.text);
                        Navigator.pop(sheetContext);

                        if (hasChanged) {
                          final snackText = newValue.isEmpty
                              ? 'Đã xóa biệt danh của $targetName'
                              : 'Đã cập nhật biệt danh của $targetName';

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(snackText),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Xong',
                        style: TextStyle(
                          fontSize: 32 / 2,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1689F6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFD9D9DD)),
              const SizedBox(height: 14),
              CircleAvatar(
                radius: 20,
                foregroundImage: AssetImage(avatarAssetPath),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Nhập biệt danh',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF1F1F23)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF1F1F23)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                        color: Color(0xFF1F1F23),
                        width: 1.2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 11,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mọi người trong đoạn chat đều sẽ nhìn thấy biệt danh này của $targetName.',
                style: const TextStyle(color: Color(0xFF808086), fontSize: 12),
              ),
              const SizedBox(height: 18),
            ],
          ),
        );
      },
    );
  }
}
