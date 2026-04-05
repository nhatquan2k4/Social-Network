import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase getProfileUseCase;
  final UpdateMyAvatarUseCase updateMyAvatarUseCase;

  ProfileProvider(this.getProfileUseCase, this.updateMyAvatarUseCase);

  ProfileEntity? profile;
  bool isLoading = false;
  bool isSaving = false;
  String? error;
  Future<void>? _ensureMyProfileFuture;

  Future<void> ensureMyProfileLoaded() {
    if (profile != null || isLoading) {
      return Future.value();
    }

    if (_ensureMyProfileFuture != null) {
      return _ensureMyProfileFuture!;
    }

    _ensureMyProfileFuture = fetchProfile('me').whenComplete(() {
      _ensureMyProfileFuture = null;
    });

    return _ensureMyProfileFuture!;
  }

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

  Future<bool> updateAvatar(String filePath) async {
    try {
      isSaving = true;
      error = null;
      notifyListeners();

      profile = await updateMyAvatarUseCase(filePath);
      return true;
    } on DioException catch (e) {
      if (e.response?.data != null && e.response!.data is Map) {
        error =
            e.response!.data['message'] ??
            'Khong cap nhat duoc avatar. Vui long thu lai.';
      } else {
        error = 'Khong the ket noi den may chu';
      }
      return false;
    } catch (_) {
      error = 'Da xay ra loi khi cap nhat avatar';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  void applyLocalProfileEdits({
    required String displayName,
    required String username,
    required String email,
    String? bio,
    String? phone,
  }) {
    final current = profile;
    if (current == null) return;

    profile = current.copyWith(
      displayName: displayName,
      username: username,
      email: email,
      bio: bio,
      phone: phone,
    );
    notifyListeners();
  }
}
