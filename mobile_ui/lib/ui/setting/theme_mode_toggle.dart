import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/state/theme_mode_state.dart';

class ThemeModeToggle extends ConsumerWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (ref.watch(themeModeStateProvider)) {
      case ThemeMode.light:
        return ListTile(
          leading: const Icon(Icons.light_mode_rounded),
          title: const Text('Theme: Light'),
          onTap: () => ref.read(themeModeStateProvider.notifier).toggle(),
        );
      case ThemeMode.dark:
        return ListTile(
          leading: const Icon(Icons.dark_mode_rounded),
          title: const Text('Theme: Dark'),
          onTap: () => ref.read(themeModeStateProvider.notifier).toggle(),
        );
      case ThemeMode.system:
        return ListTile(
          leading: const Icon(Icons.smartphone_rounded),
          title: const Text('Theme: System'),
          onTap: () => ref.read(themeModeStateProvider.notifier).toggle(),
        );
    }
  }
}
