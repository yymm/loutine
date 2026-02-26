import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ui/providers/purchase/purchase_summary_provider.dart';

class CategoryPieChartWidget extends ConsumerWidget {
  const CategoryPieChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorySummaryAsync = ref.watch(purchaseCategorySummaryProvider);
    final currencyFormat = NumberFormat('#,###');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            categorySummaryAsync.when(
              data: (summaries) {
                if (summaries.isEmpty) {
                  return const Center(child: Text('No data available'));
                }
                return Column(
                  children: [
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: _createSections(summaries),
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildLegend(summaries, currencyFormat),
                  ],
                );
              },
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SizedBox(
                height: 200,
                child: Center(child: Text('Error: $error')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _createSections(List<CategorySummary> summaries) {
    final total = summaries.fold<int>(0, (sum, item) => sum + item.totalAmount);

    return summaries.map((summary) {
      final percentage = (summary.totalAmount / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: summary.color,
        value: summary.totalAmount.toDouble(),
        title: '$percentage%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(
    List<CategorySummary> summaries,
    NumberFormat currencyFormat,
  ) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: summaries.map((summary) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: summary.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${summary.categoryName} (¥${currencyFormat.format(summary.totalAmount)})',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }
}
