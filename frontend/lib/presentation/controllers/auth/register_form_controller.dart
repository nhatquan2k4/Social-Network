import 'package:frontend/presentation/providers/auth_provider.dart';

enum RegisterValidationError {
  missingFullName,
  missingUsername,
  invalidEmail,
  invalidPassword,
}

class RegisterInput {
  const RegisterInput({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String confirmPassword;
}

class RegisterSubmitResult {
  const RegisterSubmitResult({
    required this.isSuccess,
    this.validationError,
    this.errorMessage,
  });

  final bool isSuccess;
  final RegisterValidationError? validationError;
  final String? errorMessage;
}

class RegisterFormController {
  RegisterValidationError? validate(RegisterInput input) {
    if (input.firstName.isEmpty || input.lastName.isEmpty) {
      return RegisterValidationError.missingFullName;
    }
    if (input.username.isEmpty) {
      return RegisterValidationError.missingUsername;
    }
    if (input.email.isEmpty || !input.email.contains('@')) {
      return RegisterValidationError.invalidEmail;
    }
    if (input.password.length < 6 || input.password != input.confirmPassword) {
      return RegisterValidationError.invalidPassword;
    }

    return null;
  }

  Future<RegisterSubmitResult> submit({
    required AuthProvider authProvider,
    required RegisterInput input,
  }) async {
    final validationError = validate(input);
    if (validationError != null) {
      return RegisterSubmitResult(
        isSuccess: false,
        validationError: validationError,
      );
    }

    final isSuccess = await authProvider.register(
      input.username,
      input.password,
      input.email,
      input.firstName,
      input.lastName,
    );

    return RegisterSubmitResult(
      isSuccess: isSuccess,
      errorMessage: authProvider.errorMessage,
    );
  }
}
