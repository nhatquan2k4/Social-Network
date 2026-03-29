// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostCommentModel _$PostCommentModelFromJson(Map<String, dynamic> json) =>
    PostCommentModel(
      id: json['_id'] as String,
      parentCommentId: json['parentCommentId'] as String?,
      authorId: PostCommentModel._authorIdFromJson(json['authorId']),
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PostCommentModelToJson(PostCommentModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'parentCommentId': instance.parentCommentId,
      'authorId': PostCommentModel._authorIdToJson(instance.authorId),
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
