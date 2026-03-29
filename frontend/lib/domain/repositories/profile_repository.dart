import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile(String userId);
  Future<ProfileEntity> updateMyAvatar(String filePath);
}
