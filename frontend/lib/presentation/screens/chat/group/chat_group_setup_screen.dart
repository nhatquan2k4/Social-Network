import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/domain/entities/friend_entity.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';
import 'package:frontend/presentation/screens/chat/chat_screen.dart';
import 'package:frontend/presentation/screens/chat/group/chat_group_avatar_picker_screen.dart';

class ChatGroupSetupScreen extends StatefulWidget {
  final List<String> selectedConversationIds;
  final MockChatStore chatStore;

  const ChatGroupSetupScreen({
    super.key,
    required this.selectedConversationIds,
    required this.chatStore,
  });

  @override
  State<ChatGroupSetupScreen> createState() => _ChatGroupSetupScreenState();
}

class _ChatGroupSetupScreenState extends State<ChatGroupSetupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  late final List<String> _selectedIds;
  String? _selectedAvatarAssetPath;

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
  void initState() {
    super.initState();
    _selectedIds = widget.selectedConversationIds.toSet().toList();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  bool get _canCreate => _selectedIds.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final selectedMembers = _selectedIds
        .map(widget.chatStore.conversationById)
        .whereType<MockConversation>()
        .toList();

    final defaultAvatarPath = selectedMembers.isNotEmpty
        ? selectedMembers.first.avatarAssetPath
        : MockChatStore.currentUserAvatarAssetPath;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F4),
        elevation: 0,
        title: Text(
          l10n.editGroupTitle,
          style: TextStyle(
            color: Color(0xFF1F1F23),
            fontWeight: FontWeight.w700,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            l10n.cancel,
            style: TextStyle(
              color: Color(0xFF1C1D22),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        leadingWidth: 70,
        actions: [
          TextButton(
            onPressed: !_canCreate ? null : _createGroup,
            child: Text(
              l10n.createAction,
              style: TextStyle(
                color: _canCreate
                    ? const Color(0xFF1689F6)
                    : const Color(0xFF98A0AA),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: GestureDetector(
              onTap: _openAvatarPicker,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    foregroundImage: AssetImage(
                      _selectedAvatarAssetPath ?? defaultAvatarPath,
                    ),
                    backgroundColor: const Color(0xFFD8D8DE),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D1D22),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFF2F2F4),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: l10n.groupNameHint,
                filled: true,
                fillColor: const Color(0xFFE8E8EC),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.invitedMembers,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Color(0xFF1F1F23),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 84,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: selectedMembers.length,
              itemBuilder: (context, index) {
                final member = selectedMembers[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _memberChip(member),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberChip(MockConversation member) {
    return SizedBox(
      width: 84,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22,
                foregroundImage: AssetImage(member.avatarAssetPath),
                backgroundColor: member.avatarColor,
              ),
              Positioned(
                right: -4,
                top: -4,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIds.remove(member.id);
                    });
                  },
                  child: Container(
                    width: 19,
                    height: 19,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _toDisplayName(member.username),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2A2A2E),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openAvatarPicker() async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => ChatGroupAvatarPickerScreen(
          avatarAssets: _avatarPool,
          selectedAsset: _selectedAvatarAssetPath,
        ),
      ),
    );

    if (selected == null || !mounted) return;
    setState(() {
      _selectedAvatarAssetPath = selected;
    });
  }

  void _createGroup() {
    if (_selectedIds.isEmpty) return;

    final conversation = widget.chatStore.createGroupConversation(
      memberConversationIds: _selectedIds,
      groupName: _groupNameController.text,
      groupAvatarAssetPath: _selectedAvatarAssetPath,
    );

    final displayName = conversation.username;

    final friend = FriendEntity(
      id: conversation.id,
      username: displayName,
      displayName: displayName,
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => ChatScreen(friend: friend, conversationId: null),
      ),
      (route) => route.isFirst,
    );
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
