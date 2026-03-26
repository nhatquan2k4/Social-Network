// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendModel _$FriendModelFromJson(Map<String, dynamic> json) => FriendModel(
  id: json['_id'] as String,
  username: json['username'] as String,
  displayName: json['displayName'] as String,
);

Map<String, dynamic> _$FriendModelToJson(FriendModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'username': instance.username,
      'displayName': instance.displayName,
    };
