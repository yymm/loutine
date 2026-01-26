import 'dart:convert';
import 'dart:io';

import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/link.dart';
import 'package:mobile_ui/exceptions/app_exceptions.dart';

/// Link関連のデータ取得を担当するRepository
///
/// 責務:
/// - APIクライアントを使ってデータを取得
/// - JSONレスポンスをLinkモデルに変換
/// - データ取得ロジックの抽象化
/// - エラーを適切なカスタム例外に変換
class LinkRepository {
  final LinkApiClient _apiClient;

  /// コンストラクタでAPIクライアントを注入
  /// これによりテスト時にモックAPIクライアントを渡せる
  LinkRepository(this._apiClient);

  /// 指定期間のリンク一覧を取得
  ///
  /// APIから取得したJSONをパースしてLinkのリストに変換して返す
  ///
  /// 発生する可能性のある例外:
  /// - [NetworkException]: ネットワークエラー
  /// - [ServerException]: サーバーエラー
  /// - [ParseException]: JSONパースエラー
  Future<List<Link>> fetchLinks(DateTime startDate, DateTime endDate) async {
    try {
      final resBody = await _apiClient.list(startDate, endDate);
      final List<dynamic> json = jsonDecode(resBody);
      return json.map((e) => Link.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      throw const NetworkException('インターネット接続を確認してください');
    } on FormatException catch (e) {
      throw ParseException('リンクデータの解析に失敗しました: ${e.message}');
    } on TypeError catch (e) {
      throw ParseException('リンクデータの形式が不正です: $e');
    }
  }

  /// 新しいリンクを作成
  ///
  /// APIに送信して作成されたLinkを返す
  ///
  /// 発生する可能性のある例外:
  /// - [NetworkException]: ネットワークエラー
  /// - [ServerException]: サーバーエラー
  /// - [ParseException]: JSONパースエラー
  Future<Link> createLink(String url, String title, List<int> tagIds) async {
    try {
      final resBody = await _apiClient.post(url, title, tagIds);
      final Map<String, dynamic> json = jsonDecode(resBody);
      return Link.fromJson(json);
    } on SocketException {
      throw const NetworkException('インターネット接続を確認してください');
    } on FormatException catch (e) {
      throw ParseException('作成されたリンクデータの解析に失敗しました: ${e.message}');
    } on TypeError catch (e) {
      throw ParseException('作成されたリンクデータの形式が不正です: $e');
    }
  }
}
