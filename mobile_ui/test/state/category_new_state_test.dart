import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/state/category_new_state.dart';

void main() {
  group('CategoryNewName', () {
    test('初期値は空文字列', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(categoryNewNameProvider), '');
    });

    test('change()で値が変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(categoryNewNameProvider.notifier).change('テストカテゴリ');
      expect(container.read(categoryNewNameProvider), 'テストカテゴリ');
    });

    test('reset()で空文字列に戻る', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(categoryNewNameProvider.notifier);
      notifier.change('テストカテゴリ');
      notifier.reset();
      expect(container.read(categoryNewNameProvider), '');
    });
  });

  group('CategoryNewDescription', () {
    test('初期値は空文字列', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(categoryNewDescriptionProvider), '');
    });

    test('change()で値が変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(categoryNewDescriptionProvider.notifier).change('説明文');
      expect(container.read(categoryNewDescriptionProvider), '説明文');
    });

    test('reset()で空文字列に戻る', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(categoryNewDescriptionProvider.notifier);
      notifier.change('説明文');
      notifier.reset();
      expect(container.read(categoryNewDescriptionProvider), '');
    });
  });
}
