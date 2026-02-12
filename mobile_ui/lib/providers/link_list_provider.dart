import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/link.dart';
import 'package:mobile_ui/providers/repository_provider.dart';

part 'link_list_provider.g.dart';

/// リンク一覧を取得するProvider（カレンダー用）
/// 
/// **このProviderは読み取り専用です**
/// リンクの作成・更新・削除は [LinkListPaginated] を使用してください
/// 
/// 役割:
/// - home_calendarでの更新検知（ref.listenで監視）
/// - 日付範囲での全件取得
/// 
/// 使い分け:
/// - [LinkList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [LinkListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）
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
}
