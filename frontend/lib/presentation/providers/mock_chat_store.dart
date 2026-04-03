import 'package:flutter/material.dart';

class MockChatStore extends ChangeNotifier {
  MockChatStore._();

  static final MockChatStore instance = MockChatStore._();

  final DateTime _now = DateTime.now();
  static const String currentUserId = 'self';
  static const String currentUserDisplayName = 'Hoàng Tú';
  static const String currentUserUsername = 'hoangtu_01';
  static const String currentUserAvatarAssetPath = 'assets/images/image 74.png';

  final Map<String, String> _selfNicknames = {};
  final Map<String, String> _friendNicknames = {};

  late final List<MockConversation> _conversations =
      _buildInitialConversations();

  List<MockConversation> visibleConversations(String query) {
    final filtered = _conversations.where((c) {
      if (c.isDeleted || c.isHidden) return false;
      return _matchesConversationQuery(c, query);
    }).toList();

    filtered.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.lastMessageAt.compareTo(a.lastMessageAt);
    });

    return filtered;
  }

  List<MockConversation> pendingConversations(String query) {
    final filtered = _conversations.where((c) {
      if (c.isDeleted || !c.isHidden) return false;
      return _matchesConversationQuery(c, query);
    }).toList();

    filtered.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.lastMessageAt.compareTo(a.lastMessageAt);
    });

    return filtered;
  }

  int get pendingConversationCount {
    for (final conversation in _conversations) {
      _refreshMuteState(conversation);
    }
    return _conversations.where((c) => !c.isDeleted && c.isHidden).length;
  }

  List<MockChatMessage> conversationMessages(String conversationId) {
    final conversation = _findById(conversationId);
    if (conversation == null) return [];
    return List<MockChatMessage>.from(conversation.messages);
  }

  List<MockConversation> groupSuggestions({
    required String excludeConversationId,
  }) {
    return _conversations.where((c) {
      return !c.isDeleted &&
          !c.isHidden &&
          !c.isGroup &&
          c.id != excludeConversationId;
    }).toList();
  }

  MockConversation createGroupConversation({
    required List<String> memberConversationIds,
    String? groupName,
    String? groupAvatarAssetPath,
  }) {
    final now = DateTime.now();
    final uniqueMembers = memberConversationIds.toSet().toList();
    final members = uniqueMembers
        .map(_findById)
        .whereType<MockConversation>()
        .toList();

    final generatedName = members
        .map((m) => _displayNameFromUsername(m.username))
        .take(3)
        .join(', ');
    final displayName = (groupName ?? '').trim().isEmpty
        ? generatedName
        : groupName!.trim();

    final avatarPath = (groupAvatarAssetPath ?? '').trim().isNotEmpty
        ? groupAvatarAssetPath!.trim()
        : (members.isNotEmpty
              ? members.first.avatarAssetPath
              : currentUserAvatarAssetPath);

    final avatarColor = members.isNotEmpty
        ? members.first.avatarColor
        : const Color(0xFF6C7E92);

    final initialMessages = <MockChatMessage>[
      MockChatMessage(
        content:
            '${_formatDateTime(now)} • $currentUserDisplayName đã tạo nhóm này',
        isMe: false,
        sentAt: now,
        isSystem: true,
      ),
    ];

    if ((groupName ?? '').trim().isNotEmpty) {
      initialMessages.add(
        MockChatMessage(
          content:
              '${_formatDateTime(now)} • $currentUserDisplayName đã đặt tên nhóm là "${groupName!.trim()}"',
          isMe: false,
          sentAt: now,
          isSystem: true,
        ),
      );
    }

    if ((groupAvatarAssetPath ?? '').trim().isNotEmpty) {
      initialMessages.add(
        MockChatMessage(
          content:
              '${_formatDateTime(now)} • $currentUserDisplayName đã đổi ảnh nhóm',
          isMe: false,
          sentAt: now,
          isSystem: true,
        ),
      );
    }

    final conversation = MockConversation(
      id: 'group_${now.microsecondsSinceEpoch}',
      username: displayName,
      avatarColor: avatarColor,
      avatarAssetPath: avatarPath,
      isOnline: false,
      messages: initialMessages,
      lastMessageAt: now,
      mediaAssets: members.expand((m) => m.mediaAssets.take(3)).toList(),
      extraMediaCount: 0,
      isGroup: true,
      memberIds: members.map((m) => m.id).toList(),
      memberNames: members
          .map((m) => _displayNameFromUsername(m.username))
          .toList(),
      adminMemberIds: const [currentUserId],
      createdAt: now,
    );

    _conversations.add(conversation);
    notifyListeners();
    return conversation;
  }

  List<MockConversation> addableMembersForGroup(String groupConversationId) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return const [];
    if (!isCurrentUserGroupAdmin(groupConversationId)) return const [];

    return _conversations.where((c) {
      return !c.isDeleted &&
          !c.isHidden &&
          !c.isGroup &&
          c.id != groupConversationId &&
          !group.memberIds.contains(c.id);
    }).toList();
  }

  bool isCurrentUserGroupAdmin(String groupConversationId) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return false;
    return group.adminMemberIds.contains(currentUserId);
  }

  bool isGroupMemberAdmin(String groupConversationId, String memberId) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return false;
    return group.adminMemberIds.contains(memberId);
  }

  int groupAdminCount(String groupConversationId) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return 0;
    return group.adminMemberIds.length;
  }

  bool canCurrentUserLeaveGroup(String groupConversationId) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return false;

    final isCurrentAdmin = group.adminMemberIds.contains(currentUserId);
    if (!isCurrentAdmin) return true;

    return group.adminMemberIds.length > 1;
  }

  bool promoteGroupMemberToAdmin(
    String groupConversationId,
    String memberId, {
    String actorName = currentUserDisplayName,
  }) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return false;
    if (!isCurrentUserGroupAdmin(groupConversationId)) return false;
    if (memberId == currentUserId) return false;
    if (!group.memberIds.contains(memberId)) return false;
    if (group.adminMemberIds.contains(memberId)) return false;

    final member = _findById(memberId);
    if (member == null) return false;

    group.adminMemberIds.add(memberId);
    final now = DateTime.now();
    _appendSystemMessage(
      conversationId: groupConversationId,
      sentAt: now,
      content:
          '${_formatDateTime(now)} • $actorName đã cấp quyền quản trị viên cho ${_displayNameFromUsername(member.username)}',
    );

    notifyListeners();
    return true;
  }

  bool demoteGroupMemberFromAdmin(
    String groupConversationId,
    String memberId, {
    String actorName = currentUserDisplayName,
  }) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return false;
    if (!isCurrentUserGroupAdmin(groupConversationId)) return false;
    if (memberId == currentUserId) return false;
    if (!group.adminMemberIds.contains(memberId)) return false;

    if (group.adminMemberIds.length <= 1) {
      return false;
    }

    final member = _findById(memberId);
    if (member == null) return false;

    group.adminMemberIds.remove(memberId);
    final now = DateTime.now();
    _appendSystemMessage(
      conversationId: groupConversationId,
      sentAt: now,
      content:
          '${_formatDateTime(now)} • $actorName đã gỡ quyền quản trị viên của ${_displayNameFromUsername(member.username)}',
    );

    notifyListeners();
    return true;
  }

  bool handoverAdminAndLeaveGroup(
    String groupConversationId,
    String nextAdminMemberId, {
    String actorName = currentUserDisplayName,
  }) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return false;
    if (!group.adminMemberIds.contains(currentUserId)) return false;
    if (nextAdminMemberId == currentUserId) return false;
    if (!group.memberIds.contains(nextAdminMemberId)) return false;

    final nextAdminConversation = _findById(nextAdminMemberId);
    if (nextAdminConversation == null) return false;

    final now = DateTime.now();
    if (!group.adminMemberIds.contains(nextAdminMemberId)) {
      group.adminMemberIds.add(nextAdminMemberId);
    }
    group.adminMemberIds.remove(currentUserId);

    _appendSystemMessage(
      conversationId: groupConversationId,
      sentAt: now,
      content:
          '${_formatDateTime(now)} • $actorName đã chuyển quyền quản trị viên cho ${_displayNameFromUsername(nextAdminConversation.username)}',
    );

    _appendSystemMessage(
      conversationId: groupConversationId,
      sentAt: now,
      content: '${_formatDateTime(now)} • $actorName đã rời khỏi nhóm',
    );

    group.isHidden = true;
    notifyListeners();
    return true;
  }

  void renameGroup(
    String groupConversationId,
    String newName, {
    String actorName = currentUserDisplayName,
  }) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return;
    if (!isCurrentUserGroupAdmin(groupConversationId)) return;

    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == group.username) return;

    group.username = trimmed;
    final now = DateTime.now();
    _appendSystemMessage(
      conversationId: groupConversationId,
      sentAt: now,
      content:
          '${_formatDateTime(now)} • $actorName đã đổi tên nhóm thành "$trimmed"',
    );

    notifyListeners();
  }

  void changeGroupAvatar(
    String groupConversationId,
    String avatarAssetPath, {
    String actorName = currentUserDisplayName,
  }) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return;
    if (!isCurrentUserGroupAdmin(groupConversationId)) return;

    final trimmed = avatarAssetPath.trim();
    if (trimmed.isEmpty || trimmed == group.avatarAssetPath) return;

    group.avatarAssetPath = trimmed;
    final now = DateTime.now();
    _appendSystemMessage(
      conversationId: groupConversationId,
      sentAt: now,
      content: '${_formatDateTime(now)} • $actorName đã đổi ảnh nhóm',
    );

    notifyListeners();
  }

  void addMembersToGroup(
    String groupConversationId,
    List<String> memberConversationIds, {
    String actorName = currentUserDisplayName,
  }) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return;
    if (!isCurrentUserGroupAdmin(groupConversationId)) return;

    final newMembers = memberConversationIds
        .toSet()
        .map(_findById)
        .whereType<MockConversation>()
        .where((c) => !c.isGroup && !group.memberIds.contains(c.id))
        .toList();

    if (newMembers.isEmpty) return;

    final now = DateTime.now();
    for (final member in newMembers) {
      group.memberIds.add(member.id);
      group.memberNames.add(_displayNameFromUsername(member.username));
    }

    final addedNames = newMembers
        .map((m) => _displayNameFromUsername(m.username))
        .join(', ');

    _appendSystemMessage(
      conversationId: groupConversationId,
      sentAt: now,
      content:
          '${_formatDateTime(now)} • $actorName đã thêm $addedNames vào nhóm',
    );

    notifyListeners();
  }

  bool leaveGroup(
    String groupConversationId, {
    String actorName = currentUserDisplayName,
  }) {
    final group = _findById(groupConversationId);
    if (group == null || !group.isGroup) return false;

    if (!canCurrentUserLeaveGroup(groupConversationId)) {
      return false;
    }

    final now = DateTime.now();
    _appendSystemMessage(
      conversationId: groupConversationId,
      sentAt: now,
      content: '${_formatDateTime(now)} • $actorName đã rời khỏi nhóm',
    );

    group.adminMemberIds.remove(currentUserId);

    group.isHidden = true;
    notifyListeners();
    return true;
  }

  String nicknameForSelf(String conversationId) {
    return _selfNicknames[conversationId] ?? currentUserDisplayName;
  }

  String nicknameForFriend(String conversationId, String fallbackName) {
    return _friendNicknames[conversationId] ?? fallbackName;
  }

  void setNicknameForSelf(
    String conversationId,
    String value, {
    String actorName = currentUserDisplayName,
  }) {
    final changed = _setNickname(
      store: _selfNicknames,
      conversationId: conversationId,
      value: value,
    );

    if (!changed) return;

    final now = DateTime.now();
    final normalized = value.trim();
    final actionText = normalized.isEmpty
        ? '$actorName đã xóa biệt danh của $currentUserDisplayName'
        : '$actorName đã đặt biệt danh của $currentUserDisplayName là "$normalized"';

    _appendSystemMessage(
      conversationId: conversationId,
      sentAt: now,
      content: '${_formatDateTime(now)} • $actionText',
    );

    notifyListeners();
  }

  void setNicknameForFriend(
    String conversationId,
    String value, {
    String actorName = currentUserDisplayName,
    required String friendDisplayName,
  }) {
    final changed = _setNickname(
      store: _friendNicknames,
      conversationId: conversationId,
      value: value,
    );

    if (!changed) return;

    final now = DateTime.now();
    final normalized = value.trim();
    final actionText = normalized.isEmpty
        ? '$actorName đã xóa biệt danh của $friendDisplayName'
        : '$actorName đã đặt biệt danh của $friendDisplayName là "$normalized"';

    _appendSystemMessage(
      conversationId: conversationId,
      sentAt: now,
      content: '${_formatDateTime(now)} • $actionText',
    );

    notifyListeners();
  }

  MockConversation? conversationById(String id) {
    final conversation = _findById(id);
    if (conversation == null) return null;
    _refreshMuteState(conversation);
    return conversation;
  }

  List<String> mediaForConversation(String conversationId) {
    return _findById(conversationId)?.mediaAssets ?? const [];
  }

  int extraMediaCountForConversation(String conversationId) {
    return _findById(conversationId)?.extraMediaCount ?? 0;
  }

  void markConversationRead(String conversationId) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    conversation.unreadCount = 0;
    notifyListeners();
  }

  void appendOutgoingMessage({
    required String conversationId,
    required String content,
  }) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    conversation.messages.add(
      MockChatMessage(content: content, isMe: true, sentAt: DateTime.now()),
    );
    conversation.lastMessageAt = DateTime.now();
    conversation.unreadCount = 0;
    notifyListeners();
  }

  void _appendSystemMessage({
    required String conversationId,
    required DateTime sentAt,
    required String content,
  }) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    conversation.messages.add(
      MockChatMessage(
        content: content,
        isMe: false,
        sentAt: sentAt,
        isSystem: true,
      ),
    );
    conversation.lastMessageAt = sentAt;
  }

  void togglePin(String conversationId) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    conversation.isPinned = !conversation.isPinned;
    notifyListeners();
  }

  void hideConversation(String conversationId) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    conversation.isHidden = true;
    notifyListeners();
  }

  void restoreConversation(String conversationId) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    conversation.isHidden = false;
    notifyListeners();
  }

  void deleteConversation(String conversationId) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    conversation.isDeleted = true;
    notifyListeners();
  }

  void muteFor(
    String conversationId,
    Duration duration, {
    String actorName = currentUserDisplayName,
  }) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    final now = DateTime.now();
    conversation.muteUntilTurnedOn = false;
    conversation.mutedStartedAt = now;
    conversation.mutedUntil = now.add(duration);

    _appendSystemMessage(
      conversationId: conversationId,
      sentAt: now,
      content:
          '${_formatDateTime(now)} • $actorName đã tắt thông báo đoạn chat trong ${_formatDuration(duration)}',
    );

    notifyListeners();
  }

  void muteUntilTurnedOn(
    String conversationId, {
    String actorName = currentUserDisplayName,
  }) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    final now = DateTime.now();
    conversation.muteUntilTurnedOn = true;
    conversation.mutedStartedAt = now;
    conversation.mutedUntil = null;

    _appendSystemMessage(
      conversationId: conversationId,
      sentAt: now,
      content:
          '${_formatDateTime(now)} • $actorName đã tắt thông báo đoạn chat cho đến khi bật lại',
    );

    notifyListeners();
  }

  void unmute(String conversationId) {
    clearMuteState(conversationId);
  }

  void clearMuteState(
    String conversationId, {
    String actorName = currentUserDisplayName,
  }) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    final wasMuted = conversation.isMuted;
    final now = DateTime.now();

    conversation.muteUntilTurnedOn = false;
    conversation.mutedStartedAt = null;
    conversation.mutedUntil = null;

    if (wasMuted) {
      _appendSystemMessage(
        conversationId: conversationId,
        sentAt: now,
        content:
            '${_formatDateTime(now)} • $actorName đã bật lại thông báo cho đoạn chat',
      );
    }

    notifyListeners();
  }

  void setRestricted(String conversationId, bool value) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    if (conversation.isBlocked && value) {
      return;
    }

    conversation.isRestricted = value;
    notifyListeners();
  }

  void setBlocked(String conversationId, bool value) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    conversation.isBlocked = value;
    if (value) {
      // Blocked conversations are treated as restricted as well.
      conversation.isRestricted = true;
    }
    notifyListeners();
  }

  String formatRelativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return '.now';
    if (diff.inMinutes < 60) return '.${diff.inMinutes}phút';
    if (diff.inHours < 24) return '.${diff.inHours}h';
    if (diff.inDays < 7) return '.${diff.inDays} ngày';

    final weeks = (diff.inDays / 7).floor();
    return '.$weeks tuần';
  }

  List<MockConversation> _buildInitialConversations() {
    const mediaPool = [
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

    const base = [
      _SeedConversation(
        'keociiu',
        0,
        true,
        Color(0xFF8E695D),
        'em iu ai nh +<3',
        'assets/images/image 74.png',
      ),
      _SeedConversation(
        'thuytrng_04',
        1,
        true,
        Color(0xFF6C5A49),
        'em sủi iu nhỏ bò nh',
        'assets/images/image 75.png',
      ),
      _SeedConversation(
        'trangg.ne',
        2,
        true,
        Color(0xFF6F8EAD),
        'chiều nay mình đi cafe không',
        'assets/images/image 76.png',
      ),
      _SeedConversation(
        'vannhh_22',
        12,
        false,
        Color(0xFF95715E),
        'mai nộp bài nhóm nha bạn ơi',
        'assets/images/image 77.png',
      ),
      _SeedConversation(
        'huytran.dev',
        26,
        true,
        Color(0xFF4E7A8C),
        'mình fix xong bug phần chat rồi',
        'assets/images/image 78.png',
      ),
      _SeedConversation(
        'linhchip_09',
        41,
        false,
        Color(0xFFA16477),
        'đi ăn tokbokki không nè',
        'assets/images/image 79.png',
      ),
      _SeedConversation(
        'khanh.97',
        60,
        false,
        Color(0xFF6C8E72),
        'ảnh hôm qua đẹp ghê luôn',
        'assets/images/image 80.png',
      ),
      _SeedConversation(
        'hoamaii_15',
        120,
        true,
        Color(0xFFB07A6A),
        'đừng quên mang áo khoác nha',
        'assets/images/image 81.png',
      ),
      _SeedConversation(
        'quynhanh.xiu',
        180,
        false,
        Color(0xFF6B9376),
        'tuần sau mình đi tắm đào nhé anh iu',
        'assets/images/image 82.png',
      ),
      _SeedConversation(
        'ngocxanhh',
        240,
        false,
        Color(0xFF5A88A6),
        'chỗ đó nghe nhạc chill lắm',
        'assets/images/image 83.png',
      ),
      _SeedConversation(
        'khai_4.khai',
        300,
        false,
        Color(0xFF8A6E59),
        '5 phút nữa a qua nhé em iu',
        'assets/images/image 84.png',
      ),
      _SeedConversation(
        'thu.minh_21',
        420,
        false,
        Color(0xFF8C78A8),
        'gửi tui file design với nhaa',
        'assets/images/image 85.png',
      ),
      _SeedConversation(
        'datlee.pro',
        540,
        true,
        Color(0xFF6E7F53),
        'chiều chạy bộ 30p nhé',
        'assets/images/image 86.png',
      ),
      _SeedConversation(
        'ngocha.66',
        7200,
        false,
        Color(0xFF5A91AF),
        'dành ở sân nào thế á',
        'assets/images/image 87.png',
      ),
      _SeedConversation(
        'haann_84',
        1440,
        false,
        Color(0xFF9C6666),
        'đã đặt bàn 7h tối rồi đó',
        'assets/images/image 88.png',
      ),
      _SeedConversation(
        'tuanvu.works',
        2880,
        false,
        Color(0xFF5E7598),
        'anh em mình code tiếp tối nay',
        'assets/images/image 89.png',
      ),
      _SeedConversation(
        'nhii.cloud',
        4320,
        true,
        Color(0xFF88766C),
        'mình vừa cập nhật roadmap',
        'assets/images/image 90.png',
      ),
      _SeedConversation(
        'quocbao_11',
        5760,
        false,
        Color(0xFF5F8A88),
        'tháng này đi biển không mọi người',
        'assets/images/image 92.png',
      ),
      _SeedConversation(
        'dimhu27th4',
        10080,
        true,
        Color(0xFFA17484),
        'em iu anh <3',
        'assets/images/image 74.png',
      ),
      _SeedConversation(
        'thuonghip136',
        50400,
        false,
        Color(0xFF8A7DA5),
        'học phòng nào đấy',
        'assets/images/image 75.png',
      ),
    ];

    return List<MockConversation>.generate(base.length, (index) {
      final seed = base[index];
      final conversationId = 'mock_${seed.lastActiveMinutes}';
      final messages = _generateMessages(
        seed.username,
        seed.lastMessageSeed,
        index,
      );
      final unreadHash = seed.username.codeUnits.fold<int>(
        0,
        (s, c) => s + c * 17,
      );
      final unread = unreadHash % 6;
      final media = List<String>.generate(
        16,
        (i) => mediaPool[(index + i) % mediaPool.length],
      );

      return MockConversation(
        id: conversationId,
        username: seed.username,
        avatarColor: seed.avatarColor,
        avatarAssetPath: seed.avatarAssetPath,
        isOnline: seed.isOnline,
        isPinned: seed.lastActiveMinutes <= 2,
        unreadCount: unread,
        messages: messages,
        mediaAssets: media,
        extraMediaCount: 23,
        lastMessageAt: _now.subtract(Duration(minutes: seed.lastActiveMinutes)),
      );
    });
  }

  List<MockChatMessage> _generateMessages(
    String username,
    String seed,
    int index,
  ) {
    final topicBank = [
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
    ];

    final topic = topicBank[index % topicBank.length];
    final altTopic = topicBank[(index + 3) % topicBank.length];

    return [
      MockChatMessage(
        content: 'hôm nay bạn rảnh không',
        isMe: false,
        sentAt: _now.subtract(const Duration(minutes: 25)),
      ),
      MockChatMessage(
        content: 'mình rảnh nè, có gì không',
        isMe: true,
        sentAt: _now.subtract(const Duration(minutes: 22)),
      ),
      MockChatMessage(
        content: 'mình tính rủ bạn $topic á',
        isMe: false,
        sentAt: _now.subtract(const Duration(minutes: 19)),
      ),
      MockChatMessage(
        content: 'nghe hay đó, để mình chuẩn bị nha',
        isMe: true,
        sentAt: _now.subtract(const Duration(minutes: 16)),
      ),
      MockChatMessage(
        content: 'ok luôn, sẵn tiện bàn thêm chuyện $altTopic',
        isMe: false,
        sentAt: _now.subtract(const Duration(minutes: 13)),
      ),
      MockChatMessage(
        content: seed,
        isMe: index.isEven,
        sentAt: _now.subtract(const Duration(minutes: 10)),
      ),
      MockChatMessage(
        content: 'okee $username nhé',
        isMe: !index.isEven,
        sentAt: _now.subtract(const Duration(minutes: 7)),
      ),
    ];
  }

  MockConversation? _findById(String id) {
    for (final c in _conversations) {
      if (c.id == id) return c;
    }
    return null;
  }

  void _refreshMuteState(MockConversation conversation) {
    if (!conversation.muteUntilTurnedOn &&
        conversation.mutedUntil != null &&
        conversation.mutedUntil!.isBefore(DateTime.now())) {
      conversation.mutedStartedAt = null;
      conversation.mutedUntil = null;
    }
  }

  bool _setNickname({
    required Map<String, String> store,
    required String conversationId,
    required String value,
  }) {
    final trimmed = value.trim();
    final current = store[conversationId] ?? '';
    if (current == trimmed) return false;

    if (trimmed.isEmpty) {
      store.remove(conversationId);
    } else {
      store[conversationId] = trimmed;
    }

    return true;
  }

  String _formatDateTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final year = time.year.toString();
    return '$hour:$minute $day/$month/$year';
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes < 60) return '${duration.inMinutes} phút';
    if (duration.inHours < 24) return '${duration.inHours} giờ';
    return '${duration.inDays} ngày';
  }

  String _displayNameFromUsername(String username) {
    final normalized = username.replaceAll(RegExp(r'[._]'), ' ').trim();
    final parts = normalized.split(RegExp(r'\s+'));
    return parts
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }

  bool _matchesConversationQuery(MockConversation conversation, String query) {
    final normalized = query.trim().toLowerCase();

    _refreshMuteState(conversation);

    if (normalized.isEmpty) {
      return true;
    }

    final selfNickname = _selfNicknames[conversation.id]?.toLowerCase() ?? '';
    final friendNickname =
        _friendNicknames[conversation.id]?.toLowerCase() ?? '';
    final memberText = conversation.memberNames.join(' ').toLowerCase();

    return conversation.username.toLowerCase().contains(normalized) ||
        conversation.lastPreviewText.toLowerCase().contains(normalized) ||
        memberText.contains(normalized) ||
        selfNickname.contains(normalized) ||
        friendNickname.contains(normalized);
  }
}

class MockConversation {
  final String id;
  String username;
  final Color avatarColor;
  String avatarAssetPath;
  final bool isOnline;
  List<MockChatMessage> messages;

  bool isPinned;
  bool isHidden;
  bool isDeleted;
  bool isRestricted;
  bool isBlocked;
  bool muteUntilTurnedOn;
  int unreadCount;
  DateTime lastMessageAt;
  DateTime? mutedStartedAt;
  DateTime? mutedUntil;
  final List<String> mediaAssets;
  final int extraMediaCount;
  final bool isGroup;
  final List<String> memberIds;
  final List<String> memberNames;
  final List<String> adminMemberIds;
  final DateTime createdAt;

  MockConversation({
    required this.id,
    required this.username,
    required this.avatarColor,
    required this.avatarAssetPath,
    required this.isOnline,
    required this.messages,
    required this.lastMessageAt,
    required this.mediaAssets,
    this.extraMediaCount = 0,
    this.isPinned = false,
    this.isHidden = false,
    this.isDeleted = false,
    this.isRestricted = false,
    this.isBlocked = false,
    this.muteUntilTurnedOn = false,
    this.unreadCount = 0,
    this.mutedStartedAt,
    this.mutedUntil,
    this.isGroup = false,
    List<String> memberIds = const [],
    List<String> memberNames = const [],
    List<String> adminMemberIds = const [],
    DateTime? createdAt,
  }) : memberIds = List<String>.of(memberIds),
       memberNames = List<String>.of(memberNames),
       adminMemberIds = List<String>.of(adminMemberIds),
       createdAt = createdAt ?? lastMessageAt;

  MockChatMessage get lastMessage => messages.last;

  String get lastPreviewText {
    final message = lastMessage;
    if (message.isSystem) return message.content;
    return message.isMe ? 'Bạn: ${message.content}' : message.content;
  }

  bool get isMuted {
    return muteUntilTurnedOn ||
        (mutedUntil != null && mutedUntil!.isAfter(DateTime.now()));
  }
}

class MockChatMessage {
  final String content;
  final bool isMe;
  final DateTime sentAt;
  final bool isSystem;

  const MockChatMessage({
    required this.content,
    required this.isMe,
    required this.sentAt,
    this.isSystem = false,
  });
}

class _SeedConversation {
  final String username;
  final int lastActiveMinutes;
  final bool isOnline;
  final Color avatarColor;
  final String lastMessageSeed;
  final String avatarAssetPath;

  const _SeedConversation(
    this.username,
    this.lastActiveMinutes,
    this.isOnline,
    this.avatarColor,
    this.lastMessageSeed,
    this.avatarAssetPath,
  );
}
