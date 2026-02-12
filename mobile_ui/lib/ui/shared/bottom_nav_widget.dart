import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BottomNavWidget extends ConsumerWidget {
  const BottomNavWidget({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTabTapped(WidgetRef ref, int index) {
    // buildパターンでは自動的にデータが取得されるため、手動更新は不要
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
