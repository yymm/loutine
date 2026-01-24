import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/tag_list_provider.dart';
import 'package:mobile_ui/models/tag.dart';

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
  });
}
