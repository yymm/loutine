import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_ui/providers/home_calendar_provider.dart';

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
    // Add other tab initialization logic here if needed
    // if (index == 1) { /* Link tab */ }
    // if (index == 2) { /* Purchase tab */ }
    // if (index == 3) { /* Note tab */ }

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
