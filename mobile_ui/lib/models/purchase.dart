// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'purchase.freezed.dart';
part 'purchase.g.dart';

@freezed
abstract class Purchase with _$Purchase {
  const factory Purchase({
    required int id,
    required String title,
    required int cost,
    @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
    required DateTime createdAt,
    @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)
    required DateTime updatedAt,
    // TODO: タグ機能を実装する際にコメントを外す
    // required List<Tag> tags,
  }) = _Purchase;

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);
}

DateTime _dateTimeFromJson(String dateTimeString) {
  final utcDateTime = DateTime.parse(dateTimeString);
  return utcDateTime.toLocal();
}
