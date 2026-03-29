import 'package:flutter/material.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/data/services/local_storage_service.dart';
import 'package:frontend/domain/entities/post_entity.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Mochi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.black,
              size: 22,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thong bao se duoc them sau.')),
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
            if (feedProvider.requiresAuth && !_isHandlingAuthExpiry) {
              _isHandlingAuthExpiry = true;

              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if (!mounted) return;

                await _localStorage.clearToken();

                if (!mounted) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Phien dang nhap het han. Vui long dang nhap lai.',
                    ),
                  ),
                );

                Navigator.of(
                  this.context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              });
            }

            if (feedProvider.isLoadingInitial && feedProvider.posts.isEmpty) {
              return const FeedSkeletonList(itemCount: 2);
            }

            if (feedProvider.error != null && feedProvider.posts.isEmpty) {
              return ErrorDisplay(
                message: feedProvider.error!,
                onRetry: () => feedProvider.loadInitial(),
              );
            }

            if (feedProvider.posts.isEmpty) {
              return const EmptyState(
                message: 'Chua co bai viet nao',
                description: 'Hay quay lai sau hoac theo doi them ban be',
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
                    feedProvider.posts.length +
                    (feedProvider.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= feedProvider.posts.length) {
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

                  final post = feedProvider.posts[index];
                  final isLikedByMe =
                      _currentUserId != null &&
                      post.likes.contains(_currentUserId);

                  return PostCard(
                    post: post,
                    isLikedByMe: isLikedByMe,
                    onLike: () => _handleLike(
                      feedProvider: feedProvider,
                      postId: post.id,
                      isCurrentlyLiked: isLikedByMe,
                    ),
                    onComment: () => _openCommentsSheet(post),
                    onViewComments: () => _openCommentsSheet(post),
                    onShare: () {
                      ScaffoldMessenger.of(consumerContext).showSnackBar(
                        const SnackBar(
                          content: Text('Chia se se duoc them sau.'),
                        ),
                      );
                    },
                    onSave: () {
                      ScaffoldMessenger.of(consumerContext).showSnackBar(
                        const SnackBar(
                          content: Text('Luu bai viet se duoc them sau.'),
                        ),
                      );
                    },
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
          onTap: (index) {
            if (index == _currentIndex) return;

            setState(() => _currentIndex = index);

            if (index == 0) {
              Navigator.pushReplacementNamed(context, AppRoutes.postsFeed);
            } else if (index == 3) {
              Navigator.pushReplacementNamed(context, AppRoutes.messages);
            } else if (index == 4) {
              Navigator.pushReplacementNamed(context, AppRoutes.profile);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Trang nay chua duoc trien khai.'),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
