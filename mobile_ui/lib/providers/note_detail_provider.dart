import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/note.dart';
import 'package:mobile_ui/providers/repository_provider.dart';

part 'note_detail_provider.g.dart';

/// 特定のノートを取得するProvider
@riverpod
class NoteDetail extends _$NoteDetail {
  @override
  Future<Note?> build(int noteId) async {
    final repository = ref.watch(noteRepositoryProvider);
    return repository.getNoteById(noteId);
  }
}
