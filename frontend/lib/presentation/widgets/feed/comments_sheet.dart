import 'package:flutter/material.dart';
import 'package:frontend/domain/entities/post_comment_entity.dart';
import 'package:frontend/domain/entities/post_entity.dart';
import 'package:frontend/presentation/providers/feed_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentsSheet extends StatefulWidget {
  const CommentsSheet({
    super.key,
    required this.initialPost,
    required this.currentUserId,
    this.highlightedCommentId,
    this.initialReplyCommentId,
    this.autoFocusComposer = false,
  });

  final PostEntity initialPost;
  final String? currentUserId;
  final String? highlightedCommentId;
  final String? initialReplyCommentId;
  final bool autoFocusComposer;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final Map<String, GlobalKey> _commentKeys = <String, GlobalKey>{};
  PostCommentEntity? _replyTarget;
  String? _activeHighlightCommentId;
  bool _didAutoHighlight = false;
  bool _didInitializeReplyTarget = false;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _activeHighlightCommentId = widget.highlightedCommentId?.trim();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    );
    if ((_activeHighlightCommentId ?? '').isNotEmpty) {
      _pulseController.repeat(reverse: true);
    }
  }

  String _formatCommentAuthor(String authorId) {
    if (widget.currentUserId != null && authorId == widget.currentUserId) {
      return 'Ban';
    }

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

  Future<void> _submitComment({
    required FeedProvider feedProvider,
    required PostEntity post,
  }) async {
    final content = _controller.text.trim();
    if (content.isEmpty || feedProvider.isCommenting(post.id)) {
      return;
    }

    final success = await feedProvider.addComment(
      postId: post.id,
      content: content,
      parentCommentId: _replyTarget?.id,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _controller.clear();
      setState(() => _replyTarget = null);
      FocusScope.of(context).unfocus();
      return;
    }

    if (feedProvider.requiresAuth) {
      return;
    }

    final message = feedProvider.error;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      feedProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.45,
        initialChildSize: 0.72,
        maxChildSize: 0.95,
        builder: (context, sheetScrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Consumer<FeedProvider>(
              builder: (context, feedProvider, _) {
                final post =
                    feedProvider.postById(widget.initialPost.id) ??
                    widget.initialPost;
                final comments = _buildFlattenedComments(post.comments);
                final isBusy = feedProvider.isCommenting(post.id);
                final replyTarget = _replyTarget;
                _tryInitializeReplyTarget(comments);
                _tryAutoHighlight(comments);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Binh luan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${post.commentsCount}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: Colors.grey.shade200),
                    Expanded(
                      child: comments.isEmpty
                          ? const Center(
                              child: Text(
                                'Chua co binh luan nao. Hay la nguoi dau tien!',
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          : ListView.separated(
                              controller: sheetScrollController,
                              padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                              itemCount: comments.length,
                              separatorBuilder: (_, index) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = comments[index];
                                final comment = item.comment;
                                final colorScheme =
                                    Theme.of(context).colorScheme;
                                final highlightBg = Color.lerp(
                                  colorScheme.primaryContainer,
                                  colorScheme.surface,
                                  0.45,
                                );
                                final indent = (item.depth * 18.0)
                                    .clamp(0.0, 72.0)
                                    .toDouble();
                                final authorLabel = _formatCommentAuthor(
                                  comment.authorId,
                                );
                                final isHighlighted =
                                    _activeHighlightCommentId == comment.id;
                                final rowKey = _commentKeys.putIfAbsent(
                                  comment.id,
                                  () => GlobalKey(),
                                );

                                return Padding(
                                  key: rowKey,
                                  padding: EdgeInsets.only(left: indent),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 260),
                                    curve: Curves.easeOut,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isHighlighted
                                          ? highlightBg
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 14,
                                          backgroundColor: const Color(
                                            0xFFE7E7E7,
                                          ),
                                          child: Text(
                                            authorLabel[0].toUpperCase(),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    authorLabel,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    DateFormat(
                                                      'HH:mm dd/MM',
                                                    ).format(comment.createdAt),
                                                    style: const TextStyle(
                                                      color: Colors.black45,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              AnimatedBuilder(
                                                animation: _pulseController,
                                                builder: (context, child) {
                                                  final textColor =
                                                      isHighlighted
                                                      ? Color.lerp(
                                                          colorScheme
                                                              .onPrimaryContainer,
                                                          colorScheme.primary,
                                                          _pulseController
                                                              .value,
                                                        )
                                                      : colorScheme.onSurface;

                                                  return Text(
                                                    comment.content,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      height: 1.3,
                                                      color: textColor,
                                                      fontWeight:
                                                          isHighlighted
                                                          ? FontWeight.w600
                                                          : FontWeight.w400,
                                                    ),
                                                  );
                                                },
                                              ),
                                              const SizedBox(height: 4),
                                              InkWell(
                                                onTap: () {
                                                  setState(
                                                    () =>
                                                        _replyTarget = comment,
                                                  );
                                                  _inputFocusNode
                                                      .requestFocus();
                                                },
                                                child: Text(
                                                  _replyTarget?.id == comment.id
                                                      ? 'Dang tra loi...'
                                                      : 'Tra loi',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: Color(0xFF246BCE),
                                                  ),
                                                ),
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
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (replyTarget != null)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2F6FC),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Dang tra loi ${_formatCommentAuthor(replyTarget.authorId)}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF335A8F),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () =>
                                          setState(() => _replyTarget = null),
                                      child: const Padding(
                                        padding: EdgeInsets.all(2),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _controller,
                                    focusNode: _inputFocusNode,
                                    minLines: 1,
                                    maxLines: 4,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _submitComment(
                                      feedProvider: feedProvider,
                                      post: post,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: replyTarget == null
                                          ? 'Viet binh luan...'
                                          : 'Viet tra loi...',
                                      filled: true,
                                      fillColor: const Color(0xFFF4F4F4),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(22),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  onPressed: isBusy
                                      ? null
                                      : () => _submitComment(
                                          feedProvider: feedProvider,
                                          post: post,
                                        ),
                                  icon: isBusy
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.send_rounded),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _tryAutoHighlight(List<_FlattenedComment> comments) {
    if (_didAutoHighlight) return;
    final targetId = _activeHighlightCommentId;
    if (targetId == null || targetId.isEmpty) return;

    final exists = comments.any((item) => item.comment.id == targetId);
    if (!exists) return;

    _didAutoHighlight = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetKey = _commentKeys[targetId];
      final targetContext = targetKey?.currentContext;
      if (targetContext == null) return;

      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: 0.2,
      );

      Future.delayed(const Duration(milliseconds: 1800), () {
        if (!mounted) return;
        if (_activeHighlightCommentId != targetId) return;
        setState(() {
          _activeHighlightCommentId = null;
        });
        _pulseController.stop();
      });
    });
  }

  void _tryInitializeReplyTarget(List<_FlattenedComment> comments) {
    if (_didInitializeReplyTarget) return;

    final targetId = widget.initialReplyCommentId?.trim();
    if (targetId == null || targetId.isEmpty) {
      _didInitializeReplyTarget = true;
      return;
    }

    PostCommentEntity? matched;
    for (final item in comments) {
      if (item.comment.id == targetId) {
        matched = item.comment;
        break;
      }
    }

    _didInitializeReplyTarget = true;
    if (matched == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _replyTarget = matched;
      });

      if (widget.autoFocusComposer) {
        _inputFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _inputFocusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}

class _FlattenedComment {
  const _FlattenedComment({required this.comment, required this.depth});

  final PostCommentEntity comment;
  final int depth;
}
