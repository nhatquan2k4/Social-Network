import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/post_comment_entity.dart';

part 'post_comment_model.g.dart';

@JsonSerializable()
class PostCommentModel {
  @JsonKey(name: '_id')
  final String id;
  final String? parentCommentId;
  @JsonKey(fromJson: _authorIdFromJson, toJson: _authorIdToJson)
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostCommentModel({
    required this.id,
    this.parentCommentId,
    required this.authorId,
    required this.content,
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

  factory PostCommentModel.fromJson(Map<String, dynamic> json) =>
      _$PostCommentModelFromJson(json);
  Map<String, dynamic> toJson() => _$PostCommentModelToJson(this);

  // Convert to Entity
  PostCommentEntity toEntity() {
    return PostCommentEntity(
      id: id,
      parentCommentId: parentCommentId,
      authorId: authorId,
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
