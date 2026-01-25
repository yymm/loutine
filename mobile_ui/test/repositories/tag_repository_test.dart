import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/repositories/tag_repository.dart';
import 'package:mobile_ui/models/tag.dart';

/// TagApiClientのモック
/// mocktailを使って実際のAPIコールを避ける
class MockTagApiClient extends Mock implements TagApiClient {}

void main() {
  group('TagRepository', () {
    late TagRepository repository;
    late MockTagApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockTagApiClient();
      repository = TagRepository(mockApiClient);
    });

    group('fetchTags', () {
      test('APIから取得したJSONをTagモデルのリストに変換する', () async {
        // Arrange: モックAPIクライアントの振る舞いを定義
        final jsonResponse = '''
        [
          {
            "id": 1,
            "name": "タグ1",
            "description": "説明1",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T00:00:00Z"
          },
          {
            "id": 2,
            "name": "タグ2",
            "description": "説明2",
            "created_at": "2024-01-02T00:00:00Z",
            "updated_at": "2024-01-02T00:00:00Z"
          }
        ]
        ''';
        
        when(() => mockApiClient.list()).thenAnswer((_) async => jsonResponse);

        // Act: Repositoryメソッドを実行
        final tags = await repository.fetchTags();

        // Assert: 正しく変換されているか検証
        expect(tags.length, 2);
        expect(tags[0].id, 1);
        expect(tags[0].name, 'タグ1');
        expect(tags[0].description, '説明1');
        expect(tags[1].id, 2);
        expect(tags[1].name, 'タグ2');
        
        // APIクライアントが1回呼ばれたことを確認
        verify(() => mockApiClient.list()).called(1);
      });

      test('空のリストを正しく処理できる', () async {
        // Arrange
        when(() => mockApiClient.list()).thenAnswer((_) async => '[]');

        // Act
        final tags = await repository.fetchTags();

        // Assert
        expect(tags, isEmpty);
        verify(() => mockApiClient.list()).called(1);
      });
    });

    group('createTag', () {
      test('新しいタグを作成して返す', () async {
        // Arrange
        const name = '新しいタグ';
        const description = '新しい説明';
        final jsonResponse = '''
        {
          "id": 3,
          "name": "$name",
          "description": "$description",
          "created_at": "2024-01-03T00:00:00Z",
          "updated_at": "2024-01-03T00:00:00Z"
        }
        ''';
        
        when(() => mockApiClient.post(name, description))
            .thenAnswer((_) async => jsonResponse);

        // Act
        final tag = await repository.createTag(name, description);

        // Assert
        expect(tag.id, 3);
        expect(tag.name, name);
        expect(tag.description, description);
        verify(() => mockApiClient.post(name, description)).called(1);
      });
    });
  });
}
