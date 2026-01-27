import 'package:mobile_ui/models/note.dart';
import 'package:uuid/uuid.dart';

/// Note関連のローカルデータ管理を担当するRepository
///
/// TODO: SharedPreferencesを使った永続化は後で実装
/// 現在はモックデータを返すのみ
class NoteRepository {
  final Uuid _uuid = const Uuid();
  final List<Note> _mockNotes = [];

  /// ノート一覧を取得
  Future<List<Note>> fetchNotes() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_mockNotes);
  }

  /// ノートを作成
  Future<Note> createNote({
    required String title,
    required String content,
    List<String> tagIds = const [],
    DateTime? date,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final now = DateTime.now();
    final note = Note(
      id: _uuid.v4(),
      title: title,
      content: content,
      tagIds: tagIds,
      date: date,
      createdAt: now,
      updatedAt: now,
    );

    _mockNotes.add(note);
    return note;
  }

  /// ノートを更新
  Future<Note> updateNote(Note note) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _mockNotes.indexWhere((n) => n.id == note.id);

    if (index == -1) {
      throw Exception('Note not found: ${note.id}');
    }

    final updatedNote = note.copyWith(updatedAt: DateTime.now());
    _mockNotes[index] = updatedNote;
    return updatedNote;
  }

  /// ノートを削除
  Future<void> deleteNote(String noteId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mockNotes.removeWhere((note) => note.id == noteId);
  }

  /// IDでノートを取得
  Future<Note?> getNoteById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _mockNotes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 日付でノートを取得
  Future<List<Note>> getNotesByDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockNotes.where((note) {
      if (note.date == null) return false;
      return note.date!.year == date.year &&
          note.date!.month == date.month &&
          note.date!.day == date.day;
    }).toList();
  }

  /// タグIDでノートを取得
  Future<List<Note>> getNotesByTagId(String tagId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockNotes.where((note) => note.tagIds.contains(tagId)).toList();
  }
}
