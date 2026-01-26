import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/providers/category_list_provider.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/repositories/category_repository.dart';
import 'package:mobile_ui/models/category.dart';

/// CategoryRepositoryのモック
/// Providerテストでは、Repositoryをモック化して
/// ビジネスロジック（API処理）を避ける
class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  group('CategoryList', () {
    test('初期値は空のリスト', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(categoryListProvider), []);
    });

    test('状態は直接更新できる', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final now = DateTime.now();
      final testCategory = Category(
        id: 1,
        name: 'テストカテゴリ',
        description: '説明',
        createdAt: now,
        updatedAt: now,
      );
      container.read(categoryListProvider.notifier).state = [testCategory];

      final state = container.read(categoryListProvider);
      expect(state.length, 1);
      expect(state[0].name, 'テストカテゴリ');
    });

    test('複数のカテゴリを設定できる', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final now = DateTime.now();
      final categories = [
        Category(
          id: 1,
          name: 'カテゴリ1',
          description: '説明1',
          createdAt: now,
          updatedAt: now,
        ),
        Category(
          id: 2,
          name: 'カテゴリ2',
          description: '説明2',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      container.read(categoryListProvider.notifier).state = categories;

      final state = container.read(categoryListProvider);
      expect(state.length, 2);
      expect(state[0].name, 'カテゴリ1');
      expect(state[1].name, 'カテゴリ2');
    });

    group('Repositoryを使った操作', () {
      late MockCategoryRepository mockRepository;

      setUp(() {
        mockRepository = MockCategoryRepository();
      });

      test('getList()はRepositoryからカテゴリ一覧を取得して状態を更新する', () async {
        // Arrange: モックRepositoryの振る舞いを定義
        final now = DateTime.now();
        final mockCategories = [
          Category(
            id: 1,
            name: 'リポジトリカテゴリ1',
            description: '説明1',
            createdAt: now,
            updatedAt: now,
          ),
          Category(
            id: 2,
            name: 'リポジトリカテゴリ2',
            description: '説明2',
            createdAt: now,
            updatedAt: now,
          ),
        ];
        when(
          () => mockRepository.fetchCategories(),
        ).thenAnswer((_) async => mockCategories);

        // ProviderContainerでRepositoryをオーバーライド
        final container = ProviderContainer(
          overrides: [
            categoryRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        // Act: getList()を実行
        final result =
            await container.read(categoryListProvider.notifier).getList();

        // Assert: 正しく状態が更新されているか検証
        expect(result.length, 2);
        expect(result[0].name, 'リポジトリカテゴリ1');
        expect(result[1].name, 'リポジトリカテゴリ2');

        final state = container.read(categoryListProvider);
        expect(state.length, 2);
        expect(state[0].name, 'リポジトリカテゴリ1');

        // Repositoryが1回呼ばれたことを確認
        verify(() => mockRepository.fetchCategories()).called(1);
      });

      test('add()はRepositoryで新しいカテゴリを作成して状態に追加する', () async {
        // Arrange
        final now = DateTime.now();
        final newCategory = Category(
          id: 3,
          name: '新規カテゴリ',
          description: '新規説明',
          createdAt: now,
          updatedAt: now,
        );
        when(
          () => mockRepository.createCategory('新規カテゴリ', '新規説明'),
        ).thenAnswer((_) async => newCategory);

        final container = ProviderContainer(
          overrides: [
            categoryRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        // 初期状態を設定
        final existingCategory = Category(
          id: 1,
          name: '既存カテゴリ',
          description: '既存説明',
          createdAt: now,
          updatedAt: now,
        );
        container.read(categoryListProvider.notifier).state = [
          existingCategory,
        ];

        // Act
        await container
            .read(categoryListProvider.notifier)
            .add('新規カテゴリ', '新規説明');

        // Assert
        final state = container.read(categoryListProvider);
        expect(state.length, 2);
        expect(state[0].name, '既存カテゴリ');
        expect(state[1].name, '新規カテゴリ');

        verify(() => mockRepository.createCategory('新規カテゴリ', '新規説明')).called(1);
      });
    });
  });
}
