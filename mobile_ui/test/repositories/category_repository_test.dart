import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/repositories/category_repository.dart';

/// CategoryApiClientのモック
/// mocktailを使って実際のAPIコールを避ける
class MockCategoryApiClient extends Mock implements CategoryApiClient {}

void main() {
  group('CategoryRepository', () {
    late CategoryRepository repository;
    late MockCategoryApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockCategoryApiClient();
      repository = CategoryRepository(mockApiClient);
    });

    group('fetchCategories', () {
      test('APIから取得したJSONをCategoryモデルのリストに変換する', () async {
        // Arrange: モックAPIクライアントの振る舞いを定義
        final jsonResponse = '''
        [
          {
            "id": 1,
            "name": "カテゴリ1",
            "description": "説明1",
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T00:00:00Z"
          },
          {
            "id": 2,
            "name": "カテゴリ2",
            "description": "説明2",
            "created_at": "2024-01-02T00:00:00Z",
            "updated_at": "2024-01-02T00:00:00Z"
          }
        ]
        ''';

        when(() => mockApiClient.list()).thenAnswer((_) async => jsonResponse);

        // Act: Repositoryメソッドを実行
        final categories = await repository.fetchCategories();

        // Assert: 正しく変換されているか検証
        expect(categories.length, 2);
        expect(categories[0].id, 1);
        expect(categories[0].name, 'カテゴリ1');
        expect(categories[0].description, '説明1');
        expect(categories[1].id, 2);
        expect(categories[1].name, 'カテゴリ2');

        // APIクライアントが1回呼ばれたことを確認
        verify(() => mockApiClient.list()).called(1);
      });

      test('空のリストを正しく処理できる', () async {
        // Arrange
        when(() => mockApiClient.list()).thenAnswer((_) async => '[]');

        // Act
        final categories = await repository.fetchCategories();

        // Assert
        expect(categories, isEmpty);
        verify(() => mockApiClient.list()).called(1);
      });
    });

    group('createCategory', () {
      test('新しいカテゴリを作成して返す', () async {
        // Arrange
        const name = '新しいカテゴリ';
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

        when(() => mockApiClient.post(name, description)).thenAnswer((_) async => jsonResponse);

        // Act
        final category = await repository.createCategory(name, description);

        // Assert
        expect(category.id, 3);
        expect(category.name, name);
        expect(category.description, description);
        verify(() => mockApiClient.post(name, description)).called(1);
      });
    });
  });
}
