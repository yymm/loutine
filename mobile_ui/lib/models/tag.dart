import 'package:freezed_annotation/freezed_annotation.dart';

// Freezedが生成するコードを参照するための宣言
// tag.freezed.dart と tag.g.dart が自動生成される
part 'tag.freezed.dart';
part 'tag.g.dart';

/// Tagモデル - Freezedを使用したイミュータブルなデータクラス
///
/// Freezedの利点:
/// 1. copyWith()が自動生成される - 一部のフィールドだけ変更したコピーを簡単に作成
/// 2. ==演算子とhashCodeが自動生成される - 値で比較できる
/// 3. toStringが自動生成される - デバッグが容易
/// 4. fromJson/toJsonが自動生成される - JSON変換が簡単
/// 5. イミュータブルが保証される - 予期しない変更を防ぐ
@freezed
abstract class Tag with _$Tag {
  /// Tagのファクトリコンストラクタ
  ///
  /// @Defaultアノテーションでデフォルト値を指定できます
  /// @JsonSerializable(fieldRename: FieldRename.snake)により
  /// createdAt -> created_at、updatedAt -> updated_at に自動変換
  const factory Tag({
    required int id,
    required String name,
    @Default('') String description,
    @JsonKey(name: "created_at") required DateTime createdAt,
    @JsonKey(name: "updated_at") required DateTime updatedAt,
  }) = _Tag;

  /// JSONからTagオブジェクトを生成
  ///
  /// json_serializableが自動生成するヘルパー関数を使用
  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}
