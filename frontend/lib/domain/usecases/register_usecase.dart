import '../repositories/auth_repository.dart';
import '../../data/models/auth/register_model.dart';

class RegisterUseCase {
  final AuthRepository authRepository;

  RegisterUseCase(this.authRepository);

  Future<RegisterModel> register(
    String username,
    String password,
    String email,
    String firstName,
    String lastName,
  ) async {
    return await authRepository.register(
      username,
      password,
      email,
      firstName,
      lastName,
    );
  }
}
