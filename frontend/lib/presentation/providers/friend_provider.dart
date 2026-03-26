import 'package:flutter/material.dart';
import '../../domain/entities/friend_entity.dart';
import '../../domain/usecases/friend_usecase.dart';

class MessagesProvider extends ChangeNotifier {
  final GetFriendsUseCase getFriendsUseCase;

  MessagesProvider(this.getFriendsUseCase);

  List<FriendEntity> friends = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchFriends() async {
    try {
      isLoading = true;
      notifyListeners();

      friends = await getFriendsUseCase();

      error = null;
    } catch (e) {
      error = "Không tải được danh sách chat";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
