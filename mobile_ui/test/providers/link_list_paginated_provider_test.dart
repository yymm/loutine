import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/providers/link_list_paginated_provider.dart';
import 'package:mobile_ui/providers/link_list_provider.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/repositories/link_repository.dart';
import 'package:mobile_ui/models/link.dart';
import 'package:mobile_ui/models/paginated_result.dart';

/// LinkRepositoryのモック
class MockLinkRepository extends Mock implements LinkRepository {}

void main() {
  group('LinkListPaginated', () {
    late MockLinkRepository mockRepository;

    setUp(() {
      mockRepository = MockLinkRepository();
    });

    test('初期値はRepositoryから取得したページネーション結果', () async {
      // Arrange
      final now = DateTime.now();
      final mockLinks = [
        Link(
          id: 1,
          title: 'リンク1',
          url: 'https://example.com/1',
          createdAt: now,
          updatedAt: now,
        ),
        Link(
          id: 2,
          title: 'リンク2',
          url: 'https://example.com/2',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final paginatedResult = PaginatedResult(
        items: mockLinks,
        nextCursor: 'cursor1',
        hasMore: true,
      );

      when(
        () => mockRepository.fetchLinksPaginated(cursor: null, limit: 20),
      ).thenAnswer((_) async => paginatedResult);

      final container = ProviderContainer(
        overrides: [linkRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      final state = await container.read(linkListPaginatedProvider.future);

      // Assert
      expect(state.items.length, 2);
      expect(state.items[0].id, 1);
      expect(state.items[1].id, 2);
      expect(state.nextCursor, 'cursor1');
      expect(state.hasMore, true);
      expect(state.isLoadingMore, false);
      verify(() => mockRepository.fetchLinksPaginated(cursor: null, limit: 20)).called(1);
    });

    test('loadMore()で次のページを読み込む', () async {
      // Arrange
      final now = DateTime.now();
      final firstPageLinks = [
        Link(id: 1, title: 'リンク1', url: 'https://example.com/1', createdAt: now, updatedAt: now),
        Link(id: 2, title: 'リンク2', url: 'https://example.com/2', createdAt: now, updatedAt: now),
      ];
      final secondPageLinks = [
        Link(id: 3, title: 'リンク3', url: 'https://example.com/3', createdAt: now, updatedAt: now),
      ];

      when(
        () => mockRepository.fetchLinksPaginated(cursor: null, limit: 20),
      ).thenAnswer((_) async => PaginatedResult(
        items: firstPageLinks,
        nextCursor: 'cursor1',
        hasMore: true,
      ));

      when(
        () => mockRepository.fetchLinksPaginated(cursor: 'cursor1', limit: 20),
      ).thenAnswer((_) async => PaginatedResult(
        items: secondPageLinks,
        nextCursor: 'cursor2',
        hasMore: true,
      ));

      final container = ProviderContainer(
        overrides: [linkRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // 初回ロード
      await container.read(linkListPaginatedProvider.future);

      // Act
      await container.read(linkListPaginatedProvider.notifier).loadMore();

      // Assert
      final state = container.read(linkListPaginatedProvider).value!;
      expect(state.items.length, 3);
      expect(state.items[0].id, 1);
      expect(state.items[1].id, 2);
      expect(state.items[2].id, 3);
      expect(state.nextCursor, 'cursor2');
      expect(state.hasMore, true);
    });

    test('hasMoreがfalseの場合はloadMore()が何もしない', () async {
      // Arrange
      final now = DateTime.now();
      final mockLinks = [
        Link(id: 1, title: 'リンク1', url: 'https://example.com/1', createdAt: now, updatedAt: now),
      ];

      when(
        () => mockRepository.fetchLinksPaginated(cursor: null, limit: 20),
      ).thenAnswer((_) async => PaginatedResult(
        items: mockLinks,
        nextCursor: null,
        hasMore: false,
      ));

      final container = ProviderContainer(
        overrides: [linkRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      await container.read(linkListPaginatedProvider.future);

      // Act
      await container.read(linkListPaginatedProvider.notifier).loadMore();

      // Assert
      // fetchLinksPaginatedは初回のみ呼ばれる（loadMoreでは呼ばれない）
      verify(() => mockRepository.fetchLinksPaginated(cursor: null, limit: 20)).called(1);
      verifyNever(() => mockRepository.fetchLinksPaginated(cursor: any(named: 'cursor'), limit: 20));
    });

    test('refresh()でリストを再取得する', () async {
      // Arrange
      final now = DateTime.now();
      final initialLinks = [
        Link(id: 1, title: 'リンク1', url: 'https://example.com/1', createdAt: now, updatedAt: now),
      ];
      final refreshedLinks = [
        Link(id: 2, title: '新しいリンク', url: 'https://example.com/2', createdAt: now, updatedAt: now),
        Link(id: 1, title: 'リンク1', url: 'https://example.com/1', createdAt: now, updatedAt: now),
      ];

      when(
        () => mockRepository.fetchLinksPaginated(cursor: null, limit: 20),
      ).thenAnswer((_) async => PaginatedResult(
        items: initialLinks,
        nextCursor: 'cursor1',
        hasMore: true,
      ));

      final container = ProviderContainer(
        overrides: [linkRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      await container.read(linkListPaginatedProvider.future);

      // リフレッシュ時は新しいデータを返す
      when(
        () => mockRepository.fetchLinksPaginated(cursor: null, limit: 20),
      ).thenAnswer((_) async => PaginatedResult(
        items: refreshedLinks,
        nextCursor: 'cursor2',
        hasMore: true,
      ));

      // Act
      await container.read(linkListPaginatedProvider.notifier).refresh();

      // Assert
      final state = container.read(linkListPaginatedProvider).value!;
      expect(state.items.length, 2);
      expect(state.items[0].id, 2);
      expect(state.items[0].title, '新しいリンク');
    });

    test('createLink()でリンクを作成し楽観的更新する', () async {
      // Arrange
      final now = DateTime.now();
      final existingLinks = [
        Link(id: 1, title: 'リンク1', url: 'https://example.com/1', createdAt: now, updatedAt: now),
      ];
      final newLink = Link(
        id: 2,
        title: '新しいリンク',
        url: 'https://example.com/new',
        createdAt: now,
        updatedAt: now,
      );

      when(
        () => mockRepository.fetchLinksPaginated(cursor: null, limit: 20),
      ).thenAnswer((_) async => PaginatedResult(
        items: existingLinks,
        nextCursor: 'cursor1',
        hasMore: false,
      ));

      when(
        () => mockRepository.createLink('https://example.com/new', '新しいリンク', [1]),
      ).thenAnswer((_) async => newLink);

      final container = ProviderContainer(
        overrides: [linkRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      await container.read(linkListPaginatedProvider.future);

      // Act
      await container.read(linkListPaginatedProvider.notifier).createLink(
        'https://example.com/new',
        '新しいリンク',
        [1],
      );

      // Assert
      final state = container.read(linkListPaginatedProvider).value!;
      expect(state.items.length, 2);
      expect(state.items[0].id, 2); // 新しいリンクが先頭に追加される
      expect(state.items[0].title, '新しいリンク');
      expect(state.items[1].id, 1);

      // LinkListProviderもinvalidateされる
      // (実際の動作確認は統合テストで行う)
    });
  });
}
