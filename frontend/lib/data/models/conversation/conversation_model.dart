import 'package:json_annotation/json_annotation.dart';
import '../../../domain/entities/conversation_entity.dart';

part 'conversation_model.g.dart';

@JsonSerializable()
class ConversationModel {
  @JsonKey(name: '_id')
  final String id;
  final String type;
  @JsonKey(name: 'participants')
  final List<ParticipantModel> participants;
  @JsonKey(name: 'group')
  final GroupModel? group;
  final DateTime createdAt;

  ConversationModel({
    required this.id,
    required this.type,
    required this.participants,
    this.group,
    required this.createdAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) =>
      _$ConversationModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConversationModelToJson(this);

  // Convert to Entity
  ConversationEntity toEntity() {
    return ConversationEntity(
      id: id,
      type: type,
      participantIds: participants.map((p) => p.userId).toList(),
      groupName: group?.name,
      createdAt: createdAt,
    );
  }
}

@JsonSerializable()
class ParticipantModel {
  @JsonKey(name: '_id')
  final String userId;
  final String? displayName;
  final String? avatarUrl;
  final DateTime joinedAt;

  ParticipantModel({
    required this.userId,
    this.displayName,
    this.avatarUrl,
    required this.joinedAt,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$ParticipantModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParticipantModelToJson(this);
}

@JsonSerializable()
class GroupModel {
  final String? name;
  final String? createdBy;

  GroupModel({this.name, this.createdBy});

  factory GroupModel.fromJson(Map<String, dynamic> json) =>
      _$GroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$GroupModelToJson(this);
}
