import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/purchase/purchase_summary_provider.dart';

class AmountBarChartWidget extends ConsumerWidget {
  const AmountBarChartWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chartMode = ref.watch(purchaseChartModeProvider);
    final dailySummaryAsync = ref.watch(purchaseDailySummaryProvider);
    final weeklySummaryAsync = ref.watch(purchaseWeeklySummaryProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  chartMode == ChartMode.daily ? '日別支出' : '週別支出',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SegmentedButton<ChartMode>(
                  segments: const [
                    ButtonSegment(
                      value: ChartMode.daily,
                      label: Text('日次'),
                      icon: Icon(Icons.calendar_today, size: 16),
                    ),
                    ButtonSegment(
                      value: ChartMode.weekly,
                      label: Text('週次'),
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
                  ? _buildDailyChart(dailySummaryAsync)
                  : _buildWeeklyChart(weeklySummaryAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChart(AsyncValue<List<DailySummary>> dailySummaryAsync) {
    return dailySummaryAsync.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return const Center(child: Text('データがありません'));
        }
        return BarChart(
          BarChartData(
            barGroups: _createDailyBarGroups(summaries),
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
                      '${value.toInt()}日',
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
      error: (error, stack) => Center(child: Text('エラー: $error')),
    );
  }

  Widget _buildWeeklyChart(AsyncValue<List<WeeklySummary>> weeklySummaryAsync) {
    return weeklySummaryAsync.when(
      data: (summaries) {
        if (summaries.isEmpty) {
          return const Center(child: Text('データがありません'));
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
                      '第${value.toInt()}週',
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
      error: (error, stack) => Center(child: Text('エラー: $error')),
    );
  }

  List<BarChartGroupData> _createDailyBarGroups(List<DailySummary> summaries) {
    return summaries.map((summary) {
      return BarChartGroupData(
        x: summary.day,
        barRods: [
          BarChartRodData(
            toY: summary.totalAmount.toDouble(),
            color: Colors.blue,
            width: 16,
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
            color: Colors.green,
            width: 24,
          ),
        ],
      );
    }).toList();
  }
}
