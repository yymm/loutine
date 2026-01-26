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
  List<Category> build() => [];

  /// 新しいカテゴリを追加
  ///
  /// Repositoryを使ってAPIにリクエストし、
  /// 作成されたカテゴリを状態に追加
  Future<void> add(String name, String description) async {
    final repository = ref.read(categoryRepositoryProvider);
    final category = await repository.createCategory(name, description);
    if (!ref.mounted) return;
    state = [...state, category];
  }

  /// カテゴリ一覧を取得
  ///
  /// Repositoryを使ってAPIからカテゴリ一覧を取得し、
  /// 状態を更新
  Future<List<Category>> getList() async {
    final repository = ref.read(categoryRepositoryProvider);
    final categoryList = await repository.fetchCategories();
    if (!ref.mounted) return categoryList;
    state = categoryList;
    return categoryList;
  }
}

/// カテゴリ一覧をFutureとして提供するProvider
///
/// 初回表示時などに使用
@riverpod
Future<List<Category>> categoryListFuture(Ref ref) async {
  return ref.read(categoryListProvider.notifier).getList();
}
