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
  List<Tag> build() => [];

  /// 新しいタグを追加
  ///
  /// Repositoryを使ってAPIにリクエストし、
  /// 作成されたタグを状態に追加
  Future<void> add(String name, String description) async {
    final repository = ref.read(tagRepositoryProvider);
    final tag = await repository.createTag(name, description);
    if (!ref.mounted) return;
    state = [...state, tag];
  }

  /// タグ一覧を取得
  ///
  /// Repositoryを使ってAPIからタグ一覧を取得し、
  /// 状態を更新
  Future<List<Tag>> getList() async {
    final repository = ref.read(tagRepositoryProvider);
    final tagList = await repository.fetchTags();
    if (!ref.mounted) return tagList;
    state = tagList;
    return tagList;
  }
}

/// タグ一覧をFutureとして提供するProvider
///
/// 初回表示時などに使用
@riverpod
Future<List<Tag>> tagListFuture(Ref ref) async {
  return ref.read(tagListProvider.notifier).getList();
}
