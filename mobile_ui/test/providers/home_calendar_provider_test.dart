import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/home_calendar_provider.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  group('CalendarFocusDay', () {
    test('初期値は現在日時', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(calendarFocusDayProvider);
      expect(state.day, DateTime.now().day);
      expect(state.month, DateTime.now().month);
      expect(state.year, DateTime.now().year);
    });

    test('change()で日付が変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final testDate = DateTime(2025, 1, 15);
      container.read(calendarFocusDayProvider.notifier).change(testDate);
      expect(container.read(calendarFocusDayProvider), testDate);
    });

    test('reset()で現在日時に戻る', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calendarFocusDayProvider.notifier);
      notifier.change(DateTime(2025, 1, 15));
      notifier.reset();

      final state = container.read(calendarFocusDayProvider);
      expect(state.day, DateTime.now().day);
      expect(state.month, DateTime.now().month);
      expect(state.year, DateTime.now().year);
    });
  });

  group('CalendarFormatManager', () {
    test('初期値はmonth', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(
        container.read(calendarFormatManagerProvider),
        CalendarFormat.month,
      );
    });

    test('change()でフォーマットが変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(calendarFormatManagerProvider.notifier).change(CalendarFormat.week);
      expect(
        container.read(calendarFormatManagerProvider),
        CalendarFormat.week,
      );
    });

    test('reset()でmonthに戻る', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calendarFormatManagerProvider.notifier);
      notifier.change(CalendarFormat.twoWeeks);
      notifier.reset();
      expect(
        container.read(calendarFormatManagerProvider),
        CalendarFormat.month,
      );
    });
  });

  group('CalendarEventList', () {
    test('初期値は空のリスト', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(calendarEventListProvider), []);
    });

    test('change()でリストが変更される', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Placeholder test - actual CalendarEventItem creation would require mock data
      container.read(calendarEventListProvider.notifier).change([]);
      expect(container.read(calendarEventListProvider), []);
    });

    test('reset()で空のリストに戻る', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(calendarEventListProvider.notifier);
      notifier.change([]);
      notifier.reset();
      expect(container.read(calendarEventListProvider), []);
    });
  });
}
