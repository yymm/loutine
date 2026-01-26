import 'dart:convert';
import 'dart:io';

import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/category.dart';
import 'package:mobile_ui/exceptions/app_exceptions.dart';

/// Category関連のデータ取得を担当するRepository
///
/// 責務:
/// - APIクライアントを使ってデータを取得
/// - JSONレスポンスをCategoryモデルに変換
/// - データ取得ロジックの抽象化（将来的なキャッシュ追加などに対応しやすく）
/// - エラーを適切なカスタム例外に変換
class CategoryRepository {
  final CategoryApiClient _apiClient;

  /// コンストラクタでAPIクライアントを注入
  /// これによりテスト時にモックAPIクライアントを渡せる
  CategoryRepository(this._apiClient);

  /// カテゴリ一覧を取得
  ///
  /// APIから取得したJSONをパースしてCategoryのリストに変換して返す
  ///
  /// 発生する可能性のある例外:
  /// - [NetworkException]: ネットワークエラー
  /// - [ServerException]: サーバーエラー
  /// - [ParseException]: JSONパースエラー
  Future<List<Category>> fetchCategories() async {
    try {
      final resBody = await _apiClient.list();
      final List<dynamic> json = jsonDecode(resBody);
      return json
          .map((e) => Category.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const NetworkException('インターネット接続を確認してください');
    } on FormatException catch (e) {
      throw ParseException('カテゴリデータの解析に失敗しました: ${e.message}');
    } on TypeError catch (e) {
      throw ParseException('カテゴリデータの形式が不正です: $e');
    }
  }

  /// 新しいカテゴリを作成
  ///
  /// APIに送信して作成されたCategoryを返す
  ///
  /// 発生する可能性のある例外:
  /// - [NetworkException]: ネットワークエラー
  /// - [ServerException]: サーバーエラー
  /// - [ParseException]: JSONパースエラー
  Future<Category> createCategory(String name, String description) async {
    try {
      final resBody = await _apiClient.post(name, description);
      final Map<String, dynamic> json = jsonDecode(resBody);
      return Category.fromJson(json);
    } on SocketException {
      throw const NetworkException('インターネット接続を確認してください');
    } on FormatException catch (e) {
      throw ParseException('作成されたカテゴリデータの解析に失敗しました: ${e.message}');
    } on TypeError catch (e) {
      throw ParseException('作成されたカテゴリデータの形式が不正です: $e');
    }
  }
}
