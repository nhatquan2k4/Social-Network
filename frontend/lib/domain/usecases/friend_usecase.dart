import '../entities/friend_entity.dart';
import '../repositories/friend_repository.dart';

class GetFriendsUseCase {
  final FriendRepository repository;

  GetFriendsUseCase(this.repository);

  Future<List<FriendEntity>> call() {
    return repository.getFriends();
  }
}
