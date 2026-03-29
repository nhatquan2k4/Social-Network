// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostModel _$PostModelFromJson(Map<String, dynamic> json) => PostModel(
  id: json['_id'] as String,
  authorId: PostModel._authorIdFromJson(json['authorId']),
  content: json['content'] as String?,
  media:
      (json['media'] as List<dynamic>?)
          ?.map((e) => PostMediaModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  likes:
      (json['likes'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  comments:
      (json['comments'] as List<dynamic>?)
          ?.map((e) => PostCommentModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
  '_id': instance.id,
  'authorId': PostModel._authorIdToJson(instance.authorId),
  'content': instance.content,
  'media': instance.media,
  'likes': instance.likes,
  'comments': instance.comments,
  'commentsCount': instance.commentsCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};
