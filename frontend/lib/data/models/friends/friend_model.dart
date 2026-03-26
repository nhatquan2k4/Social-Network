import 'package:json_annotation/json_annotation.dart';

part 'friend_model.g.dart';

@JsonSerializable()
class FriendModel {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String displayName;

  FriendModel({
    required this.id,
    required this.username,
    required this.displayName,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) =>
      _$FriendModelFromJson(json);

  Map<String, dynamic> toJson() => _$FriendModelToJson(this);
}
