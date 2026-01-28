import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/note.dart';
import 'package:mobile_ui/providers/repository_provider.dart';

part 'note_list_provider.g.dart';

/// ノート一覧を取得するProvider
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

  /// ノートを削除
  Future<void> deleteNote(int noteId) async {
    final repository = ref.read(noteRepositoryProvider);
    await repository.deleteNote(noteId);
    // 非同期でinvalidate
    Future.microtask(() {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
  }

  /// ノートを作成
  Future<Note> createNote({
    required String title,
    required String text,
    List<int> tagIds = const [],
    DateTime? date,
  }) async {
    final repository = ref.read(noteRepositoryProvider);
    final note = await repository.createNote(
      title: title,
      text: text,
      tagIds: tagIds,
      date: date,
    );
    // invalidateSelfの前に値を保存
    final result = note;
    // 非同期でinvalidate（呼び出し元に影響しない）
    Future.microtask(() {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
    return result;
  }

  /// ノートを更新
  Future<Note> updateNote(Note note) async {
    final repository = ref.read(noteRepositoryProvider);
    final updatedNote = await repository.updateNote(note);
    // invalidateSelfの前に値を保存
    final result = updatedNote;
    // 非同期でinvalidate（呼び出し元に影響しない）
    Future.microtask(() {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
    return result;
  }
}
