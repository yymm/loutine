import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/calendar_event_item.dart';
import 'package:mobile_ui/providers/home/home_calendar_provider.dart';

part 'purchase_summary_provider.g.dart';

enum ChartMode { daily, weekly }

/// 選択中の月を管理
@riverpod
class PurchaseSummaryMonth extends _$PurchaseSummaryMonth {
  @override
  DateTime build() => DateTime.now();

  void changeMonth(DateTime newMonth) {
    state = newMonth;
  }

  void nextMonth() {
    state = DateTime(state.year, state.month + 1);
  }

  void previousMonth() {
    state = DateTime(state.year, state.month - 1);
  }
}

/// カテゴリー別の集計データ
class CategorySummary {
  CategorySummary({
    required this.categoryName,
    required this.totalAmount,
    required this.color,
  });

  final String categoryName;
  final int totalAmount;
  final Color color;
}

/// 選択月のPurchaseデータをカテゴリー別に集計
@riverpod
Future<List<CategorySummary>> purchaseCategorySummary(Ref ref) async {
  final selectedMonth = ref.watch(purchaseSummaryMonthProvider);
  final calendarData = await ref.watch(
    calendarEventDataProvider(selectedMonth).future,
  );

  // Purchase typeのイベントのみを抽出
  final purchases = calendarData.values
      .expand((items) => items)
      .where((item) => item.itemType == CalendarEventItemType.purchase)
      .toList();

  if (purchases.isEmpty) {
    return [];
  }

  // カテゴリー別に集計
  final Map<String, int> categoryTotals = {};
  for (final purchase in purchases) {
    final categoryName = purchase.category?.name ?? '未分類';
    final amount = int.tryParse(purchase.data) ?? 0;
    categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0) + amount;
  }

  // CategorySummaryのリストに変換
  final colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  int colorIndex = 0;
  return categoryTotals.entries.map((entry) {
    final color = colors[colorIndex % colors.length];
    colorIndex++;
    return CategorySummary(
      categoryName: entry.key,
      totalAmount: entry.value,
      color: color,
    );
  }).toList();
}

/// 日別・カテゴリー別の集計データ（積み上げ棒グラフ用）
class DailyCategorySummary {
  DailyCategorySummary({required this.day, required this.categoryAmounts});

  final int day;
  final Map<String, int> categoryAmounts; // categoryName -> amount
}

/// 日別の集計データ
class DailySummary {
  DailySummary({required this.day, required this.totalAmount});

  final int day;
  final int totalAmount;
}

/// 選択月のPurchaseデータを日別・カテゴリー別に集計（積み上げ棒グラフ用）
@riverpod
Future<List<DailyCategorySummary>> purchaseDailyCategorySummary(Ref ref) async {
  final selectedMonth = ref.watch(purchaseSummaryMonthProvider);
  final calendarData = await ref.watch(
    calendarEventDataProvider(selectedMonth).future,
  );

  // Purchase typeのイベントのみを抽出
  final purchases = calendarData.values
      .expand((items) => items)
      .where((item) => item.itemType == CalendarEventItemType.purchase)
      .toList();

  if (purchases.isEmpty) {
    return [];
  }

  // 日別・カテゴリー別に集計
  final Map<int, Map<String, int>> dailyCategoryTotals = {};
  for (final purchase in purchases) {
    final day = purchase.createdAt.day;
    final categoryName = purchase.category?.name ?? 'Uncategorized';
    final amount = int.tryParse(purchase.data) ?? 0;

    dailyCategoryTotals[day] ??= {};
    dailyCategoryTotals[day]![categoryName] =
        (dailyCategoryTotals[day]![categoryName] ?? 0) + amount;
  }

  // DailyCategorySummaryのリストに変換してソート
  final summaries =
      dailyCategoryTotals.entries
          .map(
            (entry) => DailyCategorySummary(
              day: entry.key,
              categoryAmounts: entry.value,
            ),
          )
          .toList()
        ..sort((a, b) => a.day.compareTo(b.day));

  return summaries;
}

/// 選択月のPurchaseデータを日別に集計
@riverpod
Future<List<DailySummary>> purchaseDailySummary(Ref ref) async {
  final selectedMonth = ref.watch(purchaseSummaryMonthProvider);
  final calendarData = await ref.watch(
    calendarEventDataProvider(selectedMonth).future,
  );

  // Purchase typeのイベントのみを抽出
  final purchases = calendarData.values
      .expand((items) => items)
      .where((item) => item.itemType == CalendarEventItemType.purchase)
      .toList();

  if (purchases.isEmpty) {
    return [];
  }

  // 日別に集計
  final Map<int, int> dailyTotals = {};
  for (final purchase in purchases) {
    final day = purchase.createdAt.day;
    final amount = int.tryParse(purchase.data) ?? 0;
    dailyTotals[day] = (dailyTotals[day] ?? 0) + amount;
  }

  // DailySummaryのリストに変換してソート
  final summaries =
      dailyTotals.entries
          .map(
            (entry) => DailySummary(day: entry.key, totalAmount: entry.value),
          )
          .toList()
        ..sort((a, b) => a.day.compareTo(b.day));

  return summaries;
}

/// グラフ表示モード（日次/週次）
@riverpod
class PurchaseChartMode extends _$PurchaseChartMode {
  @override
  ChartMode build() => ChartMode.daily;

  void toggle() {
    state = state == ChartMode.daily ? ChartMode.weekly : ChartMode.daily;
  }
}

/// 週別の集計データ
class WeeklySummary {
  WeeklySummary({required this.weekNumber, required this.totalAmount});

  final int weekNumber;
  final int totalAmount;
}

/// 選択月のPurchaseデータを週別に集計
@riverpod
Future<List<WeeklySummary>> purchaseWeeklySummary(Ref ref) async {
  final selectedMonth = ref.watch(purchaseSummaryMonthProvider);
  final calendarData = await ref.watch(
    calendarEventDataProvider(selectedMonth).future,
  );

  // Purchase typeのイベントのみを抽出
  final purchases = calendarData.values
      .expand((items) => items)
      .where((item) => item.itemType == CalendarEventItemType.purchase)
      .toList();

  if (purchases.isEmpty) {
    return [];
  }

  // 週別に集計（週番号 = (日 - 1) / 7 + 1）
  final Map<int, int> weeklyTotals = {};
  for (final purchase in purchases) {
    final weekNumber = ((purchase.createdAt.day - 1) ~/ 7) + 1;
    final amount = int.tryParse(purchase.data) ?? 0;
    weeklyTotals[weekNumber] = (weeklyTotals[weekNumber] ?? 0) + amount;
  }

  // WeeklySummaryのリストに変換してソート
  final summaries =
      weeklyTotals.entries
          .map(
            (entry) =>
                WeeklySummary(weekNumber: entry.key, totalAmount: entry.value),
          )
          .toList()
        ..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));

  return summaries;
}

/// 選択月の合計金額を計算
@riverpod
Future<int> purchaseMonthlyTotal(Ref ref) async {
  final selectedMonth = ref.watch(purchaseSummaryMonthProvider);
  final calendarData = await ref.watch(
    calendarEventDataProvider(selectedMonth).future,
  );

  // Purchase typeのイベントのみを抽出
  final purchases = calendarData.values
      .expand((items) => items)
      .where((item) => item.itemType == CalendarEventItemType.purchase)
      .toList();

  if (purchases.isEmpty) {
    return 0;
  }

  // 合計金額を計算
  return purchases.fold<int>(
    0,
    (sum, purchase) => sum + (int.tryParse(purchase.data) ?? 0),
  );
}
