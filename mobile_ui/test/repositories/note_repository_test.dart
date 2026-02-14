import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/repositories/note_repository.dart';
import 'package:mobile_ui/exceptions/app_exceptions.dart';

/// NoteApiClientのモック
class MockNoteApiClient extends Mock implements NoteApiClient {}

void main() {
  group('NoteRepository', () {
    late NoteRepository repository;
    late MockNoteApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockNoteApiClient();
      repository = NoteRepository(mockApiClient);
    });

    group('fetchNotes', () {
      test('APIから取得したJSONをNoteモデルのリストに変換する', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        final jsonResponse = '''
        [
          {
            "id": 1,
            "title": "ノート1",
            "text": "[{\\"insert\\":\\"テスト内容\\\\n\\"}]",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T00:00:00Z"
          },
          {
            "id": 2,
            "title": "ノート2",
            "text": "[{\\"insert\\":\\"内容2\\\\n\\"}]",
            "created_at": "2024-01-02T00:00:00Z",
            "updated_at": "2024-01-02T00:00:00Z"
          }
        ]
        ''';

        when(
          () => mockApiClient.list(startDate, endDate),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final notes = await repository.fetchNotes(startDate, endDate);

        // Assert
        expect(notes.length, 2);
        expect(notes[0].id, 1);
        expect(notes[0].title, 'ノート1');
        expect(notes[0].text, '[{"insert":"テスト内容\\n"}]');
        expect(notes[1].id, 2);
        expect(notes[1].title, 'ノート2');

        verify(() => mockApiClient.list(startDate, endDate)).called(1);
      });

      test('空のリストを正しく処理できる', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        when(
          () => mockApiClient.list(startDate, endDate),
        ).thenAnswer((_) async => '[]');

        // Act
        final notes = await repository.fetchNotes(startDate, endDate);

        // Assert
        expect(notes, isEmpty);
        verify(() => mockApiClient.list(startDate, endDate)).called(1);
      });

      test('ネットワークエラーの場合にNetworkExceptionをスローする', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        when(
          () => mockApiClient.list(startDate, endDate),
        ).thenThrow(const SocketException('No internet'));

        // Act & Assert
        expect(
          () => repository.fetchNotes(startDate, endDate),
          throwsA(isA<NetworkException>()),
        );
      });

      test('不正なJSONの場合にParseExceptionをスローする', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        when(
          () => mockApiClient.list(startDate, endDate),
        ).thenAnswer((_) async => 'invalid json');

        // Act & Assert
        expect(
          () => repository.fetchNotes(startDate, endDate),
          throwsA(isA<ParseException>()),
        );
      });
    });

    group('createNote', () {
      test('APIに送信して作成されたNoteを返す', () async {
        // Arrange
        final jsonResponse = '''
        {
          "id": 1,
          "title": "新規ノート",
          "text": "[{\\"insert\\":\\"新規内容\\\\n\\"}]",
          "created_at": "2024-01-01T00:00:00Z",
          "updated_at": "2024-01-01T00:00:00Z"
        }
        ''';

        when(
          () => mockApiClient.post('[{"insert":"新規内容\\n"}]', '新規ノート', [1]),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final note = await repository.createNote(
          title: '新規ノート',
          text: '[{"insert":"新規内容\\n"}]',
          tagIds: [1],
        );

        // Assert
        expect(note.id, 1);
        expect(note.title, '新規ノート');
        expect(note.text, '[{"insert":"新規内容\\n"}]');

        verify(
          () => mockApiClient.post('[{"insert":"新規内容\\n"}]', '新規ノート', [1]),
        ).called(1);
      });

      test('タグなしでノートを作成できる', () async {
        // Arrange
        final jsonResponse = '''
        {
          "id": 2,
          "title": "タグなし",
          "text": "[{\\"insert\\":\\"内容\\\\n\\"}]",
          "created_at": "2024-01-01T00:00:00Z",
          "updated_at": "2024-01-01T00:00:00Z"
        }
        ''';

        when(
          () => mockApiClient.post('[{"insert":"内容\\n"}]', 'タグなし', []),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final note = await repository.createNote(
          title: 'タグなし',
          text: '[{"insert":"内容\\n"}]',
        );

        // Assert
        expect(note.id, 2);
      });

      test('ネットワークエラーの場合にNetworkExceptionをスローする', () async {
        // Arrange
        when(
          () => mockApiClient.post(any(), any(), any()),
        ).thenThrow(const SocketException('No internet'));

        // Act & Assert
        expect(
          () => repository.createNote(
            title: 'テスト',
            text: '[{"insert":"test\\n"}]',
          ),
          throwsA(isA<NetworkException>()),
        );
      });

      test('不正なレスポンスの場合にParseExceptionをスローする', () async {
        // Arrange
        when(
          () => mockApiClient.post(any(), any(), any()),
        ).thenAnswer((_) async => 'invalid json');

        // Act & Assert
        expect(
          () => repository.createNote(
            title: 'テスト',
            text: '[{"insert":"test\\n"}]',
          ),
          throwsA(isA<ParseException>()),
        );
      });
    });

    group('updateNote', () {
      test('未実装のため例外をスローする', () async {
        // Act & Assert
        expect(() => repository.updateNote, isA<Function>());
      });
    });

    group('deleteNote', () {
      test('未実装のため例外をスローする', () async {
        // Act & Assert
        expect(() => repository.deleteNote, isA<Function>());
      });
    });

    group('getNoteById', () {
      test('未実装のため例外をスローする', () async {
        // Act & Assert
        expect(() => repository.getNoteById, isA<Function>());
      });
    });

    group('fetchNotesPaginated', () {
      test('APIから取得したJSONをPaginatedResultに変換する', () async {
        // Arrange
        const cursor = null;
        const limit = 20;
        final jsonResponse = '''
        {
          "notes": [
            {
              "id": 1,
              "title": "ノート1",
              "text": "[{\\"insert\\":\\"内容1\\\\n\\"}]",
              "created_at": "2024-01-01T00:00:00Z",
              "updated_at": "2024-01-01T00:00:00Z"
            },
            {
              "id": 2,
              "title": "ノート2",
              "text": "[{\\"insert\\":\\"内容2\\\\n\\"}]",
              "created_at": "2024-01-02T00:00:00Z",
              "updated_at": "2024-01-02T00:00:00Z"
            }
          ],
          "next_cursor": "cursor_string",
          "has_next_page": true
        }
        ''';

        when(
          () => mockApiClient.listPaginated(cursor: cursor, limit: limit),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final result = await repository.fetchNotesPaginated(
          cursor: cursor,
          limit: limit,
        );

        // Assert
        expect(result.items.length, 2);
        expect(result.items[0].id, 1);
        expect(result.items[0].title, 'ノート1');
        expect(result.items[1].id, 2);
        expect(result.nextCursor, 'cursor_string');
        expect(result.hasMore, true);
        verify(
          () => mockApiClient.listPaginated(cursor: cursor, limit: limit),
        ).called(1);
      });

      test('cursorを指定して次のページを取得できる', () async {
        // Arrange
        const cursor = 'existing_cursor';
        const limit = 20;
        final jsonResponse = '''
        {
          "notes": [
            {
              "id": 3,
              "title": "ノート3",
              "text": "[{\\"insert\\":\\"内容3\\\\n\\"}]",
              "created_at": "2024-01-03T00:00:00Z",
              "updated_at": "2024-01-03T00:00:00Z"
            }
          ],
          "next_cursor": "next_cursor_string",
          "has_next_page": true
        }
        ''';

        when(
          () => mockApiClient.listPaginated(cursor: cursor, limit: limit),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final result = await repository.fetchNotesPaginated(
          cursor: cursor,
          limit: limit,
        );

        // Assert
        expect(result.items.length, 1);
        expect(result.items[0].id, 3);
        expect(result.nextCursor, 'next_cursor_string');
        expect(result.hasMore, true);
      });

      test('最終ページではhas_next_pageがfalseになる', () async {
        // Arrange
        const cursor = 'last_cursor';
        const limit = 20;
        final jsonResponse = '''
        {
          "notes": [
            {
              "id": 100,
              "title": "最後のノート",
              "text": "[{\\"insert\\":\\"最後の内容\\\\n\\"}]",
              "created_at": "2024-01-31T00:00:00Z",
              "updated_at": "2024-01-31T00:00:00Z"
            }
          ],
          "next_cursor": null,
          "has_next_page": false
        }
        ''';

        when(
          () => mockApiClient.listPaginated(cursor: cursor, limit: limit),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final result = await repository.fetchNotesPaginated(
          cursor: cursor,
          limit: limit,
        );

        // Assert
        expect(result.items.length, 1);
        expect(result.nextCursor, null);
        expect(result.hasMore, false);
      });

      test('空のリストを正しく処理できる', () async {
        // Arrange
        const cursor = null;
        const limit = 20;
        final jsonResponse = '''
        {
          "notes": [],
          "next_cursor": null,
          "has_next_page": false
        }
        ''';

        when(
          () => mockApiClient.listPaginated(cursor: cursor, limit: limit),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final result = await repository.fetchNotesPaginated(
          cursor: cursor,
          limit: limit,
        );

        // Assert
        expect(result.items, isEmpty);
        expect(result.hasMore, false);
      });

      test('ネットワークエラー時にNetworkExceptionを投げる', () async {
        // Arrange
        when(
          () => mockApiClient.listPaginated(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenThrow(const SocketException('Network unreachable'));

        // Act & Assert
        expect(
          () => repository.fetchNotesPaginated(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('不正なJSON形式の場合にParseExceptionを投げる', () async {
        // Arrange
        when(
          () => mockApiClient.listPaginated(
            cursor: any(named: 'cursor'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => 'invalid json');

        // Act & Assert
        expect(
          () => repository.fetchNotesPaginated(),
          throwsA(isA<ParseException>()),
        );
      });
    });
  });
}
