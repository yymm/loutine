import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/api/vanilla_api.dart';

part 'purchase_new_state.g.dart';

class PurchaseNewData {
  PurchaseNewData({
    required this.title,
    required this.cost,
  });

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

  Future<void> add({ categoryId }) async {
    print('press add(): cost => ${state.cost}, title => ${state.title}');
    final apiClient = PurchaseApiClient();
    await apiClient.post(state.cost, state.title, categoryId);
    return;
  }
}
