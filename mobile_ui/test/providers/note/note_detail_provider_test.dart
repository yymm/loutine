import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/providers/note/note_detail_provider.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/repositories/note_repository.dart';
import 'package:mobile_ui/models/note.dart';

class MockNoteRepository extends Mock implements NoteRepository {}

void main() {
  group('NoteDetail', () {
    late MockNoteRepository mockRepository;

    setUp(() {
      mockRepository = MockNoteRepository();
    });

    test('指定したIDのノートを取得する', () async {
      // Arrange
      final now = DateTime.now();
      final mockNote = Note(
        id: 1,
        title: 'テストノート',
        text: '[{"insert":"テスト内容\\n"}]',
        createdAt: now,
        updatedAt: now,
      );

      when(
        () => mockRepository.getNoteById(1),
      ).thenAnswer((_) async => mockNote);

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      final note = await container.read(noteDetailProvider(1).future);

      // Assert
      expect(note?.id, 1);
      expect(note?.title, 'テストノート');
      expect(note?.text, '[{"insert":"テスト内容\\n"}]');
      verify(() => mockRepository.getNoteById(1)).called(1);
    });

    test('存在しないIDの場合はnullを返す', () async {
      // Arrange
      when(() => mockRepository.getNoteById(999)).thenAnswer((_) async => null);

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      final note = await container.read(noteDetailProvider(999).future);

      // Assert
      expect(note, isNull);
      verify(() => mockRepository.getNoteById(999)).called(1);
    });

    test('異なるIDで異なるノートを取得する', () async {
      // Arrange
      final now = DateTime.now();
      final note1 = Note(
        id: 1,
        title: 'ノート1',
        text: '[{"insert":"内容1\\n"}]',
        createdAt: now,
        updatedAt: now,
      );
      final note2 = Note(
        id: 2,
        title: 'ノート2',
        text: '[{"insert":"内容2\\n"}]',
        createdAt: now,
        updatedAt: now,
      );

      when(() => mockRepository.getNoteById(1)).thenAnswer((_) async => note1);
      when(() => mockRepository.getNoteById(2)).thenAnswer((_) async => note2);

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      final result1 = await container.read(noteDetailProvider(1).future);
      final result2 = await container.read(noteDetailProvider(2).future);

      // Assert
      expect(result1?.id, 1);
      expect(result1?.title, 'ノート1');
      expect(result2?.id, 2);
      expect(result2?.title, 'ノート2');
    });
  });
}
