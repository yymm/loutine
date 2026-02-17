import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/providers/tag/tag_list_provider.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/repositories/tag_repository.dart';
import 'package:mobile_ui/models/tag.dart';

/// TagRepositoryのモック
/// Providerテストでは、Repositoryをモック化して
/// ビジネスロジック（API処理）を避ける
class MockTagRepository extends Mock implements TagRepository {}

void main() {
  group('TagList', () {
    test('buildでRepositoryからタグ一覧を取得する', () async {
      // Arrange
      final mockRepository = MockTagRepository();
      final now = DateTime.now();
      final mockTags = [
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
      when(() => mockRepository.fetchTags()).thenAnswer((_) async => mockTags);

      final container = ProviderContainer(
        overrides: [tagRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act: Providerを読み込むとbuildが実行される
      final state = await container.read(tagListProvider.future);

      // Assert
      expect(state.length, 2);
      expect(state[0].name, 'タグ1');
      expect(state[1].name, 'タグ2');
      verify(() => mockRepository.fetchTags()).called(1);
    });

    group('Repositoryを使った操作', () {
      late MockTagRepository mockRepository;

      setUp(() {
        mockRepository = MockTagRepository();
      });

      test('add()はRepositoryで新しいタグを作成してinvalidateする', () async {
        // Arrange
        final now = DateTime.now();
        final initialTags = [
          Tag(
            id: 1,
            name: '既存タグ',
            description: '既存説明',
            createdAt: now,
            updatedAt: now,
          ),
        ];
        final newTag = Tag(
          id: 2,
          name: '新規タグ',
          description: '新規説明',
          createdAt: now,
          updatedAt: now,
        );

        // 初回のbuildとinvalidate後の両方をモック
        when(
          () => mockRepository.fetchTags(),
        ).thenAnswer((_) async => initialTags);
        when(
          () => mockRepository.createTag('新規タグ', '新規説明'),
        ).thenAnswer((_) async => newTag);

        final container = ProviderContainer(
          overrides: [tagRepositoryProvider.overrideWithValue(mockRepository)],
        );
        addTearDown(container.dispose);

        // 初期状態を取得
        await container.read(tagListProvider.future);

        // invalidate後は新しいデータを返す
        when(
          () => mockRepository.fetchTags(),
        ).thenAnswer((_) async => [...initialTags, newTag]);

        // Act: タグを追加
        final result = await container
            .read(tagListProvider.notifier)
            .add('新規タグ', '新規説明');

        // Assert
        expect(result.name, '新規タグ');
        verify(() => mockRepository.createTag('新規タグ', '新規説明')).called(1);

        // invalidateSelfが非同期で実行されるので少し待つ
        await Future.delayed(Duration(milliseconds: 100));

        // 再取得されたデータを確認
        final updatedState = await container.read(tagListProvider.future);
        expect(updatedState.length, 2);
        expect(updatedState[1].name, '新規タグ');
      });
    });
  });
}
