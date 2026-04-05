import 'package:flutter/material.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/core/utils/url_normalizer.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/domain/entities/friend_entity.dart';
import 'package:frontend/domain/entities/post_entity.dart';
import 'package:frontend/presentation/providers/chat_provider.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';
import 'package:frontend/presentation/screens/chat/chat_screen.dart';
import 'package:frontend/presentation/screens/feed/post_detail_screen.dart';
import 'package:provider/provider.dart';

class FriendProfileArgs {
  const FriendProfileArgs({
    required this.userId,
    required this.username,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.postsCount = 12,
    this.followersCount = 186,
    this.followingCount = 363,
  });

  final String userId;
  final String username;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final int postsCount;
  final int followersCount;
  final int followingCount;
}

class FriendProfileScreen extends StatefulWidget {
  const FriendProfileScreen({super.key, required this.args});

  final FriendProfileArgs args;

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final feedProvider = context.read<FeedProvider>();
      feedProvider.ensureLocalStateLoaded();
      if (feedProvider.posts.isEmpty) {
        feedProvider.loadInitial();
      }
    });
  }

  List<PostEntity> _friendPosts(List<PostEntity> posts) {
    final friendId = widget.args.userId.trim();
    if (friendId.isEmpty) return const [];

    return posts
        .where((post) => post.authorId.trim() == friendId)
        .toList(growable: false);
  }

  String? _postPreviewImage(PostEntity post) {
    for (final media in post.media) {
      final url = normalizeClientNetworkUrl((media.mediaUrl ?? '').trim());
      if (url.isNotEmpty) {
        return url;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final feedProvider = context.watch<FeedProvider>();
    final friendPosts = _friendPosts(feedProvider.posts);
    final isFollowing = feedProvider.isFollowingAuthor(widget.args.userId);
    final displayName = (widget.args.displayName ?? '').trim().isNotEmpty
        ? widget.args.displayName!.trim()
        : widget.args.username;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          widget.args.username,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
          IconButton(
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  _ProfileAvatar(
                    displayName: displayName,
                    avatarUrl: widget.args.avatarUrl,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Row(
                      children: [
                        _StatItem(
                          value: friendPosts.length.toString(),
                          label: l10n.postsLabel,
                        ),
                        _StatItem(
                          value: widget.args.followersCount.toString(),
                          label: l10n.followersLabel,
                        ),
                        _StatItem(
                          value: widget.args.followingCount.toString(),
                          label: l10n.followingLabel,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                displayName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            if ((widget.args.bio ?? '').trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: Text(
                  widget.args.bio!.trim(),
                  style: const TextStyle(
                    color: Color(0xFF212126),
                    fontSize: 13,
                    height: 1.25,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _PrimaryActionButton(
                      label: isFollowing
                          ? l10n.followingStatus
                          : l10n.followAction,
                      isPrimary: !isFollowing,
                      onTap: () {
                        feedProvider.toggleFollowAuthor(
                          authorId: widget.args.userId,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PrimaryActionButton(
                      label: l10n.privateMessage,
                      isPrimary: true,
                      onTap: _openDirectChat,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 86,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: const [
                  _StoryCircle(label: 'Mới', isAdd: true),
                  SizedBox(width: 10),
                  _StoryCircle(label: 'ice'),
                  SizedBox(width: 10),
                  _StoryCircle(label: 'chill'),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: IconButton(
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => setState(() => _selectedTab = 0),
                    icon: Icon(
                      Icons.grid_on,
                      color: _selectedTab == 0
                          ? Colors.black
                          : const Color(0xFF9B9BA1),
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    style: IconButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => setState(() => _selectedTab = 1),
                    icon: Icon(
                      Icons.person_pin_outlined,
                      color: _selectedTab == 1
                          ? Colors.black
                          : const Color(0xFF9B9BA1),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 2,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      color: _selectedTab == 0
                          ? Colors.black
                          : Colors.transparent,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: _selectedTab == 1
                          ? Colors.black
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            if (_selectedTab == 0)
              friendPosts.isEmpty
                  ? SizedBox(
                      height: 180,
                      child: Center(
                        child: Text(
                          'Người dùng này chưa có bài đăng',
                          style: const TextStyle(color: Color(0xFF8F8F95)),
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.only(top: 1),
                      itemCount: friendPosts.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 1,
                            mainAxisSpacing: 1,
                          ),
                      itemBuilder: (context, index) {
                        final post = friendPosts[index];
                        final sequencePostIds = friendPosts
                            .map((item) => item.id.trim())
                            .where((id) => id.isNotEmpty)
                            .toList(growable: false);
                        return _PostTile(
                          imageUrl: _postPreviewImage(post),
                          hasMultipleMedia: post.media.length > 1,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.postDetail,
                              arguments: PostDetailArgs(
                                postId: post.id,
                                sequencePostIds: sequencePostIds,
                              ),
                            );
                          },
                        );
                      },
                    )
            else
              SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    l10n.taggedPostsEmpty,
                    style: const TextStyle(color: Color(0xFF8F8F95)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDirectChat() async {
    final userId = widget.args.userId.trim();
    final username = widget.args.username.trim();
    final displayName = (widget.args.displayName ?? '').trim().isNotEmpty
        ? widget.args.displayName!.trim()
        : username;

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.featureInDevelopment)),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final chatProvider = context.read<ChatProvider>();
      await chatProvider.createAndLoadConversation(userId);

      if (!mounted) return;
      Navigator.pop(context);

      final friend = FriendEntity(
        id: userId,
        username: username.isNotEmpty ? username : userId,
        displayName: displayName,
      );

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            friend: friend,
            conversationId: chatProvider.currentConversationId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.cannotOpenChat(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.displayName, required this.avatarUrl});

  final String displayName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final normalizedAvatarUrl = (avatarUrl ?? '').trim();

    return Container(
      width: 84,
      height: 84,
      padding: const EdgeInsets.all(1.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFDADADF)),
      ),
      child: CircleAvatar(
        backgroundColor: const Color(0xFFE1E1E6),
        foregroundImage: normalizedAvatarUrl.isNotEmpty
            ? NetworkImage(normalizedAvatarUrl)
            : null,
        child: normalizedAvatarUrl.isEmpty
            ? Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Color(0xFF2D2D32),
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              )
            : null,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6E6E74),
              fontSize: 12,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? const Color(0xFF1689F6)
              : const Color(0xFFEFEFF1),
          foregroundColor: isPrimary ? Colors.white : const Color(0xFF222227),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        child: Text(label),
      ),
    );
  }
}

class _StoryCircle extends StatelessWidget {
  const _StoryCircle({required this.label, this.isAdd = false});

  final String label;
  final bool isAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD9D9DE)),
            ),
            child: isAdd
                ? const Icon(Icons.add, color: Color(0xFF2C2C31), size: 28)
                : Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/image 74.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PostTile extends StatelessWidget {
  const _PostTile({
    required this.imageUrl,
    required this.hasMultipleMedia,
    required this.onTap,
  });

  final String? imageUrl;
  final bool hasMultipleMedia;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFE6E6E9),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(0xFF99999F),
                ),
              ),
            )
          else
            Container(
              color: const Color(0xFFE6E6E9),
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: Color(0xFF99999F),
              ),
            ),
          if (hasMultipleMedia)
            Positioned(
              top: 6,
              right: 6,
              child: Icon(
                Icons.content_copy_rounded,
                size: 14,
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
        ],
      ),
    );
  }
}
