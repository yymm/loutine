import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/storage.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  static const String storageKeyThemeMode = 'theme_mdoe';

  final _storage = SharedPreferencesInstance().prefs;

  ThemeModeNotifier() : super(ThemeMode.system) {
    state = _loadThemeMode() ?? ThemeMode.system;
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

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => ThemeModeNotifier());
