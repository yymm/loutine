import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/providers/note_list_paginated_provider.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/repositories/note_repository.dart';
import 'package:mobile_ui/models/note.dart';
import 'package:mobile_ui/models/paginated_result.dart';

/// NoteRepositoryのモック
class MockNoteRepository extends Mock implements NoteRepository {}

/// Noteのフェイク（mocktailで使用）
class FakeNote extends Fake implements Note {}

void main() {
  setUpAll(() {
    // Noteのフォールバック値を登録
    registerFallbackValue(FakeNote());
  });

  group('NoteListPaginated', () {
    late MockNoteRepository mockRepository;

    setUp(() {
      mockRepository = MockNoteRepository();
    });

    test('初期値はRepositoryから取得したページネーション結果', () async {
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

      final paginatedResult = PaginatedResult(
        items: mockNotes,
        nextCursor: 'cursor1',
        hasMore: true,
      );

      when(
        () => mockRepository.fetchNotesPaginated(cursor: null, limit: 20),
      ).thenAnswer((_) async => paginatedResult);

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      final state = await container.read(noteListPaginatedProvider.future);

      // Assert
      expect(state.items.length, 2);
      expect(state.items[0].id, 1);
      expect(state.items[1].id, 2);
      expect(state.nextCursor, 'cursor1');
      expect(state.hasMore, true);
      expect(state.isLoadingMore, false);
      verify(
        () => mockRepository.fetchNotesPaginated(cursor: null, limit: 20),
      ).called(1);
    });

    test('loadMore()で次のページを読み込む', () async {
      // Arrange
      final now = DateTime.now();
      final firstPageNotes = [
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
      final secondPageNotes = [
        Note(
          id: 3,
          title: 'ノート3',
          text: '[{"insert":"内容3\\n"}]',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(
        () => mockRepository.fetchNotesPaginated(cursor: null, limit: 20),
      ).thenAnswer(
        (_) async => PaginatedResult(
          items: firstPageNotes,
          nextCursor: 'cursor1',
          hasMore: true,
        ),
      );

      when(
        () => mockRepository.fetchNotesPaginated(cursor: 'cursor1', limit: 20),
      ).thenAnswer(
        (_) async => PaginatedResult(
          items: secondPageNotes,
          nextCursor: 'cursor2',
          hasMore: true,
        ),
      );

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // 初回ロード
      await container.read(noteListPaginatedProvider.future);

      // Act
      await container.read(noteListPaginatedProvider.notifier).loadMore();

      // Assert
      final state = container.read(noteListPaginatedProvider).value!;
      expect(state.items.length, 3);
      expect(state.items[0].id, 1);
      expect(state.items[1].id, 2);
      expect(state.items[2].id, 3);
      expect(state.nextCursor, 'cursor2');
      expect(state.hasMore, true);
    });

    test('hasMoreがfalseの場合はloadMore()が何もしない', () async {
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
      ];

      when(
        () => mockRepository.fetchNotesPaginated(cursor: null, limit: 20),
      ).thenAnswer(
        (_) async =>
            PaginatedResult(items: mockNotes, nextCursor: null, hasMore: false),
      );

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      await container.read(noteListPaginatedProvider.future);

      // Act
      await container.read(noteListPaginatedProvider.notifier).loadMore();

      // Assert
      // fetchNotesPaginatedは初回のみ呼ばれる（loadMoreでは呼ばれない）
      verify(
        () => mockRepository.fetchNotesPaginated(cursor: null, limit: 20),
      ).called(1);
      verifyNever(
        () => mockRepository.fetchNotesPaginated(
          cursor: any(named: 'cursor'),
          limit: 20,
        ),
      );
    });

    test('refresh()でリストを再取得する', () async {
      // Arrange
      final now = DateTime.now();
      final initialNotes = [
        Note(
          id: 1,
          title: 'ノート1',
          text: '[{"insert":"内容1\\n"}]',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final refreshedNotes = [
        Note(
          id: 2,
          title: '新しいノート',
          text: '[{"insert":"新しい内容\\n"}]',
          createdAt: now,
          updatedAt: now,
        ),
        Note(
          id: 1,
          title: 'ノート1',
          text: '[{"insert":"内容1\\n"}]',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(
        () => mockRepository.fetchNotesPaginated(cursor: null, limit: 20),
      ).thenAnswer(
        (_) async => PaginatedResult(
          items: initialNotes,
          nextCursor: 'cursor1',
          hasMore: true,
        ),
      );

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      await container.read(noteListPaginatedProvider.future);

      // リフレッシュ時は新しいデータを返す
      when(
        () => mockRepository.fetchNotesPaginated(cursor: null, limit: 20),
      ).thenAnswer(
        (_) async => PaginatedResult(
          items: refreshedNotes,
          nextCursor: 'cursor2',
          hasMore: true,
        ),
      );

      // Act
      await container.read(noteListPaginatedProvider.notifier).refresh();

      // Assert
      final state = container.read(noteListPaginatedProvider).value!;
      expect(state.items.length, 2);
      expect(state.items[0].id, 2);
      expect(state.items[0].title, '新しいノート');
    });

    test('createNote()でノートを作成し楽観的更新する', () async {
      // Arrange
      final now = DateTime.now();
      final existingNotes = [
        Note(
          id: 1,
          title: 'ノート1',
          text: '[{"insert":"内容1\\n"}]',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      final newNote = Note(
        id: 2,
        title: '新しいノート',
        text: '[{"insert":"新しい内容\\n"}]',
        createdAt: now,
        updatedAt: now,
      );

      when(
        () => mockRepository.fetchNotesPaginated(cursor: null, limit: 20),
      ).thenAnswer(
        (_) async => PaginatedResult(
          items: existingNotes,
          nextCursor: 'cursor1',
          hasMore: false,
        ),
      );

      when(
        () => mockRepository.createNote(
          title: '新しいノート',
          text: '[{"insert":"新しい内容\\n"}]',
          tagIds: [1],
        ),
      ).thenAnswer((_) async => newNote);

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      await container.read(noteListPaginatedProvider.future);

      // Act
      await container
          .read(noteListPaginatedProvider.notifier)
          .createNote(
            title: '新しいノート',
            text: '[{"insert":"新しい内容\\n"}]',
            tagIds: [1],
          );

      // Assert
      final state = container.read(noteListPaginatedProvider).value!;
      expect(state.items.length, 2);
      expect(state.items[0].id, 2); // 新しいノートが先頭に追加される
      expect(state.items[0].title, '新しいノート');
      expect(state.items[1].id, 1);
    });

    test('updateNote()でノートを更新する', () async {
      // Arrange
      final now = DateTime.now();
      final existingNotes = [
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
      final updatedNote = Note(
        id: 1,
        title: '更新されたノート',
        text: '[{"insert":"更新された内容\\n"}]',
        createdAt: now,
        updatedAt: now,
      );

      when(
        () => mockRepository.fetchNotesPaginated(cursor: null, limit: 20),
      ).thenAnswer(
        (_) async => PaginatedResult(
          items: existingNotes,
          nextCursor: null,
          hasMore: false,
        ),
      );

      when(
        () => mockRepository.updateNote(note: any(named: 'note'), tagIds: any(named: 'tagIds')),
      ).thenAnswer((_) async => updatedNote);

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      await container.read(noteListPaginatedProvider.future);

      // Act
      await container
          .read(noteListPaginatedProvider.notifier)
          .updateNote(note: updatedNote);

      // Assert
      final state = container.read(noteListPaginatedProvider).value!;
      expect(state.items.length, 2);
      expect(state.items[0].id, 1);
      expect(state.items[0].title, '更新されたノート');
      expect(state.items[1].id, 2);
    });

    test('deleteNote()でノートを削除する', () async {
      // Arrange
      final now = DateTime.now();
      final existingNotes = [
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
        () => mockRepository.fetchNotesPaginated(cursor: null, limit: 20),
      ).thenAnswer(
        (_) async => PaginatedResult(
          items: existingNotes,
          nextCursor: null,
          hasMore: false,
        ),
      );

      when(() => mockRepository.deleteNote(1)).thenAnswer(
        (_) async => existingNotes.firstWhere((note) => note.id == 1),
      );

      final container = ProviderContainer(
        overrides: [noteRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      await container.read(noteListPaginatedProvider.future);

      // Act
      await container.read(noteListPaginatedProvider.notifier).deleteNote(1);

      // Assert
      final state = container.read(noteListPaginatedProvider).value!;
      expect(state.items.length, 1);
      expect(state.items[0].id, 2); // ID 1が削除され、ID 2のみ残る
    });
  });
}
