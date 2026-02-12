import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/providers/purchase_list_provider.dart';

part 'purchase_new_provider.g.dart';

class PurchaseNewData {
  PurchaseNewData({required this.title, required this.cost});

  final String title;
  final double cost;
}

@riverpod
class PurchaseNew extends _$PurchaseNew {
  @override
  PurchaseNewData build() => PurchaseNewData(title: '', cost: 0);

  void changeTitle(String v) {
    state = PurchaseNewData(title: v, cost: state.cost);
  }

  void changeCost(double v) {
    state = PurchaseNewData(title: state.title, cost: v);
  }

  void reset() {
    state = PurchaseNewData(title: '', cost: 0);
  }

  Future<void> add({categoryId}) async {
    print('press add(): cost => ${state.cost}, title => ${state.title}');
    // PurchaseListProviderのcreateメソッドを使用
    // これにより、PurchaseListProviderが更新され、それを監視している
    // CalendarEventDataも自動的に更新される
    await ref
        .read(purchaseListProvider.notifier)
        .createPurchase(state.cost, state.title, categoryId);
    return;
  }
}
