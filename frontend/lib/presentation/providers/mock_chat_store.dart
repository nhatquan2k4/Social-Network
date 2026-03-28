import 'package:flutter/material.dart';

class MockChatStore extends ChangeNotifier {
  MockChatStore._();

  static final MockChatStore instance = MockChatStore._();

  final DateTime _now = DateTime.now();

  late final List<MockConversation> _conversations =
      _buildInitialConversations();

  List<MockConversation> visibleConversations(String query) {
    final normalized = query.trim().toLowerCase();

    final filtered = _conversations.where((c) {
      if (c.isDeleted || c.isHidden) return false;
      if (normalized.isEmpty) return true;

      return c.username.toLowerCase().contains(normalized) ||
          c.lastPreviewText.toLowerCase().contains(normalized);
    }).toList();

    filtered.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.lastMessageAt.compareTo(a.lastMessageAt);
    });

    return filtered;
  }

  List<MockChatMessage> conversationMessages(String conversationId) {
    final conversation = _findById(conversationId);
    if (conversation == null) return [];
    return List<MockChatMessage>.from(conversation.messages);
  }

  MockConversation? conversationById(String id) => _findById(id);

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

  void deleteConversation(String conversationId) {
    final conversation = _findById(conversationId);
    if (conversation == null) return;

    conversation.isDeleted = true;
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

      return MockConversation(
        id: conversationId,
        username: seed.username,
        avatarColor: seed.avatarColor,
        avatarAssetPath: seed.avatarAssetPath,
        isOnline: seed.isOnline,
        isPinned: seed.lastActiveMinutes <= 2,
        unreadCount: unread,
        messages: messages,
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
}

class MockConversation {
  final String id;
  final String username;
  final Color avatarColor;
  final String avatarAssetPath;
  final bool isOnline;
  List<MockChatMessage> messages;

  bool isPinned;
  bool isHidden;
  bool isDeleted;
  int unreadCount;
  DateTime lastMessageAt;

  MockConversation({
    required this.id,
    required this.username,
    required this.avatarColor,
    required this.avatarAssetPath,
    required this.isOnline,
    required this.messages,
    required this.lastMessageAt,
    this.isPinned = false,
    this.isHidden = false,
    this.isDeleted = false,
    this.unreadCount = 0,
  });

  MockChatMessage get lastMessage => messages.last;

  String get lastPreviewText {
    final message = lastMessage;
    return message.isMe ? 'Bạn: ${message.content}' : message.content;
  }
}

class MockChatMessage {
  final String content;
  final bool isMe;
  final DateTime sentAt;

  const MockChatMessage({
    required this.content,
    required this.isMe,
    required this.sentAt,
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
