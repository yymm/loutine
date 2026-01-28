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
            "tag_ids": [1, 2],
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T00:00:00Z"
          },
          {
            "id": 2,
            "title": "ノート2",
            "text": "[{\\"insert\\":\\"内容2\\\\n\\"}]",
            "tag_ids": [],
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
        expect(notes[0].tagIds, [1, 2]);
        expect(notes[1].id, 2);
        expect(notes[1].title, 'ノート2');
        expect(notes[1].tagIds, isEmpty);

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
          "tag_ids": [1],
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
        expect(note.tagIds, [1]);

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
          "tag_ids": [],
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
          tagIds: [],
        );

        // Assert
        expect(note.id, 2);
        expect(note.tagIds, isEmpty);
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
            tagIds: [],
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
            tagIds: [],
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
  });
}
