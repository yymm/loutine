import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/note.dart';
import 'package:mobile_ui/providers/repository_provider.dart';

part 'note_list_provider.g.dart';

/// ノート一覧を取得するProvider（カレンダー用）
/// 
/// **このProviderは読み取り専用です**
/// ノートの作成・更新・削除は [NoteListPaginated] を使用してください
/// 
/// 役割:
/// - home_calendarでの更新検知（ref.listenで監視）
/// - 日付範囲での全件取得
/// 
/// 使い分け:
/// - [NoteList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [NoteListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）
@riverpod
class NoteList extends _$NoteList {
  @override
  Future<List<Note>> build() async {
    final repository = ref.watch(noteRepositoryProvider);
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 365));
    final endDate = now.add(const Duration(days: 365));
    return repository.fetchNotes(startDate, endDate);
  }
}
