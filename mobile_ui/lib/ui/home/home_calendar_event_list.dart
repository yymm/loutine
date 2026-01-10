import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/calendar_event_item.dart';
import 'package:mobile_ui/state/home_calendar_state.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeCalendarEventList extends ConsumerWidget {
  const HomeCalendarEventList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarEventList = ref.watch(calendarEventListProvider);
    return SingleChildScrollView(
      child: Column(
        children: calendarEventList.map((event) {
          return Card(
            child: ListTile(
              leading: switch (event.itemType) {
                CalendarEventItemType.link => Icon(Icons.link, color: Colors.lightBlue),
                CalendarEventItemType.purchase => Icon(Icons.shopping_cart, color: Colors.orange),
                CalendarEventItemType.note => Icon(Icons.note, color: Colors.lightGreen),
              },
              title: switch (event.itemType) {
                CalendarEventItemType.link => GestureDetector(
                  onTap: () => launchUrlString(event.data),
                  child: Text(
                    event.title,
                    style: TextStyle(color: Colors.teal),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CalendarEventItemType.purchase => Text('¥ ${event.data}'),
                CalendarEventItemType.note => Text(event.title),
              },
              // subtitle: switch (event.itemType) {
              //   CalendarEventItemType.link => SizedBox.shrink(),
              //   CalendarEventItemType.purchase => SizedBox.shrink(),
              //   CalendarEventItemType.note => SizedBox.shrink(),
              // },
            ),
          );
        }).toList(),
      ),
    );
  }
}
