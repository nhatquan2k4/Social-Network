import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final likesCount = likeCountOverride ?? post.likes.length;
    final commentCount = post.commentsCount;

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

    final imageUrl = _resolveImageUrl();

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 10),
            child: Row(
              children: [
                _UserAvatar(name: displayName, avatarUrl: avatarUrl),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            username,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              letterSpacing: -0.2,
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
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        )
                      else
                        Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.black54,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  splashRadius: 18,
                  icon: const Icon(Icons.more_horiz, color: Colors.black),
                  onPressed: onMore,
                ),
              ],
            ),
          ),
          _PostMedia(imageUrl: imageUrl),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                _ActionIcon(icon: Icons.chat_bubble_outline, onTap: onComment),
                const SizedBox(width: 2),
                Text(
                  _formatCount(commentCount),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
                  'Xem tat ca ${_formatCount(commentCount)} binh luan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
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
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: Row(
              children: [
                Text(
                  DateFormat('MMMM d').format(post.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black45,
                    fontSize: 11,
                    letterSpacing: 0.2,
                  ),
                ),
                const Spacer(),
                if (likesCount > 0)
                  Text(
                    '${_formatCount(likesCount)} luot thich',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.black45,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String? _resolveImageUrl() {
    if (post.media.isEmpty) return null;

    final primary = post.media.first;
    final mediaUrl = primary.mediaUrl?.trim();
    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      return _normalizeMediaUrl(mediaUrl);
    }

    final key = primary.objectKey.trim();
    if (key.isEmpty) {
      return null;
    }

    if (key.startsWith('http://') || key.startsWith('https://')) {
      return _normalizeMediaUrl(key);
    }

    return null;
  }

  String _normalizeMediaUrl(String rawUrl) {
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return rawUrl;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      if (uri.host == 'localhost' || uri.host == '127.0.0.1') {
        return uri.replace(host: '10.0.2.2').toString();
      }
    }

    return rawUrl;
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

class _PostMedia extends StatelessWidget {
  const _PostMedia({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: imageUrl == null
          ? Container(
              color: const Color(0xFFF1F1F1),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: Colors.black26,
                ),
              ),
            )
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: const Color(0xFFF1F1F1),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
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
            ),
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
