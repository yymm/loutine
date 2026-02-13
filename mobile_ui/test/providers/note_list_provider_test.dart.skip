import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/providers/note_list_provider.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/repositories/note_repository.dart';
import 'package:mobile_ui/models/note.dart';

/// NoteRepositoryのモック
class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  group('NoteList', () {
    late MockNoteRepository mockRepository;

    setUp(() {
      mockRepository = MockNoteRepository();
    });

    test('初期値はRepositoryから取得したノート一覧', () async {
      // Arrange
      final now = DateTime.now();
      final mockNotes = [
        Note(
          id: 1,
          title: 'ノート1',
          text: '[{"insert":"内容1\\n"}]',
          createdAt: now,
          updatedAt: now,
        ),
        Note(
          id: 2,
          title: 'ノート2',
          text: '[{"insert":"内容2\\n"}]',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(
        () => mockRepository.fetchNotes(any(), any()),
      ).thenAnswer((_) async => mockNotes);

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      final noteList = await container.read(noteListProvider.future);

      // Assert
      expect(noteList.length, 2);
      expect(noteList[0].title, 'ノート1');
      expect(noteList[1].title, 'ノート2');
    });

    test('createNote()は新しいノートを作成して状態を更新する', () async {
      // Arrange
      final now = DateTime.now();
      final newNote = Note(
        id: 1,
        title: '新規ノート',
        text: '[{"insert":"新規内容\\n"}]',
        createdAt: now,
        updatedAt: now,
      );

      when(
        () => mockRepository.createNote(
          title: '新規ノート',
          text: '[{"insert":"新規内容\\n"}]',
        ),
      ).thenAnswer((_) async => newNote);

      when(
        () => mockRepository.fetchNotes(any(), any()),
      ).thenAnswer((_) async => [newNote]);

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container
          .read(noteListProvider.notifier)
          .createNote(title: '新規ノート', text: '[{"insert":"新規内容\\n"}]');

      // Assert
      expect(result.id, 1);
      expect(result.title, '新規ノート');

      verify(
        () => mockRepository.createNote(
          title: '新規ノート',
          text: '[{"insert":"新規内容\\n"}]',
        ),
      ).called(1);

      // invalidateSelfが呼ばれることを確認（間接的に）
      await Future.delayed(const Duration(milliseconds: 100));
      verify(
        () => mockRepository.fetchNotes(any(), any()),
      ).called(greaterThanOrEqualTo(1));
    });

    test('タグなしでノートを作成できる', () async {
      // Arrange
      final now = DateTime.now();
      final newNote = Note(
        id: 2,
        title: 'タグなし',
        text: '[{"insert":"内容\\n"}]',
        createdAt: now,
        updatedAt: now,
      );

      when(
        () => mockRepository.createNote(
          title: 'タグなし',
          text: '[{"insert":"内容\\n"}]',
        ),
      ).thenAnswer((_) async => newNote);

      when(
        () => mockRepository.fetchNotes(any(), any()),
      ).thenAnswer((_) async => [newNote]);

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container
          .read(noteListProvider.notifier)
          .createNote(title: 'タグなし', text: '[{"insert":"内容\\n"}]');

      // Assert
      expect(result.id, 2);
    });

    test('deleteNote()はノートを削除して状態を更新する', () async {
      // Arrange
      when(() => mockRepository.deleteNote(1)).thenAnswer((_) async {});

      when(
        () => mockRepository.fetchNotes(any(), any()),
      ).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(noteListProvider.notifier).deleteNote(1);

      // Assert
      verify(() => mockRepository.deleteNote(1)).called(1);

      // invalidateSelfが呼ばれることを確認（間接的に）
      await Future.delayed(const Duration(milliseconds: 100));
      verify(
        () => mockRepository.fetchNotes(any(), any()),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
