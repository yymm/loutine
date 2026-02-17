import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/providers/link_list_provider.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/repositories/link_repository.dart';
import 'package:mobile_ui/models/link.dart';

class MockLinkRepository extends Mock implements LinkRepository {}

void main() {
  group('LinkList', () {
    late MockLinkRepository mockRepository;

    setUp(() {
      mockRepository = MockLinkRepository();
    });

    test('初期値はRepositoryから取得したリンク一覧', () async {
      // Arrange
      final now = DateTime.now();
      final mockLinks = [
        Link(
          id: 1,
          url: 'https://example.com/1',
          title: 'リンク1',
          createdAt: now,
          updatedAt: now,
        ),
        Link(
          id: 2,
          url: 'https://example.com/2',
          title: 'リンク2',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(
        () => mockRepository.fetchLinks(any(), any()),
      ).thenAnswer((_) async => mockLinks);

      final container = ProviderContainer(
        overrides: [linkRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      final linkList = await container.read(linkListProvider.future);

      // Assert
      expect(linkList.length, 2);
      expect(linkList[0].url, 'https://example.com/1');
      expect(linkList[1].url, 'https://example.com/2');
    });

    test('空のリストを正しく処理できる', () async {
      // Arrange
      when(
        () => mockRepository.fetchLinks(any(), any()),
      ).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [linkRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      final linkList = await container.read(linkListProvider.future);

      // Assert
      expect(linkList, isEmpty);
    });

    test('365日前から365日後の範囲でリンクを取得する', () async {
      // Arrange
      when(
        () => mockRepository.fetchLinks(any(), any()),
      ).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [linkRepositoryProvider.overrideWithValue(mockRepository)],
      );
      addTearDown(container.dispose);

      // Act
      await container.read(linkListProvider.future);

      // Assert
      final captured = verify(
        () => mockRepository.fetchLinks(captureAny(), captureAny()),
      ).captured;

      final startDate = captured[0] as DateTime;
      final endDate = captured[1] as DateTime;
      final now = DateTime.now();

      expect(
        startDate.difference(now.subtract(const Duration(days: 365))).inDays,
        0,
      );
      expect(endDate.difference(now.add(const Duration(days: 365))).inDays, 0);
    });
  });
}
