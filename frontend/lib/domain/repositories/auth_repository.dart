import '../../data/models/auth/login_response_model.dart';

abstract class AuthRepository {
  Future<LoginResponseModel> login(String username, String password);

  Future<void> logout();
}
