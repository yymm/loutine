import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/tag/tag_new_provider.dart';

void main() {
  group('TagNewName', () {
    test('初期値は空文字列', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(tagNewNameProvider), '');
    });

    test('change()で値が変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(tagNewNameProvider.notifier).change('テストタグ');
      expect(container.read(tagNewNameProvider), 'テストタグ');
    });

    test('reset()で空文字列に戻る', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tagNewNameProvider.notifier);
      notifier.change('テストタグ');
      notifier.reset();
      expect(container.read(tagNewNameProvider), '');
    });
  });

  group('TagNewDescription', () {
    test('初期値は空文字列', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(tagNewDescriptionProvider), '');
    });

    test('change()で値が変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(tagNewDescriptionProvider.notifier).change('説明文');
      expect(container.read(tagNewDescriptionProvider), '説明文');
    });

    test('reset()で空文字列に戻る', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(tagNewDescriptionProvider.notifier);
      notifier.change('説明文');
      notifier.reset();
      expect(container.read(tagNewDescriptionProvider), '');
    });
  });
}
