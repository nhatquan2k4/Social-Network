import '../repositories/auth_repository.dart';
import '../../data/models/auth/login_response_model.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<LoginResponseModel> execute(String username, String password) {
    return repository.login(username, password);
  }
}
