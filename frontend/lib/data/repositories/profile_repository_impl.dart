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

  Map<String, dynamic> _extractUserPayload(dynamic rawData) {
    if (rawData is! Map) {
      throw const FormatException('Profile response is not a JSON object');
    }

    final response = Map<String, dynamic>.from(rawData);

    final directUser = response['user'];
    if (directUser is Map) {
      return Map<String, dynamic>.from(directUser);
    }

    final data = response['data'];
    if (data is Map) {
      final nestedUser = data['user'];
      if (nestedUser is Map) {
        return Map<String, dynamic>.from(nestedUser);
      }

      if (data.containsKey('_id')) {
        return Map<String, dynamic>.from(data);
      }
    }

    throw const FormatException('Missing user payload in profile response');
  }

  @override
  Future<ProfileEntity> getProfile(String userId) async {
    final normalizedUserId = userId.trim();
    final isMe = normalizedUserId.isEmpty || normalizedUserId == 'me';
    final endpoint = isMe
        ? ApiConstants.profile
        : '/users/$normalizedUserId/profile';

    final response = await apiService.get(endpoint);
    final userJson = _extractUserPayload(response.data);
    final data = ProfileModel.fromJson(userJson);

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
    final data = ProfileModel.fromJson(_extractUserPayload(response.data));
    return data.toEntity();
  }
}
