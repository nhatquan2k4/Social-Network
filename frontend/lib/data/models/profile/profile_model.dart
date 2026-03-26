import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  @JsonKey(name: '_id')
  final String id;
  final String username;
  final String email;
  final String displayName;

  ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
