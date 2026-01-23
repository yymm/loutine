import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/router.dart';
import 'package:mobile_ui/state/category_list_state.dart';
import 'package:mobile_ui/state/home_calendar_state.dart';
import 'package:mobile_ui/state/tag_list_state.dart';
import 'package:mobile_ui/storage.dart';
import 'package:mobile_ui/state/theme_mode_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesInstance.initialize();

  runApp(
    ProviderScope(
      child: const LoutineApp()
    )
  );
}

class LoutineApp extends ConsumerWidget {
  const LoutineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initial load of tags
    ref.read(tagListStateProvider.notifier).getList();
    ref.read(categoryListStateProvider.notifier).getList();
    ref.read(calendarStateManagerProvider.notifier).getAllEventItem(DateTime.now());

    return MaterialApp.router(
      title: 'Loutine App',
      darkTheme: _getThemeData(Brightness.dark),
      theme: _getThemeData(Brightness.light),
      themeMode: ref.watch(themeModeStateProvider),
      routerConfig: router,
    );
  }
}

ThemeData _getThemeData(Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    ),
    // fontFamily: 'NotoSansJP',
  );
}
