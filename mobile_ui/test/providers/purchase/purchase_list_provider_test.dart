import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/providers/purchase/purchase_list_provider.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/repositories/purchase_repository.dart';
import 'package:mobile_ui/models/purchase.dart';

class MockPurchaseRepository extends Mock implements PurchaseRepository {}

void main() {
  group('PurchaseList', () {
    late MockPurchaseRepository mockRepository;

    setUp(() {
      mockRepository = MockPurchaseRepository();
    });

    test('初期値はRepositoryから取得した購入履歴一覧', () async {
      // Arrange
      final now = DateTime.now();
      final mockPurchases = [
        Purchase(
          id: 1,
          cost: 1000,
          title: '購入1',
          createdAt: now,
          updatedAt: now,
        ),
        Purchase(
          id: 2,
          cost: 2000,
          title: '購入2',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      when(
        () => mockRepository.fetchPurchases(any(), any()),
      ).thenAnswer((_) async => mockPurchases);

      final container = ProviderContainer(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final purchaseList = await container.read(purchaseListProvider.future);

      // Assert
      expect(purchaseList.length, 2);
      expect(purchaseList[0].title, '購入1');
      expect(purchaseList[0].cost, 1000);
      expect(purchaseList[1].title, '購入2');
      expect(purchaseList[1].cost, 2000);
    });

    test('空のリストを正しく処理できる', () async {
      // Arrange
      when(
        () => mockRepository.fetchPurchases(any(), any()),
      ).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final purchaseList = await container.read(purchaseListProvider.future);

      // Assert
      expect(purchaseList, isEmpty);
    });

    test('createPurchase()は新しい購入履歴を作成して状態を更新する', () async {
      // Arrange
      final now = DateTime.now();
      final newPurchase = Purchase(
        id: 1,
        cost: 3000,
        title: '新規購入',
        createdAt: now,
        updatedAt: now,
      );

      when(
        () => mockRepository.createPurchase(3000, '新規購入', null),
      ).thenAnswer((_) async => newPurchase);

      when(
        () => mockRepository.fetchPurchases(any(), any()),
      ).thenAnswer((_) async => [newPurchase]);

      final container = ProviderContainer(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container
          .read(purchaseListProvider.notifier)
          .createPurchase(3000, '新規購入', null);

      // Assert
      expect(result.id, 1);
      expect(result.title, '新規購入');
      expect(result.cost, 3000);

      verify(() => mockRepository.createPurchase(3000, '新規購入', null)).called(1);

      await Future.delayed(const Duration(milliseconds: 100));
      verify(
        () => mockRepository.fetchPurchases(any(), any()),
      ).called(greaterThanOrEqualTo(1));
    });

    test('カテゴリ付きで購入履歴を作成できる', () async {
      // Arrange
      final now = DateTime.now();
      final newPurchase = Purchase(
        id: 2,
        cost: 5000,
        title: 'カテゴリ付き',
        createdAt: now,
        updatedAt: now,
      );

      when(
        () => mockRepository.createPurchase(5000, 'カテゴリ付き', 1),
      ).thenAnswer((_) async => newPurchase);

      when(
        () => mockRepository.fetchPurchases(any(), any()),
      ).thenAnswer((_) async => [newPurchase]);

      final container = ProviderContainer(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container
          .read(purchaseListProvider.notifier)
          .createPurchase(5000, 'カテゴリ付き', 1);

      // Assert
      expect(result.id, 2);
    });

    test('deletePurchase()は購入履歴を削除して状態を更新する', () async {
      // Arrange
      final now = DateTime.now();
      final deletedPurchase = Purchase(
        id: 1,
        cost: 1000,
        title: '削除対象',
        createdAt: now,
        updatedAt: now,
      );

      when(
        () => mockRepository.deletePurchase(1),
      ).thenAnswer((_) async => deletedPurchase);

      when(
        () => mockRepository.fetchPurchases(any(), any()),
      ).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [
          purchaseRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      // Act
      final result = await container
          .read(purchaseListProvider.notifier)
          .deletePurchase(1);

      // Assert
      expect(result.id, 1);
      verify(() => mockRepository.deletePurchase(1)).called(1);

      await Future.delayed(const Duration(milliseconds: 100));
      verify(
        () => mockRepository.fetchPurchases(any(), any()),
      ).called(greaterThanOrEqualTo(1));
    });
  });
}
