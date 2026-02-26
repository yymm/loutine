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
    final monthFormat = DateFormat('MMMM yyyy'); // 英語フォーマット
    final monthlyTotalAsync = ref.watch(purchaseMonthlyTotalProvider);

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 月の合計金額カード
            monthlyTotalAsync.when(
              data: (total) {
                // 月の初日と最終日を計算
                final startDate = DateTime(
                  selectedMonth.year,
                  selectedMonth.month,
                  1,
                );
                final endDate = DateTime(
                  selectedMonth.year,
                  selectedMonth.month + 1,
                  0,
                );
                final dateFormat = DateFormat('MM/dd');

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Total of Monthly',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dateFormat.format(startDate)} ~ ${dateFormat.format(endDate)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '¥${total.toString()}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $error'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const CategoryPieChartWidget(),
            const SizedBox(height: 16),
            const AmountBarChartWidget(),
            const SizedBox(height: 16),
            const PurchaseCardListWidget(),
          ],
        ),
      ),
    );
  }
}
