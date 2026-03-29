import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/post_entity.dart';

import 'post_comment_model.dart';
import 'post_media_model.dart';

part 'post_model.g.dart';

@JsonSerializable()
class PostModel {
  @JsonKey(name: '_id')
  final String id;
  @JsonKey(fromJson: _authorIdFromJson, toJson: _authorIdToJson)
  final String authorId;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? authorUsername;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? authorDisplayName;
  @JsonKey(includeFromJson: false, includeToJson: false)
  final String? authorAvatarUrl;
  final String? content;
  final List<PostMediaModel> media;
  final List<String> likes;
  final List<PostCommentModel> comments;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.authorId,
    this.authorUsername,
    this.authorDisplayName,
    this.authorAvatarUrl,
    this.content,
    this.media = const [],
    this.likes = const [],
    this.comments = const [],
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  static String _authorIdFromJson(dynamic value) {
    if (value is String) {
      return value;
    }
    if (value is Map<String, dynamic>) {
      final raw = value['_id'] ?? value['id'];
      if (raw is String) {
        return raw;
      }
      if (raw != null) {
        return raw.toString();
      }
    }
    throw FormatException('Invalid authorId value: $value');
  }

  static dynamic _authorIdToJson(String value) => value;

  static Map<String, dynamic>? _authorMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }

  static String _safeString(dynamic value, {String fallback = ''}) {
    if (value is String) {
      return value;
    }
    if (value == null) {
      return fallback;
    }
    return value.toString();
  }

  static String _safeIsoTime(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (value is DateTime) {
      return value.toIso8601String();
    }
    return DateTime.now().toIso8601String();
  }

  static String _extractPostId(Map<String, dynamic> json) {
    final raw = json['_id'] ?? json['id'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    if (raw != null) {
      final converted = raw.toString().trim();
      if (converted.isNotEmpty) {
        return converted;
      }
    }
    throw const FormatException('Missing post id in response payload');
  }

  static String? _authorUsernameFromRaw(dynamic value) {
    final map = _authorMap(value);
    final raw = map?['username'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  static String? _authorDisplayNameFromRaw(dynamic value) {
    final map = _authorMap(value);
    final raw = map?['displayName'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  static String? _authorAvatarUrlFromRaw(dynamic value) {
    final map = _authorMap(value);
    final raw = map?['avatarUrl'];
    if (raw is String && raw.trim().isNotEmpty) {
      return raw.trim();
    }
    return null;
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    final rawAuthor = normalized['authorId'] ?? normalized['author'];

    normalized['_id'] = _extractPostId(normalized);
    normalized['authorId'] = normalized['authorId'] ?? rawAuthor ?? '';
    normalized['createdAt'] = _safeIsoTime(normalized['createdAt']);
    normalized['updatedAt'] = _safeIsoTime(normalized['updatedAt']);

    final mediaList = normalized['media'];
    if (mediaList is List) {
      normalized['media'] = mediaList
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(
            (item) => {
              'bucket': _safeString(item['bucket']),
              'objectKey': _safeString(item['objectKey']),
              'mediaUrl': item['mediaUrl']?.toString(),
              'mimeType': _safeString(item['mimeType']),
              'size': (item['size'] is num)
                  ? (item['size'] as num).toInt()
                  : int.tryParse(item['size']?.toString() ?? '0') ?? 0,
            },
          )
          .toList(growable: false);
    } else {
      normalized['media'] = const [];
    }

    final likesList = normalized['likes'];
    if (likesList is List) {
      normalized['likes'] = likesList
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList(growable: false);
    } else {
      normalized['likes'] = const [];
    }

    final commentsList = normalized['comments'];
    if (commentsList is List) {
      normalized['comments'] = commentsList
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(
            (item) => {
              '_id': _safeString(
                item['_id'],
                fallback: DateTime.now().millisecondsSinceEpoch.toString(),
              ),
              'parentCommentId': item['parentCommentId']?.toString(),
              'authorId': item['authorId'] ?? '',
              'content': _safeString(item['content']),
              'createdAt': _safeIsoTime(item['createdAt']),
              'updatedAt': _safeIsoTime(item['updatedAt']),
            },
          )
          .toList(growable: false);
    } else {
      normalized['comments'] = const [];
    }

    normalized['commentsCount'] = (normalized['commentsCount'] is num)
        ? (normalized['commentsCount'] as num).toInt()
        : int.tryParse(normalized['commentsCount']?.toString() ?? '0') ?? 0;

    final model = _$PostModelFromJson(normalized);

    return PostModel(
      id: model.id,
      authorId: model.authorId,
      authorUsername: _authorUsernameFromRaw(rawAuthor),
      authorDisplayName: _authorDisplayNameFromRaw(rawAuthor),
      authorAvatarUrl: _authorAvatarUrlFromRaw(rawAuthor),
      content: model.content,
      media: model.media,
      likes: model.likes,
      comments: model.comments,
      commentsCount: model.commentsCount,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => _$PostModelToJson(this);

  // Convert to Entity
  PostEntity toEntity() {
    return PostEntity(
      id: id,
      authorId: authorId,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      authorAvatarUrl: authorAvatarUrl,
      content: content,
      media: media.map((m) => m.toEntity()).toList(),
      likes: likes,
      comments: comments.map((c) => c.toEntity()).toList(),
      commentsCount: commentsCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
