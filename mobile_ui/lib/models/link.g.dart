// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Link _$LinkFromJson(Map<String, dynamic> json) => _Link(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  url: json['url'] as String,
  createdAt: _dateTimeFromJson(json['created_at'] as String),
  updatedAt: _dateTimeFromJson(json['updated_at'] as String),
);

Map<String, dynamic> _$LinkToJson(_Link instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'url': instance.url,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};
