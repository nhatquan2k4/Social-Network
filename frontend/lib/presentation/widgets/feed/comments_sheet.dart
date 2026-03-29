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
  });

  final PostEntity initialPost;
  final String? currentUserId;

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  PostCommentEntity? _replyTarget;

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
  void dispose() {
    _inputFocusNode.dispose();
    _controller.dispose();
    super.dispose();
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
                                final indent = (item.depth * 18.0)
                                    .clamp(0.0, 72.0)
                                    .toDouble();
                                final authorLabel = _formatCommentAuthor(
                                  comment.authorId,
                                );

                                return Padding(
                                  padding: EdgeInsets.only(left: indent),
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
                                            Text(
                                              comment.content,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                height: 1.3,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            InkWell(
                                              onTap: () {
                                                setState(
                                                  () => _replyTarget = comment,
                                                );
                                                _inputFocusNode.requestFocus();
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
}

class _FlattenedComment {
  const _FlattenedComment({required this.comment, required this.depth});

  final PostCommentEntity comment;
  final int depth;
}
