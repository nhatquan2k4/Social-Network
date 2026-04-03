import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/domain/entities/friend_entity.dart';
import 'package:frontend/presentation/providers/mock_chat_store.dart';
import 'package:frontend/presentation/screens/chat/chat_screen.dart';

class ChatGroupMemberProfileScreen extends StatelessWidget {
  final String groupConversationId;
  final String memberId;
  final String username;
  final String displayName;
  final String avatarAssetPath;
  final MockChatStore chatStore;

  const ChatGroupMemberProfileScreen({
    super.key,
    required this.groupConversationId,
    required this.memberId,
    required this.username,
    required this.displayName,
    required this.avatarAssetPath,
    required this.chatStore,
  });

  bool get _isSelf => memberId == MockChatStore.currentUserId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: chatStore,
      builder: (context, _) {
        final isAdmin = chatStore.isGroupMemberAdmin(
          groupConversationId,
          memberId,
        );
        final canManage = chatStore.isCurrentUserGroupAdmin(
          groupConversationId,
        );
        final canPromote = canManage && !isAdmin && !_isSelf;
        final canDemote =
            canManage &&
            isAdmin &&
            !_isSelf &&
            chatStore.groupAdminCount(groupConversationId) > 1;
        final selfDemoteBlocked = canManage && isAdmin && _isSelf;

        return Scaffold(
          backgroundColor: const Color(0xFFF2F2F4),
          appBar: AppBar(
            backgroundColor: const Color(0xFFF2F2F4),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 17),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 18),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  foregroundImage: AssetImage(avatarAssetPath),
                ),
                const SizedBox(height: 10),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F1F23),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7D7D84),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? const Color(0xFFE8F3FF)
                        : const Color(0xFFEDEDF1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    isAdmin ? context.l10n.adminRole : context.l10n.memberRole,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isAdmin
                          ? const Color(0xFF1674C8)
                          : const Color(0xFF707078),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _infoCard(
                  icon: Icons.groups_2_outlined,
                  title: context.l10n.groupRoleTitle,
                  value: isAdmin ? context.l10n.adminRole : context.l10n.memberRole,
                ),
                const SizedBox(height: 8),
                _infoCard(
                  icon: Icons.badge_outlined,
                  title: context.l10n.memberIdTitle,
                  value: memberId,
                ),
                const SizedBox(height: 10),
                _permissionSummary(
                  context: context,
                  canManage: canManage,
                  isAdmin: isAdmin,
                  isSelf: _isSelf,
                ),
                if (canPromote || canDemote) const SizedBox(height: 8),
                if (canPromote)
                  _adminActionButton(
                    label: context.l10n.grantAdmin,
                    color: const Color(0xFF1689F6),
                    textColor: Colors.white,
                    onTap: () {
                      final ok = chatStore.promoteGroupMemberToAdmin(
                        groupConversationId,
                        memberId,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? context.l10n.adminGrantedTo(displayName)
                                : context.l10n.cannotGrantAdmin,
                          ),
                        ),
                      );
                    },
                  ),
                if (canDemote)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _adminActionButton(
                      label: context.l10n.revokeAdmin,
                      color: const Color(0xFFFFE9EA),
                      textColor: const Color(0xFFE60000),
                      onTap: () {
                        final ok = chatStore.demoteGroupMemberFromAdmin(
                          groupConversationId,
                          memberId,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? context.l10n.adminRevokedFrom(displayName)
                                  : context.l10n.cannotRevokeAdmin,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                if (selfDemoteBlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Tooltip(
                      message:
                          context.l10n.cannotRevokeOwnAdminTooltip,
                      child: _adminActionButton(
                        label: context.l10n.revokeAdminLocked,
                        color: const Color(0xFFEDEDF1),
                        textColor: const Color(0xFF8B8B92),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.cannotRevokeOwnAdmin),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (!canManage && !_isSelf)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Tooltip(
                      message:
                          context.l10n.onlyAdminCanGrantOrRevokeTooltip,
                      child: _adminActionButton(
                        label: context.l10n.onlyAdminCanChangeRole,
                        color: const Color(0xFFEDEDF1),
                        textColor: const Color(0xFF8B8B92),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                context.l10n.noAdminPermissionForAction,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                if (canManage && isAdmin && !_isSelf && !canDemote)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      context.l10n.cannotRevokeLastAdmin,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8A8A91),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const Spacer(),
                if (!_isSelf)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openDirectChat(context),
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: Text(context.l10n.privateMessage),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFF1689F6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.person, size: 18),
                      label: Text(context.l10n.thisIsYourAccount),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        disabledBackgroundColor: const Color(0xFFE1E1E6),
                        disabledForegroundColor: const Color(0xFF7B7B83),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
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

  Widget _permissionSummary({
    required BuildContext context,
    required bool canManage,
    required bool isAdmin,
    required bool isSelf,
  }) {
    final String badgeText;
    final Color badgeBg;
    final Color badgeTextColor;
    final String tip;

    if (canManage && isAdmin) {
      badgeText = isSelf
          ? context.l10n.youAreCurrentAdmin
          : context.l10n.adminHasFullControl;
      badgeBg = const Color(0xFFE8F3FF);
      badgeTextColor = const Color(0xFF1674C8);
      tip = context.l10n.canGrantOrRevokeForOthers;
    } else if (canManage) {
      badgeText = context.l10n.youHaveAdminRights;
      badgeBg = const Color(0xFFE8F3FF);
      badgeTextColor = const Color(0xFF1674C8);
      tip = context.l10n.canChangeMemberRoles;
    } else {
      badgeText = context.l10n.noPermissionChangeRole;
      badgeBg = const Color(0xFFEDEDF1);
      badgeTextColor = const Color(0xFF707078);
      tip = context.l10n.onlyAdminCanGrantOrRevoke;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            badgeText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: badgeTextColor,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: tip,
          child: const Icon(
            Icons.info_outline,
            size: 16,
            color: Color(0xFF7B7B83),
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECECEF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3A3A40)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF787880),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1F1F23),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _adminActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
        ),
      ),
    );
  }

  void _openDirectChat(BuildContext context) {
    final friend = FriendEntity(
      id: memberId,
      username: username,
      displayName: displayName,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(friend: friend, conversationId: null),
      ),
    );
  }
}
