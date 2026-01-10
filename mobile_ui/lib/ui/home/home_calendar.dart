import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/calendar_event_item.dart';
import 'package:mobile_ui/state/home_calendar_state.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeCalendarWidget extends ConsumerWidget {
  const HomeCalendarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusDay = ref.watch(calendarFocusDayProvider);
    final focusDayNotifier = ref.read<CalendarFocusDayNotifier>(calendarFocusDayProvider.notifier);
    final format = ref.watch(calendarFormatProvider);
    final formatNotifier = ref.read(calendarFormatProvider.notifier);

    final calendarState = ref.watch(calendarStateProvider);
    final calendarStateNotifier = ref.read(calendarStateProvider.notifier);

    final calendarEventListNotifier = ref.read<CalendarEventListNotifier>(calendarEventListProvider.notifier);

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2050, 12, 31),
      focusedDay: focusDay,
      calendarFormat: format,
      onFormatChanged: (format) {
        formatNotifier.change(format);
      },
      eventLoader: (date) {
        return calendarState.calendarEvents[date] ?? [];
      },
      selectedDayPredicate: (day) {
        return isSameDay(focusDay, day);
      },
      onDaySelected: (selectedDay, focusDay) {
        focusDayNotifier.change(selectedDay);
        calendarEventListNotifier.change(calendarState.calendarEvents[selectedDay] ?? []);
      },
      onPageChanged: (focusedDay) {
        focusDayNotifier.change(focusedDay);
        calendarStateNotifier.getAllEventItem(focusedDay);
        calendarState.calendarEvents[focusedDay] ?? [];
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return null;
          int linkCnt = 0;
          int purchaseCnt = 0;
          int noteCnt = 0;
          final _ = events.map((event) {
            if ((event as CalendarEventItem).itemType == CalendarEventItemType.link) linkCnt++;
            if (event.itemType == CalendarEventItemType.purchase) purchaseCnt++;
            if (event.itemType == CalendarEventItemType.note) noteCnt++;
          }).toList();
          return Row(mainAxisAlignment: MainAxisAlignment.center, children: [getBadge(linkCnt, Colors.lightBlue), getBadge(purchaseCnt, Colors.orange), getBadge(noteCnt, Colors.lightGreen)]);
        },
      ),
    );
  }
}

Widget getBadge(int cnt, Color color) {
  // if (cnt == 0) return SizedBox(width: 0, height: 0);
  if (cnt == 0) return SizedBox.shrink();
  return Badge.count(count: cnt, backgroundColor: color);
}
