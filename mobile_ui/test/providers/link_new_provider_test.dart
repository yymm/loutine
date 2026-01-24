import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/link_new_provider.dart';

void main() {
  group('LinkNew', () {
    test('初期値はurl空文字列、title空文字列', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(linkNewProvider);
      expect(state.url, '');
      expect(state.title, '');
    });

    test('changeUrl()でURLが変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(linkNewProvider.notifier).changeUrl('https://example.com');
      final state = container.read(linkNewProvider);
      expect(state.url, 'https://example.com');
      expect(state.title, '');
    });

    test('changeTitle()でタイトルが変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(linkNewProvider.notifier).changeTitle('テストタイトル');
      final state = container.read(linkNewProvider);
      expect(state.url, '');
      expect(state.title, 'テストタイトル');
    });

    test('changeUrlとchangeTitle両方で値が変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(linkNewProvider.notifier);
      notifier.changeUrl('https://flutter.dev');
      notifier.changeTitle('Flutter公式サイト');

      final state = container.read(linkNewProvider);
      expect(state.url, 'https://flutter.dev');
      expect(state.title, 'Flutter公式サイト');
    });

    test('reset()で初期値に戻る', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(linkNewProvider.notifier);
      notifier.changeUrl('https://example.com');
      notifier.changeTitle('テスト');
      notifier.reset();

      final state = container.read(linkNewProvider);
      expect(state.url, '');
      expect(state.title, '');
    });
  });
}
