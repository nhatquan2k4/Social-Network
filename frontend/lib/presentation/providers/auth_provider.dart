import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../data/models/auth/login_response_model.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase? registerUseCase;

  AuthProvider(this.loginUseCase, [this.registerUseCase]);

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

  Future<bool> register(
    String username,
    String password,
    String email,
    String firstName,
    String lastName,
  ) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      await registerUseCase!.register(
        username,
        password,
        email,
        firstName,
        lastName,
      );

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
