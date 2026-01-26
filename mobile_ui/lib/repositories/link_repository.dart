import 'dart:convert';

import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/link.dart';

/// Link関連のデータ取得を担当するRepository
///
/// 責務:
/// - APIクライアントを使ってデータを取得
/// - JSONレスポンスをLinkモデルに変換
/// - データ取得ロジックの抽象化
class LinkRepository {
  final LinkApiClient _apiClient;

  /// コンストラクタでAPIクライアントを注入
  /// これによりテスト時にモックAPIクライアントを渡せる
  LinkRepository(this._apiClient);

  /// 指定期間のリンク一覧を取得
  ///
  /// APIから取得したJSONをパースしてLinkのリストに変換して返す
  Future<List<Link>> fetchLinks(DateTime startDate, DateTime endDate) async {
    final resBody = await _apiClient.list(startDate, endDate);
    final List<dynamic> json = jsonDecode(resBody);
    return json.map((e) => Link.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// 新しいリンクを作成
  ///
  /// APIに送信して作成されたLinkを返す
  Future<Link> createLink(String url, String title, List<int> tagIds) async {
    final resBody = await _apiClient.post(url, title, tagIds);
    final Map<String, dynamic> json = jsonDecode(resBody);
    return Link.fromJson(json);
  }
}
