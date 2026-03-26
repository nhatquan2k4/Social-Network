import 'package:json_annotation/json_annotation.dart';
import 'friend_model.dart';

part 'list_friends_model.g.dart';

@JsonSerializable()
class ListFriendsModel {
  final List<FriendModel> friends;

  ListFriendsModel({required this.friends});

  factory ListFriendsModel.fromJson(Map<String, dynamic> json) =>
      _$ListFriendsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ListFriendsModelToJson(this);
}
