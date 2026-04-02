import '../../data/models/auth/login_response_model.dart';
import '../../data/models/auth/register_model.dart';

abstract class AuthRepository {
  Future<LoginResponseModel> login(String username, String password);

  Future<RegisterModel> register(
    String username,
    String password,
    String email,
    String firstName,
    String lastName,
  );

  Future<void> logout();
}
