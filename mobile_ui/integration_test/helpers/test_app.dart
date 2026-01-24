import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/router.dart';
import 'package:mobile_ui/storage.dart';

/// テスト用のアプリをセットアップ
Future<Widget> setupTestApp({List<Override> overrides = const []}) async {
  await SharedPreferencesInstance.initialize();

  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(routerConfig: router, theme: ThemeData.light()),
  );
}
