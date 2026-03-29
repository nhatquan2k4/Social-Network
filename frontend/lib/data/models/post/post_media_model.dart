import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/post_media_entity.dart';

part 'post_media_model.g.dart';

@JsonSerializable()
class PostMediaModel {
  final String bucket;
  final String objectKey;
  final String? mediaUrl;
  final String mimeType;
  final int size;

  PostMediaModel({
    required this.bucket,
    required this.objectKey,
    this.mediaUrl,
    required this.mimeType,
    required this.size,
  });

  factory PostMediaModel.fromJson(Map<String, dynamic> json) =>
      _$PostMediaModelFromJson(json);
  Map<String, dynamic> toJson() => _$PostMediaModelToJson(this);

  // Convert to Entity
  PostMediaEntity toEntity() {
    return PostMediaEntity(
      bucket: bucket,
      objectKey: objectKey,
      mediaUrl: mediaUrl,
      mimeType: mimeType,
      size: size,
    );
  }
}
