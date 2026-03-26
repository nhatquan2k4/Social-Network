import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;

  ProfileProvider(this.getProfileUseCase);

  ProfileEntity? profile;
  bool isLoading = false;
  String? error;

  Future<void> fetchProfile(String userId) async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      profile = await getProfileUseCase(userId);

      error = null;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        error =
            e.response!.data['message'] ?? 'Không tải được thông tin cá nhân';
      } else {
        error = 'Không thể kết nối đến máy chủ';
      }
    } catch (e) {
      error = "Lỗi không xác định: ${e.toString()}";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
