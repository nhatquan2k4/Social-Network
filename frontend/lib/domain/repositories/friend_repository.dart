import '../entities/friend_entity.dart';

abstract class FriendRepository {
  Future<List<FriendEntity>> getFriends();
}
