// ignore_for_file: invalid_annotation_target

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'link.freezed.dart';
part 'link.g.dart';

@freezed
abstract class Link with _$Link {
  const factory Link({
    required int id,
    required String title,
    required String url,
    @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
    required DateTime createdAt,
    @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)
    required DateTime updatedAt,
    @JsonKey(name: 'tag_ids') @Default([]) List<int> tagIds,
  }) = _Link;

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);
}

DateTime _dateTimeFromJson(String dateTimeString) {
  final utcDateTime = DateTime.parse(dateTimeString);
  return utcDateTime.toLocal();
}
