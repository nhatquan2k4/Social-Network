import '../models/friends/friend_model.dart';
import '../../domain/entities/friend_entity.dart';

extension FriendMapper on FriendModel {
  FriendEntity toEntity() {
    return FriendEntity(id: id, username: username, displayName: displayName);
  }
}
