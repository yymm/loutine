import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/storage.dart';

part 'theme_mode_state.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const String storageKeyThemeMode = 'theme_mdoe';

  final _storage = SharedPreferencesInstance().prefs;

  @override
  ThemeMode build() {
    return _loadThemeMode() ?? ThemeMode.system;
  }

  Future<void> toggle() async {
    ThemeMode themeMode;
    switch (state) {
      case ThemeMode.light:
        themeMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        themeMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        themeMode = ThemeMode.light;
        break;
    }
    await _saveThemeMode(themeMode).then((value) {
      if (value == true) {
        if (!ref.mounted) return;
        state = themeMode;
      }
    });
  }

  ThemeMode? _loadThemeMode() {
    final loaded = _storage.getString(storageKeyThemeMode);
    if (loaded == null) {
      return null;
    }
    return ThemeMode.values.byName(loaded);
  }

  Future<bool> _saveThemeMode(ThemeMode themeMode) async {
    return _storage.setString(storageKeyThemeMode, themeMode.name);
  }
}
