import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/category.dart';
import 'package:mobile_ui/providers/repository_provider.dart';

part 'category_list_provider.g.dart';

/// カテゴリ一覧の状態を管理するProvider
///
/// 変更点:
/// - APIクライアントを直接使わず、Repositoryを経由してデータ取得
/// - JSONパース処理はRepositoryに委譲
/// - Providerはデータの状態管理に専念
@riverpod
class CategoryList extends _$CategoryList {
  @override
  Future<List<Category>> build() async {
    final repository = ref.watch(categoryRepositoryProvider);
    return repository.fetchCategories();
  }

  /// 新しいカテゴリを追加
  ///
  /// Repositoryを使ってAPIにリクエストし、
  /// 作成されたカテゴリを状態に追加
  Future<Category> add(String name, String description) async {
    final repository = ref.read(categoryRepositoryProvider);
    final category = await repository.createCategory(name, description);
    // 非同期でinvalidate（呼び出し元に影響しない）
    Future.microtask(() {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
    return category;
  }

  /// カテゴリを削除
  ///
  /// Repositoryを使ってAPIにリクエストし、
  /// 削除されたカテゴリを状態から削除
  Future<void> delete(int categoryId) async {
    final repository = ref.read(categoryRepositoryProvider);
    await repository.deleteCategory(categoryId);
    // 非同期でinvalidate（呼び出し元に影響しない）
    Future.microtask(() {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
  }
}
