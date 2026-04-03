import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/presentation/controllers/common/bottom_nav_route_controller.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';
import 'package:frontend/presentation/screens/profile/friend_profile_screen.dart';
import 'package:frontend/presentation/widgets/common/bottom_nav.dart';
import 'package:frontend/presentation/widgets/common/follow_status_chip.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final List<_RecentSearchUser> _seedRecentUsers = [
    const _RecentSearchUser(
      id: 'im.chan9',
      name: 'Chan 🐬',
      username: 'im.chan9',
      avatarAssetPath: 'assets/images/image 74.png',
    ),
    const _RecentSearchUser(
      id: 'nhu.phuong__',
      name: 'Nhu Phuong',
      username: 'nhu.phuong__',
      avatarAssetPath: 'assets/images/image 75.png',
    ),
    const _RecentSearchUser(
      id: 'thao.bui.__',
      name: 'Thỏ Bùi',
      username: 'thao.bui.__',
      avatarAssetPath: 'assets/images/image 76.png',
    ),
    const _RecentSearchUser(
      id: 'make_upisme',
      name: 'Phuonghaisme',
      username: 'make_upisme',
      avatarAssetPath: 'assets/images/image 77.png',
    ),
    const _RecentSearchUser(
      id: 'bemeo.dthvvv',
      name: 'Bé mèo dễ thương',
      username: 'bemeo.dthvvv',
      avatarAssetPath: 'assets/images/image 78.png',
    ),
    const _RecentSearchUser(
      id: 'khly.2001',
      name: 'Khánh Ly',
      username: 'khly.2001',
      avatarAssetPath: 'assets/images/image 79.png',
    ),
    const _RecentSearchUser(
      id: 'qtchan_74',
      name: 'Trần Thu Trang',
      username: 'qtchan_74',
      avatarAssetPath: 'assets/images/image 80.png',
    ),
    const _RecentSearchUser(
      id: 'min_weyi',
      name: 'Minh Ngọc',
      username: 'min_weyi',
      avatarAssetPath: 'assets/images/image 81.png',
    ),
  ];

  final Set<String> _dismissedRecentUserIds = <String>{};

  final List<String> _gridImages = const [
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

  int _currentIndex = 1;

  bool get _isSearchMode {
    return _searchFocusNode.hasFocus || _searchController.text.trim().isNotEmpty;
  }

  List<_RecentSearchUser> _buildRecentUsers(FeedProvider feedProvider) {
    final usersById = <String, _RecentSearchUser>{};

    for (final post in feedProvider.posts) {
      final id = post.authorId.trim();
      if (id.isEmpty) continue;

      final username = (post.authorUsername ?? '').trim();
      final displayUsername = username.isNotEmpty ? username : id;
      final displayName = (post.authorDisplayName ?? '').trim();

      usersById[id] = _RecentSearchUser(
        id: id,
        name: displayName.isNotEmpty ? displayName : displayUsername,
        username: displayUsername,
        avatarUrl: (post.authorAvatarUrl ?? '').trim(),
      );
    }

    for (final user in _seedRecentUsers) {
      usersById.putIfAbsent(user.id, () => user);
    }

    return usersById.values
        .where((user) => !_dismissedRecentUserIds.contains(user.id))
        .toList(growable: false);
  }

  List<_RecentSearchUser> _filteredRecentUsers(List<_RecentSearchUser> users) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return users;

    return users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.username.toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _searchFocusNode.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final feedProvider = context.read<FeedProvider>();
      feedProvider.ensureLocalStateLoaded();
      if (feedProvider.posts.isEmpty) {
        feedProvider.loadInitial();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _removeRecentUser(_RecentSearchUser user) {
    setState(() {
      _dismissedRecentUserIds.add(user.id);
    });
  }

  void _cancelSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  Future<void> _openFriendProfile(_RecentSearchUser user) async {
    await Navigator.of(context).pushNamed(
      AppRoutes.profileFriend,
      arguments: FriendProfileArgs(
        userId: user.id,
        username: user.username,
        displayName: user.name,
        avatarUrl: user.avatarUrl,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final feedProvider = context.watch<FeedProvider>();
    final recentUsers = _buildRecentUsers(feedProvider);
    final filteredRecentUsers = _filteredRecentUsers(recentUsers);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F4),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF2F2F4),
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.search,
                            size: 18,
                            color: Color(0xFF8B8B91),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              decoration: InputDecoration(
                                isCollapsed: true,
                                border: InputBorder.none,
                                hintText: l10n.searchGeneric,
                                hintStyle: const TextStyle(
                                  color: Color(0xFF8B8B91),
                                  fontSize: 15,
                                ),
                              ),
                              style: const TextStyle(
                                color: Color(0xFF1F1F23),
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: _searchController.clear,
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB8B8BE),
                                  borderRadius: BorderRadius.circular(99),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_isSearchMode) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _cancelSearch,
                      child: Text(
                        l10n.cancel,
                        style: const TextStyle(
                          color: Color(0xFF1689F6),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: _isSearchMode
                  ? _RecentSearchList(
                      title: l10n.recentSearchTitle,
                      users: filteredRecentUsers,
                      onRemove: _removeRecentUser,
                      isFollowing: (authorId) =>
                          feedProvider.isFollowingAuthor(authorId),
                      onToggleFollow: (authorId) {
                        feedProvider.toggleFollowAuthor(authorId: authorId);
                      },
                      onOpenProfile: _openFriendProfile,
                      followingText: l10n.followingStatus,
                      followText: l10n.followAction,
                    )
                  : _ExploreGrid(images: _gridImages),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => BottomNavRouteController.handleTabSelection(
          context: context,
          currentIndex: _currentIndex,
          nextIndex: index,
          onIndexChanged: (next) => setState(() => _currentIndex = next),
          onUnsupportedDestination: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.pageNotImplemented)),
            );
          },
        ),
      ),
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  const _ExploreGrid({required this.images});

  final List<String> images;
  static const double _gridSpacing = 1;
  static const int _crossAxisCount = 3;
  static const double _tileHeightRatio = 1.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSpacing = (_crossAxisCount - 1) * _gridSpacing;
        final tileWidth = (constraints.maxWidth - totalSpacing) / _crossAxisCount;
        final tileHeight = tileWidth * _tileHeightRatio;

        return GridView.builder(
          padding: EdgeInsets.zero,
          itemCount: images.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount,
            mainAxisSpacing: _gridSpacing,
            crossAxisSpacing: _gridSpacing,
            childAspectRatio: tileWidth / tileHeight,
          ),
          itemBuilder: (context, index) {
            final imagePath = images[index % images.length];

            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(imagePath, fit: BoxFit.cover),
                const Positioned(
                  top: 6,
                  right: 6,
                  child: _GridOverlayIcon(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _RecentSearchList extends StatelessWidget {
  const _RecentSearchList({
    required this.title,
    required this.users,
    required this.onRemove,
    required this.isFollowing,
    required this.onToggleFollow,
    required this.onOpenProfile,
    required this.followingText,
    required this.followText,
  });

  final String title;
  final List<_RecentSearchUser> users;
  final ValueChanged<_RecentSearchUser> onRemove;
  final bool Function(String authorId) isFollowing;
  final ValueChanged<String> onToggleFollow;
  final ValueChanged<_RecentSearchUser> onOpenProfile;
  final String followingText;
  final String followText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF222227),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final avatarProvider = (user.avatarUrl != null &&
                      user.avatarUrl!.trim().isNotEmpty)
                  ? NetworkImage(user.avatarUrl!.trim()) as ImageProvider
                  : (user.avatarAssetPath != null &&
                        user.avatarAssetPath!.trim().isNotEmpty)
                  ? AssetImage(user.avatarAssetPath!.trim()) as ImageProvider
                  : null;

              return SizedBox(
                height: 66,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => onOpenProfile(user),
                          borderRadius: BorderRadius.circular(10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xFFE3E3E8),
                                foregroundImage: avatarProvider,
                                child: avatarProvider == null
                                    ? Text(
                                        user.name.isNotEmpty
                                            ? user.name[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Color(0xFF34343A),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF1E1E23),
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600,
                                        height: 1.05,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      user.username,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF8A8A91),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        height: 1.05,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FollowStatusChip(
                        isFollowing: isFollowing(user.id),
                        followingText: followingText,
                        followText: followText,
                        onTap: () => onToggleFollow(user.id),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF444449),
                          size: 21,
                        ),
                        onPressed: () => onRemove(user),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentSearchUser {
  const _RecentSearchUser({
    required this.id,
    required this.name,
    required this.username,
    this.avatarAssetPath,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String username;
  final String? avatarAssetPath;
  final String? avatarUrl;
}

class _GridOverlayIcon extends StatelessWidget {
  const _GridOverlayIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 14,
      height: 14,
      child: CustomPaint(painter: _GridOverlayPainter()),
    );
  }
}

class _GridOverlayPainter extends CustomPainter {
  const _GridOverlayPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white
      ..strokeJoin = StrokeJoin.round;

    final backRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(2.2, 1.7, 8.2, 8.2),
      const Radius.circular(1.8),
    );
    final frontRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4.2, 3.7, 8.2, 8.2),
      const Radius.circular(1.8),
    );

    canvas.drawRRect(backRect, stroke);
    canvas.drawRRect(frontRect, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
