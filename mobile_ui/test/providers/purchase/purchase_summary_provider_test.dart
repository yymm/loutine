import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/purchase/purchase_summary_provider.dart';

void main() {
  group('PurchaseSummaryMonth', () {
    test('初期値は現在日時', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(purchaseSummaryMonthProvider);
      expect(state.day, DateTime.now().day);
      expect(state.month, DateTime.now().month);
      expect(state.year, DateTime.now().year);
    });

    test('nextMonth()で次月に移動', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(purchaseSummaryMonthProvider.notifier);
      notifier.changeMonth(DateTime(2025, 1, 15));

      notifier.nextMonth();
      final state = container.read(purchaseSummaryMonthProvider);
      expect(state.year, 2025);
      expect(state.month, 2);
    });

    test('previousMonth()で前月に移動', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(purchaseSummaryMonthProvider.notifier);
      notifier.changeMonth(DateTime(2025, 2, 15));

      notifier.previousMonth();
      final state = container.read(purchaseSummaryMonthProvider);
      expect(state.year, 2025);
      expect(state.month, 1);
    });

    test('changeMonth()で任意の月に変更', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final testDate = DateTime(2025, 6, 15);
      container
          .read(purchaseSummaryMonthProvider.notifier)
          .changeMonth(testDate);
      expect(container.read(purchaseSummaryMonthProvider), testDate);
    });

    test('年をまたぐ次月への移動', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(purchaseSummaryMonthProvider.notifier);
      notifier.changeMonth(DateTime(2025, 12, 15));

      notifier.nextMonth();
      final state = container.read(purchaseSummaryMonthProvider);
      expect(state.year, 2026);
      expect(state.month, 1);
    });

    test('年をまたぐ前月への移動', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(purchaseSummaryMonthProvider.notifier);
      notifier.changeMonth(DateTime(2026, 1, 15));

      notifier.previousMonth();
      final state = container.read(purchaseSummaryMonthProvider);
      expect(state.year, 2025);
      expect(state.month, 12);
    });
  });

  group('PurchaseChartMode', () {
    test('初期値はdaily', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(purchaseChartModeProvider), ChartMode.daily);
    });

    test('toggle()で日次から週次に切り替わる', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(purchaseChartModeProvider.notifier).toggle();
      expect(container.read(purchaseChartModeProvider), ChartMode.weekly);
    });

    test('toggle()で週次から日次に切り替わる', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(purchaseChartModeProvider.notifier);
      notifier.toggle(); // daily -> weekly
      notifier.toggle(); // weekly -> daily
      expect(container.read(purchaseChartModeProvider), ChartMode.daily);
    });
  });

  group('CategorySummary', () {
    test('正しく生成される', () {
      final summary = CategorySummary(
        categoryName: 'テスト',
        totalAmount: 1000,
        color: const Color(0xFF000000),
      );

      expect(summary.categoryName, 'テスト');
      expect(summary.totalAmount, 1000);
      expect(summary.color, const Color(0xFF000000));
    });
  });

  group('DailySummary', () {
    test('正しく生成される', () {
      final summary = DailySummary(day: 15, totalAmount: 2000);

      expect(summary.day, 15);
      expect(summary.totalAmount, 2000);
    });
  });

  group('WeeklySummary', () {
    test('正しく生成される', () {
      final summary = WeeklySummary(weekNumber: 3, totalAmount: 3000);

      expect(summary.weekNumber, 3);
      expect(summary.totalAmount, 3000);
    });

    test('週番号の計算ロジック検証 (1-7日=第1週)', () {
      // 1日から7日までは第1週
      for (int day = 1; day <= 7; day++) {
        final weekNumber = ((day - 1) ~/ 7) + 1;
        expect(weekNumber, 1, reason: '${day}日は第1週であるべき');
      }
    });

    test('週番号の計算ロジック検証 (8-14日=第2週)', () {
      // 8日から14日までは第2週
      for (int day = 8; day <= 14; day++) {
        final weekNumber = ((day - 1) ~/ 7) + 1;
        expect(weekNumber, 2, reason: '${day}日は第2週であるべき');
      }
    });

    test('週番号の計算ロジック検証 (15-21日=第3週)', () {
      // 15日から21日までは第3週
      for (int day = 15; day <= 21; day++) {
        final weekNumber = ((day - 1) ~/ 7) + 1;
        expect(weekNumber, 3, reason: '${day}日は第3週であるべき');
      }
    });

    test('週番号の計算ロジック検証 (22-28日=第4週)', () {
      // 22日から28日までは第4週
      for (int day = 22; day <= 28; day++) {
        final weekNumber = ((day - 1) ~/ 7) + 1;
        expect(weekNumber, 4, reason: '${day}日は第4週であるべき');
      }
    });

    test('週番号の計算ロジック検証 (29-31日=第5週)', () {
      // 29日から31日までは第5週
      for (int day = 29; day <= 31; day++) {
        final weekNumber = ((day - 1) ~/ 7) + 1;
        expect(weekNumber, 5, reason: '${day}日は第5週であるべき');
      }
    });
  });
}
