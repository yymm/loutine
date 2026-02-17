import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/purchase.dart';
import 'package:mobile_ui/providers/repository_provider.dart';

part 'purchase_list_provider.g.dart';

/// 購入履歴一覧を取得するProvider
@riverpod
class PurchaseList extends _$PurchaseList {
  @override
  Future<List<Purchase>> build() async {
    final repository = ref.watch(purchaseRepositoryProvider);
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 365));
    final endDate = now.add(const Duration(days: 365));
    return repository.fetchPurchases(startDate, endDate);
  }

  /// 購入履歴を作成
  Future<Purchase> createPurchase(
    double cost,
    String title,
    int? categoryId,
  ) async {
    final repository = ref.read(purchaseRepositoryProvider);
    final purchase = await repository.createPurchase(cost, title, categoryId);
    // invalidateSelfの前に値を保存
    final result = purchase;
    // 非同期でinvalidate（呼び出し元に影響しない）
    Future.microtask(() {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
    return result;
  }

  Future<Purchase> deletePurchase(int purchaseId) async {
    final repository = ref.read(purchaseRepositoryProvider);
    final purchase = await repository.deletePurchase(purchaseId);

    // 非同期でinvalidate（呼び出し元に影響しない）
    Future.microtask(() {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });

    return purchase;
  }
}
