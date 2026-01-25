// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationModel _$ConversationModelFromJson(Map<String, dynamic> json) =>
    ConversationModel(
      id: json['_id'] as String,
      type: json['type'] as String,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => ParticipantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      group: json['group'] == null
          ? null
          : GroupModel.fromJson(json['group'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ConversationModelToJson(ConversationModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'type': instance.type,
      'participants': instance.participants,
      'group': instance.group,
      'createdAt': instance.createdAt.toIso8601String(),
    };

ParticipantModel _$ParticipantModelFromJson(Map<String, dynamic> json) =>
    ParticipantModel(
      userId: json['_id'] as String,
      displayName: json['displayName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );

Map<String, dynamic> _$ParticipantModelToJson(ParticipantModel instance) =>
    <String, dynamic>{
      '_id': instance.userId,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'joinedAt': instance.joinedAt.toIso8601String(),
    };

GroupModel _$GroupModelFromJson(Map<String, dynamic> json) => GroupModel(
  name: json['name'] as String?,
  createdBy: json['createdBy'] as String?,
);

Map<String, dynamic> _$GroupModelToJson(GroupModel instance) =>
    <String, dynamic>{'name': instance.name, 'createdBy': instance.createdBy};
