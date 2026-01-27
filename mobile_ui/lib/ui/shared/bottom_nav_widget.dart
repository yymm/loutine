import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_ui/providers/category_list_provider.dart';
import 'package:mobile_ui/providers/home_calendar_provider.dart';
import 'package:mobile_ui/providers/tag_list_provider.dart';

class BottomNavWidget extends ConsumerWidget {
  const BottomNavWidget({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTabTapped(WidgetRef ref, int index) {
    if (index == 0) {
      // Home tab - refresh calendar data
      ref
          .read(calendarStateManagerProvider.notifier)
          .getAllEventItem(ref.read(calendarFocusDayProvider));
    }
    // Link tab (index == 1) - tags fetched in LinkForm.initState
    // Purchase tab (index == 2) - categories fetched in PurchaseForm.initState
    // Note tab (index == 3) - add initialization if needed

    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (idx) => _onTabTapped(ref, idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.add_link, color: Colors.lightBlue),
            label: 'Link',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_shopping_cart, color: Colors.orange),
            label: 'Purchase',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_add, color: Colors.lightGreen),
            label: 'Note',
          ),
        ],
      ),
    );
  }
}
