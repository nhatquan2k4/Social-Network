import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/data/services/local_storage_service.dart';
import 'package:frontend/domain/entities/post_entity.dart';
import 'package:frontend/presentation/controllers/common/bottom_nav_route_controller.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';
import 'package:frontend/presentation/providers/notification_provider.dart';
import 'package:frontend/presentation/screens/profile/friend_profile_screen.dart';
import 'package:frontend/presentation/widgets/common/bottom_nav.dart';
import 'package:frontend/presentation/widgets/common/empty_state.dart';
import 'package:frontend/presentation/widgets/common/error_display.dart';
import 'package:frontend/presentation/widgets/feed/feed_widgets.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/logger.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  final LocalStorageService _localStorage = LocalStorageService();

  String? _currentUserId;
  int _currentIndex = 0;
  bool _isHandlingAuthExpiry = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCurrentUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final feedProvider = context.read<FeedProvider>();
      if (feedProvider.posts.isEmpty) {
        feedProvider.loadInitial();
      }
      context.read<NotificationProvider>().syncUnreadCount();
    });
  }

  Future<void> _loadCurrentUser() async {
    final token = await _localStorage.getToken();
    if (token == null) return;

    try {
      final decoded = JwtDecoder.decode(token);
      final rawUserId =
          decoded['userId'] ??
          decoded['_id'] ??
          decoded['id'] ??
          decoded['sub'];
      setState(() {
        _currentUserId = rawUserId?.toString();
      });
    } catch (e, stackTrace) {
      logger.e(
        'Cannot decode auth token: $e',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 280) {
      context.read<FeedProvider>().loadMore();
    }
  }

  Future<void> _handleLike({
    required FeedProvider feedProvider,
    required String postId,
    required bool isCurrentlyLiked,
  }) async {
    await feedProvider.toggleLike(
      postId: postId,
      isCurrentlyLiked: isCurrentlyLiked,
    );

    if (!mounted) return;
    if (feedProvider.requiresAuth) return;

    final message = feedProvider.error;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      feedProvider.clearError();
    }
  }

  Future<void> _openCommentsSheet(PostEntity initialPost) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(
        initialPost: initialPost,
        currentUserId: _currentUserId,
      ),
    );
  }

  Future<void> _openCreatePostScreen() async {
    await Navigator.of(context).pushNamed(AppRoutes.postsCreate);
  }

  Future<void> _openFriendProfileFromPost(PostEntity post) async {
    final username = (post.authorUsername ?? '').trim().isNotEmpty
        ? post.authorUsername!.trim()
        : post.authorId;

    await Navigator.of(context).pushNamed(
      AppRoutes.profileFriend,
      arguments: FriendProfileArgs(
        userId: post.authorId,
        username: username,
        displayName: (post.authorDisplayName ?? '').trim().isNotEmpty
            ? post.authorDisplayName!.trim()
            : username,
        avatarUrl: (post.authorAvatarUrl ?? '').trim().isNotEmpty
            ? post.authorAvatarUrl!.trim()
            : null,
        bio: post.content,
        postsCount: 12,
        followersCount: (post.likes.length * 4) + 30,
        followingCount: (post.commentsCount * 3) + 50,
      ),
    );
  }

  Future<void> _showPostOptionsSheet(PostEntity post) async {
    final l10n = context.l10n;

    final selectedAction = await showModalBottomSheet<_PostOptionAction>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      isScrollControlled: false,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 34,
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD2D2D6),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildPostOptionsGroup(
                    children: [
                      _buildPostOptionTile(
                        icon: Icons.star_border,
                        label: l10n.postOptionAddToFavorites,
                        onTap: () => Navigator.pop(
                          sheetContext,
                          _PostOptionAction.addToFavorites,
                        ),
                      ),
                      _buildPostOptionTile(
                        icon: Icons.person_search_outlined,
                        label: l10n.postOptionAboutThisAccount,
                        onTap: () => Navigator.pop(
                          sheetContext,
                          _PostOptionAction.aboutAccount,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPostOptionsGroup(
                    children: [
                      _buildPostOptionTile(
                        icon: Icons.visibility_off_outlined,
                        label: l10n.postOptionHidePost,
                        onTap: () => Navigator.pop(
                          sheetContext,
                          _PostOptionAction.hidePost,
                        ),
                      ),
                      _buildPostOptionTile(
                        icon: Icons.report_gmailerrorred_outlined,
                        label: l10n.postOptionReport,
                        labelColor: const Color(0xFFE53935),
                        iconColor: const Color(0xFFE53935),
                        onTap: () => Navigator.pop(
                          sheetContext,
                          _PostOptionAction.report,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || selectedAction == null) return;

    final feedProvider = context.read<FeedProvider>();
    final messenger = ScaffoldMessenger.of(context);

    switch (selectedAction) {
      case _PostOptionAction.addToFavorites:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.postOptionAddToFavoritesDone)),
        );
        break;
      case _PostOptionAction.aboutAccount:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.featureInDevelopment)),
        );
        break;
      case _PostOptionAction.hidePost:
        await feedProvider.hidePost(post.id);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.postOptionHidePostDone)),
        );
        break;
      case _PostOptionAction.report:
        final reportReason = await _showReportReasonSheet();
        if (!mounted || reportReason == null) return;

        final reasonKey = reportReason.name;
        await feedProvider.reportPost(
          postId: post.id,
          reason: reasonKey,
        );

        if (!mounted) return;
        final providerError = feedProvider.error;
        if (providerError != null && providerError.isNotEmpty) {
          messenger.showSnackBar(SnackBar(content: Text(providerError)));
          feedProvider.clearError();
          return;
        }

        messenger.showSnackBar(
          SnackBar(
            content: Text(
              l10n.postOptionReportDoneWithReason(
                _reportReasonLabel(reportReason, l10n),
              ),
            ),
          ),
        );
        break;
    }
  }

  String _reportReasonLabel(_PostReportReason reason, dynamic l10n) {
    switch (reason) {
      case _PostReportReason.spam:
        return l10n.postReportReasonSpam;
      case _PostReportReason.harassment:
        return l10n.postReportReasonHarassment;
      case _PostReportReason.falseInfo:
        return l10n.postReportReasonFalseInfo;
      case _PostReportReason.hateSpeech:
        return l10n.postReportReasonHateSpeech;
      case _PostReportReason.violence:
        return l10n.postReportReasonViolence;
      case _PostReportReason.other:
        return l10n.postReportReasonOther;
    }
  }

  Future<_PostReportReason?> _showReportReasonSheet() async {
    final l10n = context.l10n;
    _PostReportReason? selectedReason;

    return showModalBottomSheet<_PostReportReason>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      isScrollControlled: false,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          width: 34,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFD2D2D6),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.postReportTitle,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.postReportSelectReason,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF66666B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._PostReportReason.values.map((reason) {
                        final isSelected = selectedReason == reason;

                        return InkWell(
                          onTap: () => setSheetState(() {
                            selectedReason = reason;
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  size: 20,
                                  color: isSelected
                                      ? const Color(0xFF1689F6)
                                      : const Color(0xFF96969B),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _reportReasonLabel(reason, l10n),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF1A1A1F),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(sheetContext),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(l10n.cancel),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: selectedReason == null
                                    ? null
                                    : () => Navigator.pop(
                                        sheetContext,
                                        selectedReason,
                                      ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE53935),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(l10n.postReportSubmit),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPostOptionsGroup({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildPostOptionTile({
    required IconData icon,
    required String label,
    Color labelColor = const Color(0xFF111111),
    Color iconColor = const Color(0xFF111111),
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 17, color: iconColor),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 22 / 1.8,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.add_box_outlined,
            color: Colors.black,
            size: 22,
          ),
          onPressed: _openCreatePostScreen,
        ),
        title: Image.asset(
          'assets/images/logo.jpg',
          height: 34,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Mochi',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.black),
              ],
            );
          },
        ),
        centerTitle: true,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              final unreadCount = notificationProvider.unreadCount;

              return IconButton(
                onPressed: () async {
                  await Navigator.of(context).pushNamed(AppRoutes.notifications);
                  if (!mounted) return;
                  notificationProvider.syncUnreadCount();
                },
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_none,
                      color: Colors.black,
                      size: 22,
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.8),
          child: Container(height: 0.8, color: Colors.grey.shade200),
        ),
      ),
      body: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: Consumer<FeedProvider>(
          builder: (consumerContext, feedProvider, _) {
            final visiblePosts = feedProvider.visiblePosts;

            if (feedProvider.requiresAuth && !_isHandlingAuthExpiry) {
              _isHandlingAuthExpiry = true;

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;

                await _localStorage.clearToken();

                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text(l10n.sessionExpiredRelogin)),
                );

                Navigator.of(
                  this.context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              });
            }

            if (feedProvider.isLoadingInitial && visiblePosts.isEmpty) {
              return const FeedSkeletonList(itemCount: 2);
            }

            if (feedProvider.error != null && visiblePosts.isEmpty) {
              return ErrorDisplay(
                message: feedProvider.error!,
                onRetry: () => feedProvider.loadInitial(),
              );
            }

            if (visiblePosts.isEmpty) {
              return EmptyState(
                message: l10n.postOptionAllHiddenTitle,
                description: l10n.postOptionAllHiddenDescription,
                icon: Icons.photo_library_outlined,
              );
            }

            return RefreshIndicator(
              onRefresh: () => feedProvider.refresh(),
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(top: 6, bottom: 4),
                itemCount:
                    1 +
                    visiblePosts.length +
                    (feedProvider.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildStoriesStrip(visiblePosts, l10n);
                  }

                  final postIndex = index - 1;

                  if (postIndex >= visiblePosts.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final post = visiblePosts[postIndex];
                  final isLikedByMe =
                      _currentUserId != null &&
                      post.likes.contains(_currentUserId);
                  final isFollowingAuthor = feedProvider.isFollowingAuthor(
                    post.authorId,
                    currentUserId: _currentUserId,
                  );
                  final isOwnPost =
                      _currentUserId != null && post.authorId == _currentUserId;

                  return PostCard(
                    post: post,
                    isLikedByMe: isLikedByMe,
                    isFollowing: isFollowingAuthor,
                    onLike: () => _handleLike(
                      feedProvider: feedProvider,
                      postId: post.id,
                      isCurrentlyLiked: isLikedByMe,
                    ),
                    onFollowTap: isOwnPost
                        ? null
                        : () {
                            feedProvider.toggleFollowAuthor(
                              authorId: post.authorId,
                              currentUserId: _currentUserId,
                            );
                          },
                    onAuthorTap: () => _openFriendProfileFromPost(post),
                    onComment: () => _openCommentsSheet(post),
                    onViewComments: () => _openCommentsSheet(post),
                    onShare: () {
                      ScaffoldMessenger.of(consumerContext).showSnackBar(
                        SnackBar(content: Text(l10n.shareSoon)),
                      );
                    },
                    onSave: () {
                      ScaffoldMessenger.of(consumerContext).showSnackBar(
                        SnackBar(content: Text(l10n.saveSoon)),
                      );
                    },
                    onMore: () => _showPostOptionsSheet(post),
                    followingLabel: l10n.followingStatus,
                  );
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: BottomNav(
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
      ),
    );
  }

  Widget _buildStoriesStrip(List<PostEntity> posts, dynamic l10n) {
    final stories = _buildStoriesData(posts, l10n);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
          child: SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: stories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final story = stories[index];
                return _FeedStoryItem(story: story);
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  List<_FeedStoryData> _buildStoriesData(List<PostEntity> posts, dynamic l10n) {
    final stories = <_FeedStoryData>[
      _FeedStoryData(
        label: l10n.yourStory,
        avatarUrl: 'assets/images/logo1.jpg',
        isAsset: true,
        showPlusBadge: true,
      ),
    ];

    final usedIds = <String>{};
    for (final post in posts) {
      if (usedIds.contains(post.authorId)) continue;
      usedIds.add(post.authorId);

      final username = (post.authorUsername ?? '').trim();
      final displayLabel = username.isNotEmpty
          ? username
          : post.authorId.substring(0, post.authorId.length > 8 ? 8 : post.authorId.length);

      stories.add(
        _FeedStoryData(
          label: displayLabel,
          avatarUrl: (post.authorAvatarUrl ?? '').trim(),
        ),
      );

      if (stories.length >= 8) break;
    }

    return stories;
  }
}

enum _PostOptionAction {
  addToFavorites,
  aboutAccount,
  hidePost,
  report,
}

enum _PostReportReason {
  spam,
  harassment,
  falseInfo,
  hateSpeech,
  violence,
  other,
}

class _FeedStoryData {
  const _FeedStoryData({
    required this.label,
    required this.avatarUrl,
    this.isAsset = false,
    this.showPlusBadge = false,
  });

  final String label;
  final String avatarUrl;
  final bool isAsset;
  final bool showPlusBadge;
}

class _FeedStoryItem extends StatelessWidget {
  const _FeedStoryItem({required this.story});

  final _FeedStoryData story;

  @override
  Widget build(BuildContext context) {
    final hasAvatar = story.avatarUrl.isNotEmpty;

    Widget avatarChild;
    if (!hasAvatar) {
      avatarChild = const CircleAvatar(
        radius: 25,
        backgroundColor: Color(0xFFDADADA),
        child: Icon(Icons.person, color: Color(0xFF8A8A90)),
      );
    } else if (story.isAsset) {
      avatarChild = CircleAvatar(
        radius: 25,
        foregroundImage: AssetImage(story.avatarUrl),
        backgroundColor: const Color(0xFFDADADA),
      );
    } else {
      avatarChild = CircleAvatar(
        radius: 25,
        foregroundImage: NetworkImage(story.avatarUrl),
        backgroundColor: const Color(0xFFDADADA),
      );
    }

    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2.4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF93A6B), Color(0xFFFFA64D), Color(0xFF8A3CFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(1.6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: avatarChild,
                ),
              ),
              if (story.showPlusBadge)
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1689F6),
                      borderRadius: BorderRadius.circular(99),
                      border: Border.all(color: Colors.white, width: 1.4),
                    ),
                    child: const Icon(Icons.add, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            story.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF212126),
            ),
          ),
        ],
      ),
    );
  }
}
