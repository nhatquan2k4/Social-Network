import 'package:dio/dio.dart';
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
      if (e is DioException) {
        errorMessage = e.response?.data['message'] ?? 'Đã có lỗi xảy ra';
      } else {
        errorMessage = e.toString();
      }
      notifyListeners();

      return false;
    }
  }
}
