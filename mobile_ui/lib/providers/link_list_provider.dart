import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/link.dart';
import 'package:mobile_ui/providers/repository_provider.dart';

part 'link_list_provider.g.dart';

/// リンク一覧を取得するProvider
@riverpod
class LinkList extends _$LinkList {
  @override
  Future<List<Link>> build() async {
    final repository = ref.watch(linkRepositoryProvider);
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 365));
    final endDate = now.add(const Duration(days: 365));
    return repository.fetchLinks(startDate, endDate);
  }

  /// リンクを作成
  Future<Link> createLink(String url, String title, List<int> tagIds) async {
    final repository = ref.read(linkRepositoryProvider);
    final link = await repository.createLink(url, title, tagIds);
    // invalidateSelfの前に値を保存
    final result = link;
    // 非同期でinvalidate（呼び出し元に影響しない）
    Future.microtask(() {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
    return result;
  }
}
