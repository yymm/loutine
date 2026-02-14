import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/repositories/link_repository.dart';
import 'package:mobile_ui/exceptions/app_exceptions.dart';

/// LinkApiClientのモック
class MockLinkApiClient extends Mock implements LinkApiClient {}

void main() {
  group('LinkRepository', () {
    late LinkRepository repository;
    late MockLinkApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockLinkApiClient();
      repository = LinkRepository(mockApiClient);
    });

    group('fetchLinks', () {
      test('APIから取得したJSONをLinkモデルのリストに変換する', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        final jsonResponse = '''
        [
          {
            "id": 1,
            "title": "リンク1",
            "url": "https://example.com/1",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T00:00:00Z"
          },
          {
            "id": 2,
            "title": "リンク2",
            "url": "https://example.com/2",
            "created_at": "2024-01-02T00:00:00Z",
            "updated_at": "2024-01-02T00:00:00Z"
          }
        ]
        ''';

        when(
          () => mockApiClient.list(startDate, endDate),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final links = await repository.fetchLinks(startDate, endDate);

        // Assert
        expect(links.length, 2);
        expect(links[0].id, 1);
        expect(links[0].title, 'リンク1');
        expect(links[0].url, 'https://example.com/1');
        expect(links[1].id, 2);
        expect(links[1].title, 'リンク2');

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
        final links = await repository.fetchLinks(startDate, endDate);

        // Assert
        expect(links, isEmpty);
        verify(() => mockApiClient.list(startDate, endDate)).called(1);
      });
    });

    group('createLink', () {
      test('新しいリンクを作成して返す', () async {
        // Arrange
        const url = 'https://example.com/new';
        const title = '新しいリンク';
        final tagIds = [1, 2];
        final jsonResponse =
            '''
        {
          "id": 3,
          "title": "$title",
          "url": "$url",
          "created_at": "2024-01-03T00:00:00Z",
          "updated_at": "2024-01-03T00:00:00Z"
        }
        ''';

        when(
          () => mockApiClient.post(url, title, tagIds),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final link = await repository.createLink(url, title, tagIds);

        // Assert
        expect(link.id, 3);
        expect(link.title, title);
        expect(link.url, url);
        verify(() => mockApiClient.post(url, title, tagIds)).called(1);
      });
    });

    group('fetchLinksPaginated', () {
      test('APIから取得したJSONをPaginatedResultに変換する', () async {
        // Arrange
        const cursor = null;
        const limit = 20;
        final jsonResponse = '''
        {
          "links": [
            {
              "id": 1,
              "title": "リンク1",
              "url": "https://example.com/1",
              "created_at": "2024-01-01T00:00:00Z",
              "updated_at": "2024-01-01T00:00:00Z"
            },
            {
              "id": 2,
              "title": "リンク2",
              "url": "https://example.com/2",
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
        final result = await repository.fetchLinksPaginated(cursor: cursor, limit: limit);

        // Assert
        expect(result.items.length, 2);
        expect(result.items[0].id, 1);
        expect(result.items[0].title, 'リンク1');
        expect(result.items[1].id, 2);
        expect(result.nextCursor, 'cursor_string');
        expect(result.hasMore, true);
        verify(() => mockApiClient.listPaginated(cursor: cursor, limit: limit)).called(1);
      });

      test('cursorを指定して次のページを取得できる', () async {
        // Arrange
        const cursor = 'existing_cursor';
        const limit = 20;
        final jsonResponse = '''
        {
          "links": [
            {
              "id": 3,
              "title": "リンク3",
              "url": "https://example.com/3",
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
        final result = await repository.fetchLinksPaginated(cursor: cursor, limit: limit);

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
          "links": [
            {
              "id": 100,
              "title": "最後のリンク",
              "url": "https://example.com/100",
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
        final result = await repository.fetchLinksPaginated(cursor: cursor, limit: limit);

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
          "links": [],
          "next_cursor": null,
          "has_next_page": false
        }
        ''';

        when(
          () => mockApiClient.listPaginated(cursor: cursor, limit: limit),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final result = await repository.fetchLinksPaginated(cursor: cursor, limit: limit);

        // Assert
        expect(result.items, isEmpty);
        expect(result.hasMore, false);
      });

      test('ネットワークエラー時にNetworkExceptionを投げる', () async {
        // Arrange
        when(
          () => mockApiClient.listPaginated(cursor: any(named: 'cursor'), limit: any(named: 'limit')),
        ).thenThrow(const SocketException('Network unreachable'));

        // Act & Assert
        expect(
          () => repository.fetchLinksPaginated(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('不正なJSON形式の場合にParseExceptionを投げる', () async {
        // Arrange
        when(
          () => mockApiClient.listPaginated(cursor: any(named: 'cursor'), limit: any(named: 'limit')),
        ).thenAnswer((_) async => 'invalid json');

        // Act & Assert
        expect(
          () => repository.fetchLinksPaginated(),
          throwsA(isA<ParseException>()),
        );
      });
    });

    group('エラーハンドリング', () {
      test('ネットワークエラー時にNetworkExceptionを投げる', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        when(
          () => mockApiClient.list(startDate, endDate),
        ).thenThrow(const SocketException('Network unreachable'));

        // Act & Assert
        expect(
          () => repository.fetchLinks(startDate, endDate),
          throwsA(isA<NetworkException>()),
        );
      });

      test('不正なJSON形式の場合にParseExceptionを投げる', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        when(
          () => mockApiClient.list(startDate, endDate),
        ).thenAnswer((_) async => 'invalid json');

        // Act & Assert
        expect(
          () => repository.fetchLinks(startDate, endDate),
          throwsA(isA<ParseException>()),
        );
      });

      test('JSONの型が期待と異なる場合にParseExceptionを投げる', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        when(
          () => mockApiClient.list(startDate, endDate),
        ).thenAnswer((_) async => '"this should be an array"');

        // Act & Assert
        expect(
          () => repository.fetchLinks(startDate, endDate),
          throwsA(isA<ParseException>()),
        );
      });
    });
  });
}
