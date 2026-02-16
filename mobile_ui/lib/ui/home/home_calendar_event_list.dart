import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/calendar_event_item.dart';
import 'package:mobile_ui/providers/home_calendar_provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeCalendarEventList extends ConsumerWidget {
  const HomeCalendarEventList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarEventList = ref.watch(calendarEventListProvider);
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    return SingleChildScrollView(
      child: Column(
        children: calendarEventList.map((event) {
          return Card(
            child: ListTile(
              leading: switch (event.itemType) {
                CalendarEventItemType.link => Icon(
                  Icons.link,
                  color: Colors.lightBlue,
                ),
                CalendarEventItemType.purchase => Icon(
                  Icons.shopping_cart,
                  color: Colors.orange,
                ),
                CalendarEventItemType.note => Icon(
                  Icons.note,
                  color: Colors.lightGreen,
                ),
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
                CalendarEventItemType.purchase => Text('${event.title} ¥${event.data}'),
                CalendarEventItemType.note => Text(event.title),
              },
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Created: ${dateFormat.format(event.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
