import 'package:flutter/material.dart';
import 'package:frontend/core/routes/app_routes.dart';
import 'package:frontend/domain/entities/post_comment_entity.dart';
import 'package:frontend/data/services/local_storage_service.dart';
import 'package:frontend/domain/entities/post_entity.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';
import 'package:frontend/presentation/screens/profile/friend_profile_screen.dart';
import 'package:frontend/presentation/widgets/common/error_display.dart';
import 'package:frontend/presentation/widgets/feed/comments_sheet.dart';
import 'package:frontend/presentation/widgets/feed/post_card.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

class PostDetailArgs {
  const PostDetailArgs({
    required this.postId,
    this.highlightCommentId,
    this.autoReplyCommentId,
    this.openCommentsOnLoad = false,
  });

  final String postId;
  final String? highlightCommentId;
  final String? autoReplyCommentId;
  final bool openCommentsOnLoad;
}

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.args});

  final PostDetailArgs args;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen>
    with SingleTickerProviderStateMixin {
  final LocalStorageService _localStorage = LocalStorageService();
  final Map<String, GlobalKey> _commentKeys = <String, GlobalKey>{};

  String? _currentUserId;
  bool _isLoading = true;
  int _selectedTab = 0;
  String? _activeHighlightCommentId;
  bool _didAutoScrollHighlight = false;
  bool _didOpenInitialComments = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.args.openCommentsOnLoad ? 1 : 0;
    _activeHighlightCommentId = widget.args.highlightCommentId?.trim();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    if ((_activeHighlightCommentId ?? '').isNotEmpty) {
      _pulseController.repeat(reverse: true);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadCurrentUser();
      await _ensurePostLoaded();
      if (!mounted) return;
      setState(() => _isLoading = false);
      _openCommentsIfNeeded();
    });
  }

  void _openCommentsIfNeeded() {
    if (_didOpenInitialComments) return;
    if (!widget.args.openCommentsOnLoad) return;

    final post = context.read<FeedProvider>().postById(widget.args.postId);
    if (post == null) return;

    _didOpenInitialComments = true;
    _openCommentsSheet(post);
  }

  Future<void> _loadCurrentUser() async {
    final token = await _localStorage.getToken();
    if (token == null) return;

    try {
      final decoded = JwtDecoder.decode(token);
      _currentUserId = (decoded['userId'] ??
              decoded['_id'] ??
              decoded['id'] ??
              decoded['sub'])
          ?.toString();
    } catch (_) {
      _currentUserId = null;
    }
  }

  Future<void> _ensurePostLoaded() async {
    final postId = widget.args.postId.trim();
    if (postId.isEmpty) return;

    await context.read<FeedProvider>().ensurePostById(postId);
  }

  Future<void> _openCommentsSheet(PostEntity post) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(
        initialPost: post,
        currentUserId: _currentUserId,
        highlightedCommentId: widget.args.highlightCommentId,
        initialReplyCommentId: widget.args.autoReplyCommentId,
        autoFocusComposer: (widget.args.autoReplyCommentId ?? '').isNotEmpty,
      ),
    );
  }

  List<_FlattenedComment> _buildFlattenedComments(
    List<PostCommentEntity> comments,
  ) {
    if (comments.isEmpty) {
      return const [];
    }

    final sorted = List<PostCommentEntity>.from(comments)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final allIds = sorted.map((item) => item.id).toSet();

    final Map<String, List<PostCommentEntity>> byParent = {};
    final List<PostCommentEntity> roots = [];

    for (final comment in sorted) {
      final parentId = comment.parentCommentId;
      if (parentId == null || parentId.isEmpty || !allIds.contains(parentId)) {
        roots.add(comment);
        continue;
      }

      byParent.putIfAbsent(parentId, () => []).add(comment);
    }

    final result = <_FlattenedComment>[];
    final visited = <String>{};

    void appendComment(PostCommentEntity comment, int depth) {
      if (visited.contains(comment.id)) {
        return;
      }

      visited.add(comment.id);
      result.add(_FlattenedComment(comment: comment, depth: depth));

      final children = byParent[comment.id] ?? const [];
      for (final child in children) {
        appendComment(child, depth + 1);
      }
    }

    for (final root in roots) {
      appendComment(root, 0);
    }

    if (result.length != sorted.length) {
      for (final comment in sorted) {
        if (!visited.contains(comment.id)) {
          appendComment(comment, 0);
        }
      }
    }

    return result;
  }

  void _tryAutoHighlightInTab(List<_FlattenedComment> comments) {
    if (_selectedTab != 1) return;
    if (_didAutoScrollHighlight) return;

    final targetId = _activeHighlightCommentId;
    if (targetId == null || targetId.isEmpty) return;

    final exists = comments.any((item) => item.comment.id == targetId);
    if (!exists) return;

    _didAutoScrollHighlight = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final key = _commentKeys[targetId];
      final targetContext = key?.currentContext;
      if (targetContext == null) return;

      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        alignment: 0.18,
      );

      Future.delayed(const Duration(milliseconds: 2200), () {
        if (!mounted) return;
        if (_activeHighlightCommentId != targetId) return;
        setState(() {
          _activeHighlightCommentId = null;
        });
        _pulseController.stop();
      });
    });
  }

  Future<void> _handleLike({
    required FeedProvider feedProvider,
    required PostEntity post,
    required bool isCurrentlyLiked,
  }) async {
    await feedProvider.toggleLike(
      postId: post.id,
      isCurrentlyLiked: isCurrentlyLiked,
    );

    if (!mounted || feedProvider.requiresAuth) return;

    final message = feedProvider.error;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      feedProvider.clearError();
    }
  }

  Future<void> _openAuthorProfile(PostEntity post) async {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Bài viết',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, _) {
          final post = feedProvider.postById(widget.args.postId);

          if (_isLoading && post == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (post == null) {
            return ErrorDisplay(
              message: 'Không thể tải bài viết.',
              onRetry: () async {
                setState(() => _isLoading = true);
                await _ensurePostLoaded();
                if (!mounted) return;
                setState(() => _isLoading = false);
              },
            );
          }

          final isLikedByMe =
              _currentUserId != null && post.likes.contains(_currentUserId);
          final isFollowingAuthor = feedProvider.isFollowingAuthor(
            post.authorId,
            currentUserId: _currentUserId,
          );
          final isOwnPost =
              _currentUserId != null && post.authorId == _currentUserId;
          final flattenedComments = _buildFlattenedComments(post.comments);
          _tryAutoHighlightInTab(flattenedComments);

          return ListView(
            padding: const EdgeInsets.only(top: 6, bottom: 16),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _DetailTabButton(
                        title: 'Bài viết',
                        isSelected: _selectedTab == 0,
                        onTap: () => setState(() => _selectedTab = 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DetailTabButton(
                        title: 'Bình luận',
                        isSelected: _selectedTab == 1,
                        onTap: () => setState(() => _selectedTab = 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (_selectedTab == 0)
                PostCard(
                  post: post,
                  isLikedByMe: isLikedByMe,
                  isFollowing: isFollowingAuthor,
                  onLike: () => _handleLike(
                    feedProvider: feedProvider,
                    post: post,
                    isCurrentlyLiked: isLikedByMe,
                  ),
                  onComment: () => _openCommentsSheet(post),
                  onViewComments: () => _openCommentsSheet(post),
                  onShare: () {},
                  onSave: () {},
                  onMore: () {},
                  onFollowTap: isOwnPost
                      ? null
                      : () => feedProvider.toggleFollowAuthor(
                            authorId: post.authorId,
                            currentUserId: _currentUserId,
                          ),
                  onAuthorTap: () => _openAuthorProfile(post),
                )
              else
                _InlineCommentsTab(
                  comments: flattenedComments,
                  highlightedCommentId: _activeHighlightCommentId,
                  pulseAnimation: _pulseController,
                  commentKeys: _commentKeys,
                  onOpenCommentSheet: () => _openCommentsSheet(post),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}

class _FlattenedComment {
  const _FlattenedComment({required this.comment, required this.depth});

  final PostCommentEntity comment;
  final int depth;
}

class _DetailTabButton extends StatelessWidget {
  const _DetailTabButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1689F6) : const Color(0xFFEDEDEF),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1F1F23),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _InlineCommentsTab extends StatelessWidget {
  const _InlineCommentsTab({
    required this.comments,
    required this.highlightedCommentId,
    required this.pulseAnimation,
    required this.commentKeys,
    required this.onOpenCommentSheet,
  });

  final List<_FlattenedComment> comments;
  final String? highlightedCommentId;
  final Animation<double> pulseAnimation;
  final Map<String, GlobalKey> commentKeys;
  final VoidCallback onOpenCommentSheet;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Text(
          'Chưa có bình luận nào cho bài viết này.',
          style: TextStyle(color: Colors.black54),
        ),
      );
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onOpenCommentSheet,
            child: const Text('Mở khung bình luận'),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          itemCount: comments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = comments[index];
            final comment = item.comment;
            final indent = (item.depth * 18.0).clamp(0.0, 72.0).toDouble();
            final author = _formatCommentAuthor(comment.authorId);
            final isHighlighted = highlightedCommentId == comment.id;
            final rowKey = commentKeys.putIfAbsent(comment.id, () => GlobalKey());

            return Padding(
              key: rowKey,
              padding: EdgeInsets.only(left: indent),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? const Color(0xFFEAF2FF)
                      : const Color(0xFFF7F7F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: const Color(0xFFE7E7E7),
                      child: Text(
                        author[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                author,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('HH:mm dd/MM').format(comment.createdAt),
                                style: const TextStyle(
                                  color: Colors.black45,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          AnimatedBuilder(
                            animation: pulseAnimation,
                            builder: (context, child) {
                              final textColor = isHighlighted
                                  ? Color.lerp(
                                      const Color(0xFF123A75),
                                      const Color(0xFF2D7DF8),
                                      pulseAnimation.value,
                                    )
                                  : Colors.black;

                              return Text(
                                comment.content,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.3,
                                  color: textColor,
                                  fontWeight: isHighlighted
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatCommentAuthor(String authorId) {
    final normalized = authorId
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
        .toLowerCase();
    if (normalized.isEmpty) {
      return 'user';
    }

    final prefix = normalized.length > 10
        ? normalized.substring(0, 10)
        : normalized;
    return '@$prefix';
  }
}
