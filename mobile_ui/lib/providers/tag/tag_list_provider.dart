import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/tag.dart';
import 'package:mobile_ui/providers/repository_provider.dart';

part 'tag_list_provider.g.dart';

/// タグ一覧の状態を管理するProvider
///
/// 変更点:
/// - APIクライアントを直接使わず、Repositoryを経由してデータ取得
/// - JSONパース処理はRepositoryに委譲
/// - Providerはデータの状態管理に専念
@riverpod
class TagList extends _$TagList {
  @override
  Future<List<Tag>> build() async {
    final repository = ref.watch(tagRepositoryProvider);
    return repository.fetchTags();
  }

  /// 新しいタグを追加
  ///
  /// Repositoryを使ってAPIにリクエストし、
  /// 作成されたタグを状態に追加
  Future<Tag> add(String name, String description) async {
    final repository = ref.read(tagRepositoryProvider);
    final tag = await repository.createTag(name, description);
    // 非同期でinvalidate（呼び出し元に影響しない）
    Future.microtask(() {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
    return tag;
  }
}
