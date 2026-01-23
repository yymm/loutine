import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/state/theme_mode_state.dart';

class AppDividerWidget extends ConsumerWidget{
  const AppDividerWidget({ super.key });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeManagerProvider);
    final color = switch (themeMode) {
      ThemeMode.system => Colors.black12,
      ThemeMode.light => Colors.black12,
      ThemeMode.dark => Colors.white12,
    };
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Divider(thickness: 1, color: color)),
            Icon(Icons.code, color: color),
            Expanded(child: Divider(thickness: 1, color: color)),
          ],
        ),
        SizedBox(height: 20),
      ]
    );
  }
}
