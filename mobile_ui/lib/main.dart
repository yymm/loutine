import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:mobile_ui/router.dart';
import 'package:mobile_ui/storage.dart';
import 'package:mobile_ui/providers/theme_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesInstance.initialize();

  runApp(ProviderScope(child: const LoutineApp()));
}

class LoutineApp extends ConsumerWidget {
  const LoutineApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Loutine App',
      darkTheme: _getThemeData(Brightness.dark),
      theme: _getThemeData(Brightness.light),
      themeMode: ref.watch(themeModeManagerProvider),
      routerConfig: router,
      localizationsDelegates: const [FlutterQuillLocalizations.delegate],
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
