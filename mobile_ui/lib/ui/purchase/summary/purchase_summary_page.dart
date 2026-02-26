import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ui/providers/purchase/purchase_summary_provider.dart';
import 'package:mobile_ui/ui/purchase/summary/category_pie_chart_widget.dart';
import 'package:mobile_ui/ui/purchase/summary/amount_bar_chart_widget.dart';
import 'package:mobile_ui/ui/purchase/summary/purchase_card_list_widget.dart';

class PurchaseSummaryPage extends ConsumerWidget {
  const PurchaseSummaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(purchaseSummaryMonthProvider);
    final monthFormat = DateFormat('yyyy年MM月');

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                ref.read(purchaseSummaryMonthProvider.notifier).previousMonth();
              },
            ),
            Text(monthFormat.format(selectedMonth)),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                ref.read(purchaseSummaryMonthProvider.notifier).nextMonth();
              },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CategoryPieChartWidget(),
            SizedBox(height: 16),
            AmountBarChartWidget(),
            SizedBox(height: 16),
            PurchaseCardListWidget(),
          ],
        ),
      ),
    );
  }
}
