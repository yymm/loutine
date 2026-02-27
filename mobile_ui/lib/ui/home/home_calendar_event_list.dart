import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/models/calendar_event_item.dart';
import 'package:mobile_ui/providers/home/home_calendar_provider.dart';
import 'package:mobile_ui/providers/link/link_list_paginated_provider.dart';
import 'package:mobile_ui/providers/note/note_list_paginated_provider.dart';
import 'package:mobile_ui/providers/purchase/purchase_list_provider.dart';
import 'package:mobile_ui/ui/shared/delete_confirm_dialog.dart';
import 'package:mobile_ui/ui/shared/tag_chips.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomeCalendarEventList extends ConsumerWidget {
  const HomeCalendarEventList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarEventList = ref.watch(calendarEventListProvider);
    final dateFormat = DateFormat('yyyy/MM/dd HH:mm');
    final currencyFormat = NumberFormat('#,###');
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
                  Icons.insert_drive_file,
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
                CalendarEventItemType.purchase => Row(
                  children: [
                    Expanded(
                      child: Text(event.title, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '¥${currencyFormat.format(int.tryParse(event.data) ?? 0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                CalendarEventItemType.note => Text(event.title),
              },
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  if (event.itemType == CalendarEventItemType.purchase &&
                      event.category != null)
                    Text(
                      'Category: ${event.category!.name}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  if ((event.itemType == CalendarEventItemType.link ||
                          event.itemType == CalendarEventItemType.note) &&
                      event.tagIds.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    TagChips(tagIds: event.tagIds),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    'Created: ${dateFormat.format(event.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.backspace),
                color: Colors.black45,
                onPressed: () async {
                  final itemType = switch (event.itemType) {
                    CalendarEventItemType.link => DeleteItemType.link,
                    CalendarEventItemType.purchase => DeleteItemType.purchase,
                    CalendarEventItemType.note => DeleteItemType.note,
                  };

                  final confirm = await showDeleteConfirmDialog(
                    context,
                    title: event.title,
                    itemType: itemType,
                  );
                  if (confirm == true) {
                    final _ = switch (event.itemType) {
                      CalendarEventItemType.link =>
                        ref
                            .read(linkListPaginatedProvider.notifier)
                            .deleteLink(int.parse(event.id)),
                      CalendarEventItemType.purchase =>
                        ref
                            .read(purchaseListProvider.notifier)
                            .deletePurchase(int.parse(event.id)),
                      CalendarEventItemType.note =>
                        ref
                            .read(noteListPaginatedProvider.notifier)
                            .deleteNote(int.parse(event.id)),
                    };
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
