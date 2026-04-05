import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';
import 'package:frontend/presentation/screens/chat/group/chat_group_add_members_screen.dart';
import 'package:frontend/presentation/screens/chat/group/chat_group_avatar_picker_screen.dart';
import 'package:frontend/presentation/screens/chat/group/chat_group_member_profile_screen.dart';
import 'package:frontend/presentation/screens/chat/media/chat_media_gallery_screen.dart';
import 'package:frontend/presentation/screens/chat/search/chat_search_screen.dart';

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
    final l10n = context.l10n;

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
            body: Center(
              child: Text(
                l10n.groupNotFound,
                style: const TextStyle(color: Color(0xFF7D7D84)),
              ),
            ),
          );
        }

        final memberConversations = group.memberIds
            .map(widget.chatStore.conversationById)
            .whereType<MockConversation>()
            .toList();
        final canManage = widget.chatStore.isCurrentUserGroupAdmin(
          widget.conversationId,
        );
        final canLeave = widget.chatStore.canCurrentUserLeaveGroup(
          widget.conversationId,
        );

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
            title: Text(
              l10n.chatGroupInfoTitle,
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
                  l10n.membersCount((group.memberNames.length + 1).toString()),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7C7C84),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                _actionTile(
                  icon: Icons.edit_outlined,
                  label: l10n.groupRename,
                  enabled: canManage,
                  onTap: () => _showRenameSheet(group.username),
                ),
                _actionTile(
                  icon: Icons.photo_camera_back_outlined,
                  label: l10n.groupChangeAvatar,
                  enabled: canManage,
                  onTap: () => _changeAvatar(group.avatarAssetPath),
                ),
                _actionTile(
                  icon: Icons.person_add_alt_1,
                  label: l10n.addMember,
                  enabled: canManage,
                  onTap: _openAddMembers,
                ),
                _actionTile(
                  icon: Icons.search,
                  label: l10n.searchMessages,
                  onTap: _openSearchInChat,
                ),
                _actionTile(
                  icon: Icons.photo_library_outlined,
                  label: l10n.photosAndVideos,
                  onTap: _openMediaGallery,
                ),
                if (!canManage)
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l10n.adminOnlyManageGroupInfo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A8A91),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                const Divider(height: 1, color: Color(0xFFD8D8DD)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.memberList,
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
                  title: '${MockChatStore.currentUserDisplayName} (${l10n.youSuffix})',
                  subtitle: MockChatStore.currentUserUsername,
                  roleLabel:
                      widget.chatStore.isGroupMemberAdmin(
                        widget.conversationId,
                        MockChatStore.currentUserId,
                      )
                      ? l10n.adminRole
                      : l10n.memberRole,
                  onTap: () => _openMemberProfile(
                    memberId: MockChatStore.currentUserId,
                    username: MockChatStore.currentUserUsername,
                    displayName: MockChatStore.currentUserDisplayName,
                    avatarAssetPath: MockChatStore.currentUserAvatarAssetPath,
                  ),
                ),
                ...memberConversations.map(
                  (member) => _memberTile(
                    onTap: () => _openMemberProfile(
                      memberId: member.id,
                      username: member.username,
                      displayName: _toDisplayName(member.username),
                      avatarAssetPath: member.avatarAssetPath,
                    ),
                    avatarAssetPath: member.avatarAssetPath,
                    title: _toDisplayName(member.username),
                    subtitle: member.username,
                    roleLabel:
                        widget.chatStore.isGroupMemberAdmin(
                          widget.conversationId,
                          member.id,
                        )
                        ? l10n.adminRole
                        : l10n.memberRole,
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
                    child: Text(
                      l10n.leaveGroup,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                if (!canLeave)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.lastAdminCannotLeave,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A8A91),
                        fontWeight: FontWeight.w500,
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
    bool enabled = true,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: enabled ? const Color(0xFF26262A) : const Color(0xFF9B9BA2),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: enabled ? const Color(0xFF1F1F23) : const Color(0xFF9B9BA2),
          fontSize: 14.5,
        ),
      ),
      trailing: Icon(
        enabled ? Icons.chevron_right : Icons.lock_outline,
        color: const Color(0xFF8A8A91),
      ),
      onTap: enabled ? onTap : null,
    );
  }

  Widget _memberTile({
    required String avatarAssetPath,
    required String title,
    required String subtitle,
    required String roleLabel,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      onTap: onTap,
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
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: roleLabel == 'Quản trị viên'
              ? const Color(0xFFE8F3FF)
              : const Color(0xFFEDEDF1),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          roleLabel,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: roleLabel == context.l10n.adminRole
                ? const Color(0xFF1674C8)
                : const Color(0xFF707078),
          ),
        ),
      ),
    );
  }

  Future<void> _showRenameSheet(String currentName) async {
    final l10n = context.l10n;
    if (!widget.chatStore.isCurrentUserGroupAdmin(widget.conversationId)) {
      _showNoPermissionToast();
      return;
    }

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
              Text(
                l10n.groupRename,
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
                  hintText: l10n.groupRename,
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
                  child: Text(
                    l10n.save,
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
    if (!widget.chatStore.isCurrentUserGroupAdmin(widget.conversationId)) {
      _showNoPermissionToast();
      return;
    }

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
    if (!widget.chatStore.isCurrentUserGroupAdmin(widget.conversationId)) {
      _showNoPermissionToast();
      return;
    }

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
      SnackBar(content: Text(context.l10n.groupMemberAdded)),
    );
  }

  void _openSearchInChat() {
    final group = widget.chatStore.conversationById(widget.conversationId);
    final displayName = group?.username ?? context.l10n.groupChatFallback;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatSearchScreen(
          displayName: displayName,
          conversationId: widget.conversationId,
          chatStore: widget.chatStore,
        ),
      ),
    );
  }

  void _openMediaGallery() {
    final group = widget.chatStore.conversationById(widget.conversationId);
    final displayName = group?.username ?? context.l10n.groupChatFallback;
    final avatarAssetPath = group?.avatarAssetPath ?? 'assets/images/logo1.jpg';
    final media = widget.chatStore.mediaForConversation(widget.conversationId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatMediaGalleryScreen(
          displayName: displayName,
          avatarAssetPath: avatarAssetPath,
          mediaAssets: media,
        ),
      ),
    );
  }

  Future<void> _confirmLeaveGroup() async {
    final group = widget.chatStore.conversationById(widget.conversationId);
    if (group == null || !group.isGroup) return;

    final canLeaveDirect = widget.chatStore.canCurrentUserLeaveGroup(
      widget.conversationId,
    );

    final memberCandidates = group.memberIds
        .map(widget.chatStore.conversationById)
        .whereType<MockConversation>()
        .toList();

    String? selectedNewAdminId = memberCandidates.isNotEmpty
        ? memberCandidates.first.id
        : null;

    final dialogResult = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF4F4F6),
              title: Text(context.l10n.leaveGroupQuestion),
              content: canLeaveDirect
                  ? Text(context.l10n.leaveGroupNoNewMessages)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(context.l10n.selectNewAdminBeforeLeave),
                        const SizedBox(height: 12),
                        if (memberCandidates.isEmpty)
                          Text(
                            context.l10n.noMemberToTransfer,
                            style: TextStyle(
                              color: Color(0xFF8A8A91),
                              fontSize: 12,
                            ),
                          )
                        else
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 260),
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: memberCandidates.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, index) {
                                final member = memberCandidates[index];
                                final isAdmin = widget.chatStore
                                    .isGroupMemberAdmin(
                                      widget.conversationId,
                                      member.id,
                                    );
                                final isSelected =
                                    selectedNewAdminId == member.id;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    setState(() {
                                      selectedNewAdminId = member.id;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFEAF4FF)
                                          : const Color(0xFFE8E8EC),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF1689F6)
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          foregroundImage: AssetImage(
                                            member.avatarAssetPath,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                _toDisplayName(member.username),
                                                style: const TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFF1F1F23),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                isAdmin
                                                  ? context.l10n.currentRoleAdmin
                                                  : context.l10n.currentRoleMember,
                                                style: const TextStyle(
                                                  fontSize: 11.5,
                                                  color: Color(0xFF7C7C84),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          isSelected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_unchecked,
                                          size: 20,
                                          color: isSelected
                                              ? const Color(0xFF1689F6)
                                              : const Color(0xFF9A9AA1),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, null),
                  child: Text(context.l10n.cancel),
                ),
                TextButton(
                  onPressed: () {
                    if (canLeaveDirect) {
                      Navigator.pop(dialogContext, 'leave_direct');
                      return;
                    }

                    if (selectedNewAdminId == null) {
                      return;
                    }

                    Navigator.pop(dialogContext, selectedNewAdminId);
                  },
                  child: Text(
                    context.l10n.leaveGroup,
                    style: TextStyle(color: Color(0xFFE60000)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (dialogResult == null || !mounted) return;

    var left = false;
    if (canLeaveDirect) {
      left = widget.chatStore.leaveGroup(widget.conversationId);
    } else {
      final selectedMember = memberCandidates.firstWhere(
        (member) => member.id == dialogResult,
        orElse: () => memberCandidates.first,
      );
      final confirmed = await _confirmHandoverStep(
        selectedMember: selectedMember,
      );

      if (!mounted || !confirmed) {
        return;
      }

      left = widget.chatStore.handoverAdminAndLeaveGroup(
        widget.conversationId,
        dialogResult,
      );
    }

    if (!left) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.cannotLeaveGroupCheckAdmin)),
      );
      return;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    Navigator.of(context).popUntil((route) => route.isFirst);

    if (messenger != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              canLeaveDirect
                  ? context.l10n.leftGroupSuccess
                  : context.l10n.handoverAndLeaveSuccess,
            ),
          ),
        );
      });
    }
  }

  Future<bool> _confirmHandoverStep({
    required MockConversation selectedMember,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF4F4F6),
          title: Text(context.l10n.secondConfirmation),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.aboutToHandoverAndLeave),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8E8EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      foregroundImage: AssetImage(
                        selectedMember.avatarAssetPath,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _toDisplayName(selectedMember.username),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F1F23),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.l10n.newAdminWillBe,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF7C7C84),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.l10n.afterConfirmLeaveImmediately,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A8A91),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(context.l10n.goBack),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                context.l10n.confirmHandover,
                style: TextStyle(color: Color(0xFFE60000)),
              ),
            ),
          ],
        );
      },
    );

    return result == true;
  }

  void _openMemberProfile({
    required String memberId,
    required String username,
    required String displayName,
    required String avatarAssetPath,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatGroupMemberProfileScreen(
          groupConversationId: widget.conversationId,
          memberId: memberId,
          username: username,
          displayName: displayName,
          avatarAssetPath: avatarAssetPath,
          chatStore: widget.chatStore,
        ),
      ),
    );
  }

  void _showNoPermissionToast() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.adminOnlyAction)),
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
