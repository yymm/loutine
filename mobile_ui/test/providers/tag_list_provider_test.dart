import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/providers/tag_list_provider.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/repositories/tag_repository.dart';
import 'package:mobile_ui/models/tag.dart';

/// TagRepositoryのモック
/// Providerテストでは、Repositoryをモック化して
/// ビジネスロジック（API処理）を避ける
class MockTagRepository extends Mock implements TagRepository {}

void main() {
  group('TagList', () {
    test('初期値は空のリスト', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(tagListProvider), []);
    });

    test('状態は直接更新できる', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final now = DateTime.now();
      final testTag = Tag(
        id: 1,
        name: 'テストタグ',
        description: '説明',
        createdAt: now,
        updatedAt: now,
      );
      container.read(tagListProvider.notifier).state = [testTag];

      final state = container.read(tagListProvider);
      expect(state.length, 1);
      expect(state[0].name, 'テストタグ');
    });

    test('複数のタグを設定できる', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final now = DateTime.now();
      final tags = [
        Tag(
          id: 1,
          name: 'タグ1',
          description: '説明1',
          createdAt: now,
          updatedAt: now,
        ),
        Tag(
          id: 2,
          name: 'タグ2',
          description: '説明2',
          createdAt: now,
          updatedAt: now,
        ),
      ];
      container.read(tagListProvider.notifier).state = tags;

      final state = container.read(tagListProvider);
      expect(state.length, 2);
      expect(state[0].name, 'タグ1');
      expect(state[1].name, 'タグ2');
    });

    group('Repositoryを使った操作', () {
      late MockTagRepository mockRepository;

      setUp(() {
        mockRepository = MockTagRepository();
      });

      test('getList()はRepositoryからタグ一覧を取得して状態を更新する', () async {
        // Arrange: モックRepositoryの振る舞いを定義
        final now = DateTime.now();
        final mockTags = [
          Tag(
            id: 1,
            name: 'リポジトリタグ1',
            description: '説明1',
            createdAt: now,
            updatedAt: now,
          ),
          Tag(
            id: 2,
            name: 'リポジトリタグ2',
            description: '説明2',
            createdAt: now,
            updatedAt: now,
          ),
        ];
        when(() => mockRepository.fetchTags())
            .thenAnswer((_) async => mockTags);

        // ProviderContainerでRepositoryをオーバーライド
        final container = ProviderContainer(
          overrides: [
            tagRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        // Act: getList()を実行
        final result = await container.read(tagListProvider.notifier).getList();

        // Assert: 正しく状態が更新されているか検証
        expect(result.length, 2);
        expect(result[0].name, 'リポジトリタグ1');
        expect(result[1].name, 'リポジトリタグ2');

        final state = container.read(tagListProvider);
        expect(state.length, 2);
        expect(state[0].name, 'リポジトリタグ1');

        // Repositoryが1回呼ばれたことを確認
        verify(() => mockRepository.fetchTags()).called(1);
      });

      test('add()はRepositoryで新しいタグを作成して状態に追加する', () async {
        // Arrange
        final now = DateTime.now();
        final newTag = Tag(
          id: 3,
          name: '新規タグ',
          description: '新規説明',
          createdAt: now,
          updatedAt: now,
        );
        when(() => mockRepository.createTag('新規タグ', '新規説明'))
            .thenAnswer((_) async => newTag);

        final container = ProviderContainer(
          overrides: [
            tagRepositoryProvider.overrideWithValue(mockRepository),
          ],
        );
        addTearDown(container.dispose);

        // 初期状態を設定
        final existingTag = Tag(
          id: 1,
          name: '既存タグ',
          description: '既存説明',
          createdAt: now,
          updatedAt: now,
        );
        container.read(tagListProvider.notifier).state = [existingTag];

        // Act
        await container.read(tagListProvider.notifier).add('新規タグ', '新規説明');

        // Assert
        final state = container.read(tagListProvider);
        expect(state.length, 2);
        expect(state[0].name, '既存タグ');
        expect(state[1].name, '新規タグ');

        verify(() => mockRepository.createTag('新規タグ', '新規説明')).called(1);
      });
    });
  });
}
