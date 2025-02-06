import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({ super.key, required this.navigationShell });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (idx) {
          navigationShell.goBranch(
            idx,
            initialLocation: idx == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
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
