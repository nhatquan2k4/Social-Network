import '../../domain/entities/profile_entity.dart';
import '../models/profile/profile_model.dart';

extension ProfileMapper on ProfileModel {
  ProfileEntity toEntity() {
    return ProfileEntity(
      id: id,
      username: username,
      email: email,
      displayName: displayName,
    );
  }
}
