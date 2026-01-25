import 'dart:convert';

import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/tag.dart';

/// Tag関連のデータ取得を担当するRepository
///
/// 責務:
/// - APIクライアントを使ってデータを取得
/// - JSONレスポンスをTagモデルに変換
/// - データ取得ロジックの抽象化（将来的なキャッシュ追加などに対応しやすく）
class TagRepository {
  final TagApiClient _apiClient;

  /// コンストラクタでAPIクライアントを注入
  /// これによりテスト時にモックAPIクライアントを渡せる
  TagRepository(this._apiClient);

  /// タグ一覧を取得
  ///
  /// APIから取得したJSONをパースしてTagのリストに変換して返す
  Future<List<Tag>> fetchTags() async {
    final resBody = await _apiClient.list();
    final List<dynamic> json = jsonDecode(resBody);
    return json.map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 新しいタグを作成
  ///
  /// APIに送信して作成されたTagを返す
  Future<Tag> createTag(String name, String description) async {
    final resBody = await _apiClient.post(name, description);
    final Map<String, dynamic> json = jsonDecode(resBody);
    return Tag.fromJson(json);
  }
}
