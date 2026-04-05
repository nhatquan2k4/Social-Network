import 'package:frontend/presentation/providers/auth_provider.dart';

class LoginSubmitResult {
  const LoginSubmitResult({required this.isSuccess, this.errorMessage});

  final bool isSuccess;
  final String? errorMessage;
}

class LoginFormController {
  Future<LoginSubmitResult> submit({
    required AuthProvider authProvider,
    required String username,
    required String password,
  }) async {
    final isSuccess = await authProvider.login(username, password);
    return LoginSubmitResult(
      isSuccess: isSuccess,
      errorMessage: authProvider.errorMessage,
    );
  }
}
