import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../data/models/auth/login_response_model.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;

  AuthProvider(this.loginUseCase);

  bool isLoading = false;
  String? errorMessage;
  LoginResponseModel? loginResult;

  Future<bool> login(String username, String password) async {
    try {
      isLoading = true;
      notifyListeners();

      loginResult = await loginUseCase.execute(username, password);

      isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      isLoading = false;
      errorMessage = "Sai tài khoản hoặc mật khẩu";
      notifyListeners();

      return false;
    }
  }
}
