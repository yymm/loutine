import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_ui/models/calendar_event_item.dart';
import 'package:mobile_ui/providers/home/home_calendar_provider.dart';
import 'package:mobile_ui/providers/purchase/purchase_summary_provider.dart';

class PurchaseCardListWidget extends ConsumerWidget {
  const PurchaseCardListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(purchaseSummaryMonthProvider);
    final calendarDataAsync = ref.watch(
      calendarEventDataProvider(selectedMonth),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Purchase List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            calendarDataAsync.when(
              data: (calendarData) {
                // Purchase typeのイベントのみを抽出して日付降順にソート
                final purchases =
                    calendarData.values
                        .expand((items) => items)
                        .where(
                          (item) =>
                              item.itemType == CalendarEventItemType.purchase,
                        )
                        .toList()
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (purchases.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No data available'),
                    ),
                  );
                }

                return Column(
                  children: purchases.map((purchase) {
                    return _buildPurchaseCard(context, purchase);
                  }).toList(),
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseCard(BuildContext context, CalendarEventItem purchase) {
    final dateFormat = DateFormat('yyyy/MM/dd');
    final amount = int.tryParse(purchase.data) ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: const Icon(Icons.shopping_cart, color: Colors.orange),
        ),
        title: Text(
          purchase.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateFormat.format(purchase.createdAt)),
            if (purchase.category != null)
              Text(
                purchase.category!.name,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
          ],
        ),
        trailing: Text(
          '¥${amount.toString()}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange.shade700,
          ),
        ),
      ),
    );
  }
}
