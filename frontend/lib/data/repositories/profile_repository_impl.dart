import '../services/api_service.dart';
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
}
