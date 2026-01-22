import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/state/purchase_new_state.dart';

void main() {
  group('PurchaseNewState', () {
    test('初期値はtitle空文字列、cost=0', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(purchaseNewStateProvider);
      expect(state.title, '');
      expect(state.cost, 0);
    });

    test('changeTitle()でタイトルが変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(purchaseNewStateProvider.notifier).changeTitle('テスト購入');
      final state = container.read(purchaseNewStateProvider);
      expect(state.title, 'テスト購入');
      expect(state.cost, 0);
    });

    test('changeCost()でコストが変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(purchaseNewStateProvider.notifier).changeCost(1500.0);
      final state = container.read(purchaseNewStateProvider);
      expect(state.title, '');
      expect(state.cost, 1500.0);
    });

    test('changeTitleとchangeCost両方で値が変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(purchaseNewStateProvider.notifier);
      notifier.changeTitle('ランチ');
      notifier.changeCost(800.0);
      
      final state = container.read(purchaseNewStateProvider);
      expect(state.title, 'ランチ');
      expect(state.cost, 800.0);
    });

    test('reset()で初期値に戻る', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(purchaseNewStateProvider.notifier);
      notifier.changeTitle('テスト');
      notifier.changeCost(1000.0);
      notifier.reset();
      
      final state = container.read(purchaseNewStateProvider);
      expect(state.title, '');
      expect(state.cost, 0);
    });
  });
}
