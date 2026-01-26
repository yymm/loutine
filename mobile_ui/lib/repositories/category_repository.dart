import 'dart:convert';

import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/category.dart';

/// Category関連のデータ取得を担当するRepository
///
/// 責務:
/// - APIクライアントを使ってデータを取得
/// - JSONレスポンスをCategoryモデルに変換
/// - データ取得ロジックの抽象化（将来的なキャッシュ追加などに対応しやすく）
class CategoryRepository {
  final CategoryApiClient _apiClient;

  /// コンストラクタでAPIクライアントを注入
  /// これによりテスト時にモックAPIクライアントを渡せる
  CategoryRepository(this._apiClient);

  /// カテゴリ一覧を取得
  ///
  /// APIから取得したJSONをパースしてCategoryのリストに変換して返す
  Future<List<Category>> fetchCategories() async {
    final resBody = await _apiClient.list();
    final List<dynamic> json = jsonDecode(resBody);
    return json
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 新しいカテゴリを作成
  ///
  /// APIに送信して作成されたCategoryを返す
  Future<Category> createCategory(String name, String description) async {
    final resBody = await _apiClient.post(name, description);
    final Map<String, dynamic> json = jsonDecode(resBody);
    return Category.fromJson(json);
  }
}
