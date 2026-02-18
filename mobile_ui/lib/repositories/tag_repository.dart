import 'dart:convert';
import 'dart:io';

import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/tag.dart';
import 'package:mobile_ui/exceptions/app_exceptions.dart';

/// Tag関連のデータ取得を担当するRepository
///
/// 責務:
/// - APIクライアントを使ってデータを取得
/// - JSONレスポンスをTagモデルに変換
/// - データ取得ロジックの抽象化（将来的なキャッシュ追加などに対応しやすく）
/// - エラーを適切なカスタム例外に変換
class TagRepository {
  final TagApiClient _apiClient;

  /// コンストラクタでAPIクライアントを注入
  /// これによりテスト時にモックAPIクライアントを渡せる
  TagRepository(this._apiClient);

  /// タグ一覧を取得
  ///
  /// APIから取得したJSONをパースしてTagのリストに変換して返す
  ///
  /// 発生する可能性のある例外:
  /// - [NetworkException]: ネットワークエラー
  /// - [ServerException]: サーバーエラー
  /// - [ParseException]: JSONパースエラー
  Future<List<Tag>> fetchTags() async {
    try {
      final resBody = await _apiClient.list();
      final List<dynamic> json = jsonDecode(resBody);
      return json.map((e) => Tag.fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      // ネットワーク接続エラー
      throw const NetworkException('インターネット接続を確認してください');
    } on FormatException catch (e) {
      // JSONパースエラー
      throw ParseException('タグデータの解析に失敗しました: ${e.message}');
    } on TypeError catch (e) {
      // 型変換エラー（APIレスポンスの形式が期待と異なる）
      throw ParseException('タグデータの形式が不正です: $e');
    }
  }

  /// 新しいタグを作成
  ///
  /// APIに送信して作成されたTagを返す
  ///
  /// 発生する可能性のある例外:
  /// - [NetworkException]: ネットワークエラー
  /// - [ServerException]: サーバーエラー
  /// - [ParseException]: JSONパースエラー
  Future<Tag> createTag(String name, String description) async {
    try {
      final resBody = await _apiClient.post(name, description);
      final Map<String, dynamic> json = jsonDecode(resBody);
      return Tag.fromJson(json);
    } on SocketException {
      throw const NetworkException('インターネット接続を確認してください');
    } on FormatException catch (e) {
      throw ParseException('作成されたタグデータの解析に失敗しました: ${e.message}');
    } on TypeError catch (e) {
      throw ParseException('作成されたタグデータの形式が不正です: $e');
    }
  }

  Future<Tag> deleteTag(int tagId) async {
    try {
      final resBody = await _apiClient.delete(tagId);
      final Map<String, dynamic> json = jsonDecode(resBody);
      return Tag.fromJson(json);
    } on SocketException {
      throw const NetworkException('インターネット接続を確認してください');
    } on FormatException catch (e) {
      throw ParseException('削除されたタグデータの解析に失敗しました: ${e.message}');
    } on TypeError catch (e) {
      throw ParseException('削除されたタグデータの形式が不正です: $e');
    }
  }
}
