// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_media_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostMediaModel _$PostMediaModelFromJson(Map<String, dynamic> json) =>
    PostMediaModel(
      bucket: json['bucket'] as String,
      objectKey: json['objectKey'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      mimeType: json['mimeType'] as String,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$PostMediaModelToJson(PostMediaModel instance) =>
    <String, dynamic>{
      'bucket': instance.bucket,
      'objectKey': instance.objectKey,
      'mediaUrl': instance.mediaUrl,
      'mimeType': instance.mimeType,
      'size': instance.size,
    };
