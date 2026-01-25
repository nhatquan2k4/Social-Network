import 'package:frontend/core/constants/api_constants.dart';
import '../../data/mappers/friend_mapper.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/repositories/friend_repository.dart';
import '../services/api_service.dart';
import '../models/friends/list_friends_model.dart';

class FriendRepositoryImpl implements FriendRepository {
  final ApiService apiService;

  FriendRepositoryImpl(this.apiService);

  @override
  Future<List<FriendEntity>> getFriends() async {
    final response = await apiService.get(ApiConstants.friends);

    final data = ListFriendsModel.fromJson(response.data);

    return data.friends.map((e) => e.toEntity()).toList();
  }
}
