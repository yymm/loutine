import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/api/vanilla_api.dart';

part 'purchase_new_state.g.dart';

class PurchaseNew {
  PurchaseNew({
    required this.title,
    required this.cost,
  });

  final String title;
  final double cost;
}

@riverpod
class PurchaseNewState extends _$PurchaseNewState {
  @override
  PurchaseNew build() => PurchaseNew(title: '', cost: 0);

  void changeTitle(String v) {
    state = PurchaseNew(title: v, cost: state.cost);
  }

  void changeCost(double v) {
    state = PurchaseNew(title: state.title, cost: v);
  }

  void reset() {
    state = PurchaseNew(title: '', cost: 0);
  }

  Future<void> add({ categoryId }) async {
    print('press add(): cost => ${state.cost}, title => ${state.title}');
    final apiClient = PurchaseApiClient();
    await apiClient.post(state.cost, state.title, categoryId);
    return;
  }
}
