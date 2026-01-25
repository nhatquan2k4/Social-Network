// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_friends_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListFriendsModel _$ListFriendsModelFromJson(Map<String, dynamic> json) =>
    ListFriendsModel(
      friends: (json['friends'] as List<dynamic>)
          .map((e) => FriendModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ListFriendsModelToJson(ListFriendsModel instance) =>
    <String, dynamic>{'friends': instance.friends};
