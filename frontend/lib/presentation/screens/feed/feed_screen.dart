import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/data/services/local_storage_service.dart';
import 'package:frontend/domain/entities/post_entity.dart';
import 'package:frontend/presentation/controllers/common/bottom_nav_route_controller.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';
import 'package:frontend/presentation/providers/notification_provider.dart';
import 'package:frontend/presentation/providers/profile_provider.dart';
import 'package:frontend/presentation/screens/profile/friend_profile_screen.dart';
import 'package:frontend/presentation/widgets/common/bottom_nav.dart';
import 'package:frontend/presentation/widgets/common/empty_state.dart';
import 'package:frontend/presentation/widgets/common/error_display.dart';
import 'package:frontend/presentation/widgets/feed/feed_widgets.dart';
import 'package:frontend/presentation/widgets/feed/feed_story_item.dart';
import 'package:frontend/presentation/widgets/feed/post_options_sheet.dart';
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

    final selectedAction = await showPostOptionsSheet(context, post);
    if (!mounted || selectedAction == null) return;

    final feedProvider = context.read<FeedProvider>();
    final messenger = ScaffoldMessenger.of(context);

    switch (selectedAction) {
      case PostOptionAction.addToFavorites:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.postOptionAddToFavoritesDone)),
        );
        break;
      case PostOptionAction.aboutAccount:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.featureInDevelopment)),
        );
        break;
      case PostOptionAction.hidePost:
        await feedProvider.hidePost(post.id);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.postOptionHidePostDone)),
        );
        break;
      case PostOptionAction.report:
        final reportReason = await showReportReasonSheet(context);
        if (!mounted || reportReason == null) return;

        final reasonKey = reportReason.name;
        await feedProvider.reportPost(postId: post.id, reason: reasonKey);

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
                reportReasonLabel(reportReason, l10n),
              ),
            ),
          ),
        );
        break;
    }
  }

  // report label and UI moved to `post_options_sheet.dart`.

  // Post options and report sheet UI moved to `post_options_sheet.dart`.

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final myProfile = context.watch<ProfileProvider>().profile;

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
                  await Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.notifications);
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
                      ScaffoldMessenger.of(
                        consumerContext,
                      ).showSnackBar(SnackBar(content: Text(l10n.shareSoon)));
                    },
                    onSave: () {
                      ScaffoldMessenger.of(
                        consumerContext,
                      ).showSnackBar(SnackBar(content: Text(l10n.saveSoon)));
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
          profileAvatarUrl: myProfile?.avatarUrl,
          profileDisplayName: myProfile?.displayName,
          onTap: (index) => BottomNavRouteController.handleTabSelection(
            context: context,
            currentIndex: _currentIndex,
            nextIndex: index,
            onIndexChanged: (next) => setState(() => _currentIndex = next),
            onUnsupportedDestination: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.pageNotImplemented)));
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
                return FeedStoryItem(story: story);
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  List<FeedStoryData> _buildStoriesData(List<PostEntity> posts, dynamic l10n) {
    final stories = <FeedStoryData>[
      const FeedStoryData(
        label: '',
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
          : post.authorId.substring(
              0,
              post.authorId.length > 8 ? 8 : post.authorId.length,
            );

      stories.add(
        FeedStoryData(
          label: displayLabel,
          avatarUrl: (post.authorAvatarUrl ?? '').trim(),
        ),
      );

      if (stories.length >= 8) break;
    }

    return stories;
  }
}
