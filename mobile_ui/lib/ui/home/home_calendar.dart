import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/calendar_event_item.dart';
import 'package:mobile_ui/providers/home_calendar_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeCalendarWidget extends ConsumerWidget {
  HomeCalendarWidget({super.key});
  bool _isInitialized = false;

  void _setCalendarEventList(WidgetRef ref, DateTime focusDay, Map<DateTime, List<CalendarEventItem>> calendarEvents) {
     final today = DateTime(
       focusDay.year,
       focusDay.month,
       focusDay.day,
     );
     ref
         .read(calendarEventListProvider.notifier)
         .change(calendarEvents[today] ?? []);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final focusDay = ref.watch(calendarFocusDayProvider);
    final format = ref.watch(calendarFormatManagerProvider);

    // 月の初日を取得してProviderに渡す
    final focusedMonth = DateTime(focusDay.year, focusDay.month, 1);
    final calendarEventsAsync = ref.watch(
      calendarEventDataProvider(focusedMonth),
    );

    return calendarEventsAsync.when(
      data: (calendarEvents) {
        // 初回のみ今日のイベントを設定
        if (!_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _setCalendarEventList(ref, focusDay, calendarEvents);
          });
          _isInitialized = true;
        }
        return TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2050, 12, 31),
          focusedDay: focusDay,
          calendarFormat: format,
          onFormatChanged: (format) {
            ref.read(calendarFormatManagerProvider.notifier).change(format);
          },
          eventLoader: (date) {
            final localDate = DateTime(date.year, date.month, date.day);
            return calendarEvents[localDate] ?? [];
          },
          selectedDayPredicate: (day) {
            return isSameDay(focusDay, day);
          },
          onDaySelected: (selectedDay, focusDay) {
            ref.read(calendarFocusDayProvider.notifier).change(selectedDay);
            _setCalendarEventList(ref, selectedDay, calendarEvents);
          },
          onPageChanged: (focusedDay) {
            ref.read(calendarFocusDayProvider.notifier).change(focusedDay);
            _setCalendarEventList(ref, focusedDay, calendarEvents);
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;
              int linkCnt = 0;
              int purchaseCnt = 0;
              int noteCnt = 0;
              final _ = events.map((event) {
                if ((event as CalendarEventItem).itemType ==
                    CalendarEventItemType.link) {
                  linkCnt++;
                }
                if (event.itemType == CalendarEventItemType.purchase) {
                  purchaseCnt++;
                }
                if (event.itemType == CalendarEventItemType.note) {
                  noteCnt++;
                }
              }).toList();
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getBadge(linkCnt, Colors.lightBlue),
                  getBadge(purchaseCnt, Colors.orange),
                  getBadge(noteCnt, Colors.lightGreen),
                ],
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('エラーが発生しました: $error')),
    );
  }
}

Widget getBadge(int cnt, Color color) {
  if (cnt == 0) return SizedBox.shrink();
  return Badge.count(count: cnt, backgroundColor: color);
}
