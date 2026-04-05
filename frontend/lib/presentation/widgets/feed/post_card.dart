import 'package:flutter/material.dart';
import 'package:frontend/core/l10n/l10n.dart';
import 'package:frontend/core/utils/url_normalizer.dart';
import 'package:frontend/presentation/widgets/common/follow_status_chip.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/post_entity.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.authorName,
    this.authorUsername,
    this.authorAvatarUrl,
    this.locationLabel,
    this.isVerified = false,
    this.isLikedByMe = false,
    this.likeCountOverride,
    this.onLike,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onMore,
    this.onViewComments,
    this.followingLabel,
    this.followLabel,
    this.isFollowing = true,
    this.onFollowTap,
    this.onAuthorTap,
  });

  final PostEntity post;
  final String? authorName;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final String? locationLabel;
  final bool isVerified;
  final bool isLikedByMe;
  final int? likeCountOverride;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onMore;
  final VoidCallback? onViewComments;
  final String? followingLabel;
  final String? followLabel;
  final bool isFollowing;
  final VoidCallback? onFollowTap;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final likesCount = likeCountOverride ?? post.likes.length;
    final commentCount = post.commentsCount;
    final imageUrls = _resolveImageUrls();

    final displayName = (authorName != null && authorName!.trim().isNotEmpty)
        ? authorName!.trim()
        : ((post.authorDisplayName != null &&
                  post.authorDisplayName!.trim().isNotEmpty)
              ? post.authorDisplayName!.trim()
              : _formatFallbackName(post.authorId));

    final username =
        (authorUsername != null && authorUsername!.trim().isNotEmpty)
        ? authorUsername!.trim()
        : ((post.authorUsername != null &&
                  post.authorUsername!.trim().isNotEmpty)
              ? post.authorUsername!.trim()
              : _formatFallbackUsername(post.authorId));

    final avatarUrl =
        (authorAvatarUrl != null && authorAvatarUrl!.trim().isNotEmpty)
        ? authorAvatarUrl!.trim()
        : post.authorAvatarUrl;

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 8),
            child: Row(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onAuthorTap,
                  child: _UserAvatar(name: displayName, avatarUrl: avatarUrl),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onAuthorTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              username,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.black,
                                fontSize: 14,
                                letterSpacing: -0.1,
                              ),
                            ),
                            if (isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: Color(0xFF3797EF),
                              ),
                            ],
                          ],
                        ),
                        if (locationLabel != null && locationLabel!.isNotEmpty)
                          Text(
                            locationLabel!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6A6A70),
                              fontSize: 12,
                            ),
                          )
                        else
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6A6A70),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                FollowStatusChip(
                  isFollowing: isFollowing,
                  followingText: followingLabel ?? context.l10n.followingStatus,
                  followText: followLabel ?? context.l10n.followAction,
                  onTap: onFollowTap,
                ),
                const SizedBox(width: 4),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 18,
                  icon: const Icon(Icons.more_horiz, color: Colors.black),
                  onPressed: onMore,
                ),
              ],
            ),
          ),
          _PostMedia(imageUrls: imageUrls),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 0),
            child: Row(
              children: [
                _ActionIcon(
                  icon: isLikedByMe ? Icons.favorite : Icons.favorite_border,
                  color: isLikedByMe ? Colors.red : Colors.black,
                  onTap: onLike,
                ),
                const SizedBox(width: 2),
                Text(
                  _formatCount(likesCount),
                  style: const TextStyle(
                    fontSize: 22 / 2,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                _ActionIcon(icon: Icons.chat_bubble_outline, onTap: onComment),
                const SizedBox(width: 2),
                Text(
                  _formatCount(commentCount),
                  style: const TextStyle(
                    fontSize: 22 / 2,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                _ActionIcon(icon: Icons.send_outlined, onTap: onShare),
                const Spacer(),
                _ActionIcon(icon: Icons.bookmark_border, onTap: onSave),
              ],
            ),
          ),
          if (commentCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: InkWell(
                onTap: onViewComments ?? onComment,
                child: Text(
                  context.l10n.viewAllComments(_formatCount(commentCount)),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6E6E74),
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          if (post.content != null && post.content!.trim().isNotEmpty)
            Padding(
              padding: EdgeInsets.fromLTRB(14, commentCount > 0 ? 5 : 8, 14, 0),
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    height: 1.3,
                  ),
                  children: [
                    TextSpan(
                      text: '$username ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: post.content!.trim()),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 8),
            child: Row(
              children: [
                Text(
                  DateFormat('MMMM d').format(post.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFA2A2A8),
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  List<String> _resolveImageUrls() {
    if (post.media.isEmpty) return const [];

    final results = <String>[];

    for (final item in post.media) {
      final mediaUrl = item.mediaUrl?.trim();
      if (mediaUrl != null && mediaUrl.isNotEmpty) {
        results.add(mediaUrl.normalizeClientUrl());
        continue;
      }

      final key = item.objectKey.trim();
      if (key.isEmpty) {
        continue;
      }

      if (key.startsWith('http://') || key.startsWith('https://')) {
        results.add(key.normalizeClientUrl());
      }
    }

    return results;
  }

  String _formatFallbackName(String authorId) {
    if (authorId.isEmpty) return 'User';
    if (authorId.length <= 10) return authorId;
    return 'User ${authorId.substring(0, 6)}';
  }

  String _formatFallbackUsername(String authorId) {
    if (authorId.isEmpty) return 'user';
    final raw = authorId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    if (raw.isEmpty) return 'user';
    return raw.length > 12 ? raw.substring(0, 12) : raw;
  }

  String _formatCount(int value) {
    if (value >= 1000000) {
      final m = value / 1000000;
      return '${m.toStringAsFixed(m >= 10 ? 0 : 1)}M';
    }
    if (value >= 1000) {
      final k = value / 1000;
      return '${k.toStringAsFixed(k >= 10 ? 0 : 1)}K';
    }
    return value.toString();
  }
}

class _PostMedia extends StatefulWidget {
  const _PostMedia({required this.imageUrls});

  final List<String> imageUrls;

  @override
  State<_PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<_PostMedia> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void didUpdateWidget(covariant _PostMedia oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrls.length != oldWidget.imageUrls.length &&
        _currentIndex >= widget.imageUrls.length) {
      setState(() {
        _currentIndex = 0;
      });
      _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: const Color(0xFFF1F1F1),
          child: const Center(
            child: Icon(Icons.image_outlined, size: 48, color: Colors.black26),
          ),
        ),
      );
    }

    if (widget.imageUrls.length == 1) {
      return AspectRatio(
        aspectRatio: 1,
        child: _buildNetworkImage(widget.imageUrls.first),
      );
    }

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildNetworkImage(widget.imageUrls[index]);
            },
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentIndex + 1}/${widget.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                final isActive = index == _currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 8 : 6,
                  height: isActive ? 8 : 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFF1F1F1),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFF1F1F1),
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: Colors.black26,
            ),
          ),
        );
      },
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({required this.icon, this.color, this.onTap});

  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      radius: 20,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 24, color: color ?? Colors.black),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    final hasNetwork = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    if (!hasNetwork) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: const Color(0xFFDADADA),
        child: Text(
          initial,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontSize: 12,
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFDADADA),
      backgroundImage: NetworkImage(avatarUrl!),
      onBackgroundImageError: (exception, stackTrace) {},
      child: null,
    );
  }
}
