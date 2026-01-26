import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/repositories/purchase_repository.dart';
import 'package:mobile_ui/exceptions/app_exceptions.dart';

/// PurchaseApiClientのモック
class MockPurchaseApiClient extends Mock implements PurchaseApiClient {}

void main() {
  group('PurchaseRepository', () {
    late PurchaseRepository repository;
    late MockPurchaseApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockPurchaseApiClient();
      repository = PurchaseRepository(mockApiClient);
    });

    group('fetchPurchases', () {
      test('APIから取得したJSONをPurchaseモデルのリストに変換する', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        final jsonResponse = '''
        [
          {
            "id": 1,
            "title": "購入1",
            "cost": 1000,
            "created_at": "2024-01-01T00:00:00Z",
            "updated_at": "2024-01-01T00:00:00Z"
          },
          {
            "id": 2,
            "title": "購入2",
            "cost": 2000,
            "created_at": "2024-01-02T00:00:00Z",
            "updated_at": "2024-01-02T00:00:00Z"
          }
        ]
        ''';

        when(
          () => mockApiClient.list(startDate, endDate),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final purchases = await repository.fetchPurchases(startDate, endDate);

        // Assert
        expect(purchases.length, 2);
        expect(purchases[0].id, 1);
        expect(purchases[0].title, '購入1');
        expect(purchases[0].cost, 1000);
        expect(purchases[1].id, 2);
        expect(purchases[1].title, '購入2');
        expect(purchases[1].cost, 2000);

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
        final purchases = await repository.fetchPurchases(startDate, endDate);

        // Assert
        expect(purchases, isEmpty);
        verify(() => mockApiClient.list(startDate, endDate)).called(1);
      });
    });

    group('createPurchase', () {
      test('新しい購入履歴を作成して返す', () async {
        // Arrange
        const cost = 1500.0;
        const title = '新しい購入';
        const categoryId = 1;
        final jsonResponse = '''
        {
          "id": 3,
          "title": "$title",
          "cost": 1500,
          "created_at": "2024-01-03T00:00:00Z",
          "updated_at": "2024-01-03T00:00:00Z"
        }
        ''';

        when(
          () => mockApiClient.post(cost, title, categoryId),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final purchase = await repository.createPurchase(
          cost,
          title,
          categoryId,
        );

        // Assert
        expect(purchase.id, 3);
        expect(purchase.title, title);
        expect(purchase.cost, 1500);
        verify(() => mockApiClient.post(cost, title, categoryId)).called(1);
      });

      test('カテゴリなしで購入履歴を作成できる', () async {
        // Arrange
        const cost = 2000.0;
        const title = 'カテゴリなし購入';
        final jsonResponse = '''
        {
          "id": 4,
          "title": "$title",
          "cost": 2000,
          "created_at": "2024-01-04T00:00:00Z",
          "updated_at": "2024-01-04T00:00:00Z"
        }
        ''';

        when(
          () => mockApiClient.post(cost, title, null),
        ).thenAnswer((_) async => jsonResponse);

        // Act
        final purchase = await repository.createPurchase(cost, title, null);

        // Assert
        expect(purchase.id, 4);
        expect(purchase.title, title);
        expect(purchase.cost, 2000);
        verify(() => mockApiClient.post(cost, title, null)).called(1);
      });
    });

    group('エラーハンドリング', () {
      test('ネットワークエラー時にNetworkExceptionを投げる', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        when(() => mockApiClient.list(startDate, endDate)).thenThrow(
          const SocketException('Network unreachable'),
        );

        // Act & Assert
        expect(
          () => repository.fetchPurchases(startDate, endDate),
          throwsA(isA<NetworkException>()),
        );
      });

      test('不正なJSON形式の場合にParseExceptionを投げる', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        when(() => mockApiClient.list(startDate, endDate))
            .thenAnswer((_) async => 'invalid json');

        // Act & Assert
        expect(
          () => repository.fetchPurchases(startDate, endDate),
          throwsA(isA<ParseException>()),
        );
      });

      test('JSONの型が期待と異なる場合にParseExceptionを投げる', () async {
        // Arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        when(() => mockApiClient.list(startDate, endDate)).thenAnswer(
          (_) async => '"this should be an array"',
        );

        // Act & Assert
        expect(
          () => repository.fetchPurchases(startDate, endDate),
          throwsA(isA<ParseException>()),
        );
      });
    });
  });
}
