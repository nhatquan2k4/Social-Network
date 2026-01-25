import '../../domain/repositories/auth_repository.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../models/auth/login_response_model.dart';
import '../../core/constants/api_constants.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;
  final LocalStorageService localStorage;

  AuthRepositoryImpl(this.apiService, this.localStorage);

  @override
  Future<LoginResponseModel> login(String username, String password) async {
    final response = await apiService.post(ApiConstants.login, {
      "username": username,
      "password": password,
    });

    final loginResponse = LoginResponseModel.fromJson(response.data);

    // SAVE TOKEN
    await localStorage.saveToken(loginResponse.accessToken);

    return loginResponse;
  }

  @override
  Future<void> logout() async {
    // Clear token from local storage
    await localStorage.clearToken();
  }
}
