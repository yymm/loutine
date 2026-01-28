// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'note.freezed.dart';
part 'note.g.dart';

/// Noteモデル - Freezedを使用したイミュータブルなデータクラス
@freezed
abstract class Note with _$Note {
  const factory Note({
    required int id,
    required String title,
    @JsonKey(name: 'text') required String text,
    @JsonKey(name: 'tag_ids') @Default([]) List<int> tagIds,
    DateTime? date,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
  }) = _Note;

  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
