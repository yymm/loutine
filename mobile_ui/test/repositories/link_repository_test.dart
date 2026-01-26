import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/repositories/link_repository.dart';

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
        final jsonResponse = '''
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
  });
}
