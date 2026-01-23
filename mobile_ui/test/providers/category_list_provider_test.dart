import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/category_list_provider.dart';
import 'package:mobile_ui/models/category.dart';

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
        Category(id: 1, name: 'カテゴリ1', description: '説明1', createdAt: now, updatedAt: now),
        Category(id: 2, name: 'カテゴリ2', description: '説明2', createdAt: now, updatedAt: now),
      ];
      container.read(categoryListProvider.notifier).state = categories;
      
      final state = container.read(categoryListProvider);
      expect(state.length, 2);
      expect(state[0].name, 'カテゴリ1');
      expect(state[1].name, 'カテゴリ2');
    });
  });
}
