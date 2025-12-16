import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/api/vanilla_api.dart';

class PurchaseNew {
  PurchaseNew({
    required this.title,
    required this.cost,
  });

  final String title;
  final double cost;
}

class PurchaseNewNotifier extends StateNotifier<PurchaseNew> {
  PurchaseNewNotifier() : super(PurchaseNew(title: '', cost: 0));

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

final purchaseNewProvider
  = StateNotifierProvider<PurchaseNewNotifier, PurchaseNew>((ref) => PurchaseNewNotifier());
