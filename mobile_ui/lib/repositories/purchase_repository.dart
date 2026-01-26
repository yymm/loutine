import 'dart:convert';

import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/purchase.dart';

/// Purchase関連のデータ取得を担当するRepository
///
/// 責務:
/// - APIクライアントを使ってデータを取得
/// - JSONレスポンスをPurchaseモデルに変換
/// - データ取得ロジックの抽象化
class PurchaseRepository {
  final PurchaseApiClient _apiClient;

  /// コンストラクタでAPIクライアントを注入
  /// これによりテスト時にモックAPIクライアントを渡せる
  PurchaseRepository(this._apiClient);

  /// 指定期間の購入履歴一覧を取得
  ///
  /// APIから取得したJSONをパースしてPurchaseのリストに変換して返す
  Future<List<Purchase>> fetchPurchases(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final resBody = await _apiClient.list(startDate, endDate);
    final List<dynamic> json = jsonDecode(resBody);
    return json
        .map((e) => Purchase.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 新しい購入履歴を作成
  ///
  /// APIに送信して作成されたPurchaseを返す
  Future<Purchase> createPurchase(
    double cost,
    String title,
    int? categoryId,
  ) async {
    final resBody = await _apiClient.post(cost, title, categoryId);
    final Map<String, dynamic> json = jsonDecode(resBody);
    return Purchase.fromJson(json);
  }
}
