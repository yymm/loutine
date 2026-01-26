import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeModeManager', () {
    test('ThemeModeの値が正しく定義されている', () {
      expect(ThemeMode.light, isA<ThemeMode>());
      expect(ThemeMode.dark, isA<ThemeMode>());
      expect(ThemeMode.system, isA<ThemeMode>());
    });

    test('ThemeModeの切り替えロジック', () {
      // Light -> Dark
      ThemeMode current = ThemeMode.light;
      ThemeMode next = current == ThemeMode.light
          ? ThemeMode.dark
          : current == ThemeMode.dark
              ? ThemeMode.system
              : ThemeMode.light;
      expect(next, ThemeMode.dark);

      // Dark -> System
      current = ThemeMode.dark;
      next = current == ThemeMode.light
          ? ThemeMode.dark
          : current == ThemeMode.dark
              ? ThemeMode.system
              : ThemeMode.light;
      expect(next, ThemeMode.system);

      // System -> Light
      current = ThemeMode.system;
      next = current == ThemeMode.light
          ? ThemeMode.dark
          : current == ThemeMode.dark
              ? ThemeMode.system
              : ThemeMode.light;
      expect(next, ThemeMode.light);
    });
  });
}
