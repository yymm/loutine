import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/purchase/purchase_summary_provider.dart';

class AmountBarChartWidget extends ConsumerWidget {
  const AmountBarChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartMode = ref.watch(purchaseChartModeProvider);
    final dailyCategorySummaryAsync = ref.watch(
      purchaseDailyCategorySummaryProvider,
    );
    final categorySummaryAsync = ref.watch(purchaseCategorySummaryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    chartMode == ChartMode.daily ? 'Daily' : 'Weekly',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<ChartMode>(
                  segments: const [
                    ButtonSegment(
                      value: ChartMode.daily,
                      label: Text('Daily'),
                      icon: Icon(Icons.calendar_today, size: 16),
                    ),
                    ButtonSegment(
                      value: ChartMode.weekly,
                      label: Text('Weekly'),
                      icon: Icon(Icons.view_week, size: 16),
                    ),
                  ],
                  selected: {chartMode},
                  onSelectionChanged: (Set<ChartMode> newSelection) {
                    ref.read(purchaseChartModeProvider.notifier).toggle();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: chartMode == ChartMode.daily
                  ? _buildStackedDailyChart(
                      dailyCategorySummaryAsync,
                      categorySummaryAsync,
                    )
                  : _buildWeeklyChart(ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackedDailyChart(
    AsyncValue<List<DailyCategorySummary>> dailyCategorySummaryAsync,
    AsyncValue<List<CategorySummary>> categorySummaryAsync,
  ) {
    return dailyCategorySummaryAsync.when(
      data: (dailySummaries) {
        if (dailySummaries.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        return categorySummaryAsync.when(
          data: (categories) {
            // カテゴリーと色のマッピングを作成
            final categoryColors = {
              for (var cat in categories) cat.categoryName: cat.color,
            };

            return BarChart(
              BarChartData(
                barGroups: _createStackedBarGroups(
                  dailySummaries,
                  categoryColors,
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '¥${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: true),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildWeeklyChart(WidgetRef ref) {
    final weeklySummaryAsync = ref.watch(purchaseWeeklySummaryProvider);
    return weeklySummaryAsync.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return const Center(child: Text('No data available'));
        }
        return BarChart(
          BarChartData(
            barGroups: _createWeeklyBarGroups(summaries),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 50,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '¥${value.toInt()}',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      'W${value.toInt()}',
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: true),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  List<BarChartGroupData> _createStackedBarGroups(
    List<DailyCategorySummary> summaries,
    Map<String, Color> categoryColors,
  ) {
    return summaries.map((summary) {
      // 各カテゴリーのRodStackItemを作成
      double fromY = 0;
      final rodStackItems = <BarChartRodStackItem>[];

      summary.categoryAmounts.forEach((categoryName, amount) {
        final toY = fromY + amount.toDouble();
        rodStackItems.add(
          BarChartRodStackItem(
            fromY,
            toY,
            categoryColors[categoryName] ?? Colors.grey,
          ),
        );
        fromY = toY;
      });

      return BarChartGroupData(
        x: summary.day,
        barRods: [
          BarChartRodData(
            toY: fromY, // 合計値
            rodStackItems: rodStackItems,
            width: 16,
            borderRadius: BorderRadius.zero,
          ),
        ],
      );
    }).toList();
  }

  List<BarChartGroupData> _createWeeklyBarGroups(
    List<WeeklySummary> summaries,
  ) {
    return summaries.map((summary) {
      return BarChartGroupData(
        x: summary.weekNumber,
        barRods: [
          BarChartRodData(
            toY: summary.totalAmount.toDouble(),
            color: Colors.orange,
            width: 24,
          ),
        ],
      );
    }).toList();
  }
}
