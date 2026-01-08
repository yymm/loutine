import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/state/theme_mode_state.dart';

class ThemeModeToggle extends ConsumerWidget {
  const ThemeModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toggle = ref.read(themeModeProvider.notifier).toggle;
    return switch (ref.watch(themeModeProvider)) {
      ThemeMode.light => ListTile(
        leading: const Icon(Icons.light_mode_rounded),
        title: const Text('Theme: Light'),
        onTap: toggle,
      ),
      ThemeMode.dark => ListTile(
        leading: const Icon(Icons.dark_mode_rounded),
        title: const Text('Theme: Dark'),
        onTap: toggle,
      ),
      ThemeMode.system => ListTile(
        leading: const Icon(Icons.smartphone_rounded),
        title: const Text('Theme: System'),
        onTap: toggle,
      ),
    };
  }
}
