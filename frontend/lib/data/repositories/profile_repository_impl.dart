import '../services/api_service.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/profile_entity.dart';
import '../models/profile/profile_model.dart';
import '../../core/constants/api_constants.dart';
import '../mappers/profile_mapper.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService apiService;

  ProfileRepositoryImpl(this.apiService);

  @override
  Future<ProfileEntity> getProfile(String userId) async {
    final response = await apiService.get(ApiConstants.profile);

    final data = ProfileModel.fromJson(response.data['user']);

    return data.toEntity();
  }

  @override
  Future<ProfileEntity> updateMyAvatar(String filePath) async {
    final fileName = filePath.split(RegExp(r'[/\\]')).last;
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(filePath, filename: fileName),
    });

    final response = await apiService.patchFormData(
      ApiConstants.profileAvatar,
      formData,
    );
    final data = ProfileModel.fromJson(response.data['user']);
    return data.toEntity();
  }
}
