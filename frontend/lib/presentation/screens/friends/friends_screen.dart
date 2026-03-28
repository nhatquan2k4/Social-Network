import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/friend_entity.dart';
import 'package:frontend/presentation/widgets/common/bottom_nav.dart';
import 'package:frontend/presentation/screens/chat/chat_screen.dart';
import 'package:frontend/core/routes/app_routes.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _currentIndex = 3;

  static const List<_ConversationItemData> _figmaConversations = [
    _ConversationItemData(
      username: 'keociiu',
      subtitle: 'em iu ai nh +<3',
      timeLabel: '.now',
      isOnline: true,
      avatarColor: Color(0xFF8E695D),
    ),
    _ConversationItemData(
      username: 'thuytrng_04',
      subtitle: 'em sủi iu nhỏ bò nh',
      timeLabel: '.1phút',
      isOnline: true,
      avatarColor: Color(0xFF6C5A49),
    ),
    _ConversationItemData(
      username: 'quynhanh.xiu',
      subtitle: 'tuần sau mình đi tắm đào nhé anh iu',
      timeLabel: '.3h',
      isOnline: false,
      avatarColor: Color(0xFF6B9376),
    ),
    _ConversationItemData(
      username: 'khai_4.khai',
      subtitle: '5 phút nữa a qua nhé em iu',
      timeLabel: '.5h',
      isOnline: false,
      avatarColor: Color(0xFF8A6E59),
    ),
    _ConversationItemData(
      username: 'ngocha.66',
      subtitle: 'dành ở sân nào thế á',
      timeLabel: '.5 ngày',
      isOnline: false,
      avatarColor: Color(0xFF5A91AF),
    ),
    _ConversationItemData(
      username: 'dimhu27th4',
      subtitle: 'em iu anh <3',
      timeLabel: '.1 tuần',
      isOnline: true,
      avatarColor: Color(0xFFA17484),
    ),
    _ConversationItemData(
      username: 'thuonghip136',
      subtitle: 'học phòng nào đấy',
      timeLabel: '.5 tuần',
      isOnline: false,
      avatarColor: Color(0xFF8A7DA5),
    ),
    _ConversationItemData(
      username: 'trangg.ne',
      subtitle: 'chiều nay mình đi cafe không',
      timeLabel: '.2 phút',
      isOnline: true,
      avatarColor: Color(0xFF6F8EAD),
    ),
    _ConversationItemData(
      username: 'vannhh_22',
      subtitle: 'mai nộp bài nhóm nha bạn ơi',
      timeLabel: '.12 phút',
      isOnline: false,
      avatarColor: Color(0xFF95715E),
    ),
    _ConversationItemData(
      username: 'huytran.dev',
      subtitle: 'mình fix xong bug phần chat rồi',
      timeLabel: '.26 phút',
      isOnline: true,
      avatarColor: Color(0xFF4E7A8C),
    ),
    _ConversationItemData(
      username: 'linhchip_09',
      subtitle: 'đi ăn tokbokki không nè',
      timeLabel: '.41 phút',
      isOnline: false,
      avatarColor: Color(0xFFA16477),
    ),
    _ConversationItemData(
      username: 'khanh.97',
      subtitle: 'ảnh hôm qua đẹp ghê luôn',
      timeLabel: '.1h',
      isOnline: false,
      avatarColor: Color(0xFF6C8E72),
    ),
    _ConversationItemData(
      username: 'hoamaii_15',
      subtitle: 'đừng quên mang áo khoác nha',
      timeLabel: '.2h',
      isOnline: true,
      avatarColor: Color(0xFFB07A6A),
    ),
    _ConversationItemData(
      username: 'ngocxanhh',
      subtitle: 'chỗ đó nghe nhạc chill lắm',
      timeLabel: '.4h',
      isOnline: false,
      avatarColor: Color(0xFF5A88A6),
    ),
    _ConversationItemData(
      username: 'thu.minh_21',
      subtitle: 'gửi tui file design với nhaa',
      timeLabel: '.7h',
      isOnline: false,
      avatarColor: Color(0xFF8C78A8),
    ),
    _ConversationItemData(
      username: 'datlee.pro',
      subtitle: 'chiều chạy bộ 30p nhé',
      timeLabel: '.9h',
      isOnline: true,
      avatarColor: Color(0xFF6E7F53),
    ),
    _ConversationItemData(
      username: 'haann_84',
      subtitle: 'đã đặt bàn 7h tối rồi đó',
      timeLabel: '.1 ngày',
      isOnline: false,
      avatarColor: Color(0xFF9C6666),
    ),
    _ConversationItemData(
      username: 'tuanvu.works',
      subtitle: 'anh em mình code tiếp tối nay',
      timeLabel: '.2 ngày',
      isOnline: false,
      avatarColor: Color(0xFF5E7598),
    ),
    _ConversationItemData(
      username: 'nhii.cloud',
      subtitle: 'mình vừa cập nhật roadmap',
      timeLabel: '.3 ngày',
      isOnline: true,
      avatarColor: Color(0xFF88766C),
    ),
    _ConversationItemData(
      username: 'quocbao_11',
      subtitle: 'tháng này đi biển không mọi người',
      timeLabel: '.4 ngày',
      isOnline: false,
      avatarColor: Color(0xFF5F8A88),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F8),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'hoangtu_1',
              style: TextStyle(
                color: Color(0xFF171717),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF1F1F1F),
              size: 18,
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF1F1F1F), size: 22),
            onPressed: () {
              // TODO: Handle new message
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: const TextStyle(
                  color: Color(0xFF9A9AA1),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9A9AA1),
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xFFEDEDEF),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tin nhắn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF191919),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // TODO: Navigate to pending messages
                  },
                  child: const Text(
                    'Tin nhắn đang chờ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF3797EF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Conversations list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _figmaConversations.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = _figmaConversations[index];
                final friend = FriendEntity(
                  id: 'mock_$index',
                  username: item.username,
                  displayName: item.username,
                );

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _openChatWithFriend(context, friend),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 3,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: item.avatarColor,
                          child: Text(
                            item.username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.username,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.2,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1C1C1C),
                                      ),
                                    ),
                                  ),
                                  if (item.isOnline)
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF34C759),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF7B7B80),
                                  height: 1.25,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.timeLabel,
                          style: const TextStyle(
                            color: Color(0xFF9B9BA1),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
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
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;

          setState(() => _currentIndex = index);

          // Map tabs to routes that exist in this project.
          // 3 = Messages, 4 = Profile
          if (index == 3) {
            Navigator.pushReplacementNamed(context, AppRoutes.messages);
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, AppRoutes.profile);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Trang này chưa được triển khai.')),
            );
          }
        },
      ),
    );
  }

  // Mở chat preview theo UI Figma.
  Future<void> _openChatWithFriend(
    BuildContext context,
    FriendEntity friend,
  ) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(friend: friend, conversationId: null),
      ),
    );
  }
}

class _ConversationItemData {
  final String username;
  final String subtitle;
  final String timeLabel;
  final bool isOnline;
  final Color avatarColor;

  const _ConversationItemData({
    required this.username,
    required this.subtitle,
    required this.timeLabel,
    required this.isOnline,
    required this.avatarColor,
  });
}
