import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<ProfileEntity> call(String userId) {
    return repository.getProfile(userId);
  }
}
