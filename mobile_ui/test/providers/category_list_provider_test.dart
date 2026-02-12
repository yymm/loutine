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
    test('buildでRepositoryからカテゴリ一覧を取得する', () async {
      // Arrange
      final mockRepository = MockCategoryRepository();
      final now = DateTime.now();
      final mockCategories = [
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
      when(
        () => mockRepository.fetchCategories(),
      ).thenAnswer((_) async => mockCategories);

      final container = ProviderContainer(
        overrides: [
          categoryRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act: Providerを読み込むとbuildが実行される
      final state = await container.read(categoryListProvider.future);

      // Assert
      expect(state.length, 2);
      expect(state[0].name, 'カテゴリ1');
      expect(state[1].name, 'カテゴリ2');
      verify(() => mockRepository.fetchCategories()).called(1);
    });

    group('Repositoryを使った操作', () {
      late MockCategoryRepository mockRepository;

      setUp(() {
        mockRepository = MockCategoryRepository();
      });

      test('add()はRepositoryで新しいカテゴリを作成してinvalidateする', () async {
        // Arrange
        final now = DateTime.now();
        final initialCategories = [
          Category(
            id: 1,
            name: '既存カテゴリ',
            description: '既存説明',
            createdAt: now,
            updatedAt: now,
          ),
        ];
        final newCategory = Category(
          id: 2,
          name: '新規カテゴリ',
          description: '新規説明',
          createdAt: now,
          updatedAt: now,
        );

        // 初回のbuildとinvalidate後の両方をモック
        when(
          () => mockRepository.fetchCategories(),
        ).thenAnswer((_) async => initialCategories);
        when(
          () => mockRepository.createCategory('新規カテゴリ', '新規説明'),
        ).thenAnswer((_) async => newCategory);

        final container = ProviderContainer(
          overrides: [
            categoryRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        // 初期状態を取得
        await container.read(categoryListProvider.future);

        // invalidate後は新しいデータを返す
        when(
          () => mockRepository.fetchCategories(),
        ).thenAnswer((_) async => [...initialCategories, newCategory]);

        // Act: カテゴリを追加
        final result = await container
            .read(categoryListProvider.notifier)
            .add('新規カテゴリ', '新規説明');

        // Assert
        expect(result.name, '新規カテゴリ');
        verify(() => mockRepository.createCategory('新規カテゴリ', '新規説明')).called(1);

        // invalidateSelfが非同期で実行されるので少し待つ
        await Future.delayed(Duration(milliseconds: 100));

        // 再取得されたデータを確認
        final updatedState = await container.read(categoryListProvider.future);
        expect(updatedState.length, 2);
        expect(updatedState[1].name, '新規カテゴリ');
      });
    });
  });
}
