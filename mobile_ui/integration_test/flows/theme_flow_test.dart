import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_ui/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('テーマ変更のE2Eテスト', () {
    testWidgets('テーマを複数回切り替えできる', (tester) async {
      // アプリ起動
      await app.main();
      await tester.pumpAndSettle();

      // Homeタブが表示されていることを確認
      expect(find.text('Home'), findsOneWidget);

      // 設定アイコンをタップして設定画面へ遷移
      final settingsIcon = find.byIcon(Icons.settings);
      expect(settingsIcon, findsOneWidget);
      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();

      // 現在のテーマを確認（初期状態）
      final initialTheme = find.textContaining('Theme:');
      expect(initialTheme, findsOneWidget);
      
      final Text initialText = tester.widget(initialTheme);
      final String? theme1 = initialText.data;
      
      // テーマ切り替えボタンをタップ
      await tester.tap(initialTheme);
      await tester.pumpAndSettle();

      // テーマが変更されたことを確認（異なるテキストになる）
      final changedTheme = find.textContaining('Theme:');
      expect(changedTheme, findsOneWidget);
      
      final Text changedText = tester.widget(changedTheme);
      final String? theme2 = changedText.data;
      
      // 最初と違うテーマになっていることを確認
      expect(theme2, isNot(equals(theme1)));
      
      // もう一度タップ
      await tester.tap(changedTheme);
      await tester.pumpAndSettle();

      // さらにテーマが変更されたことを確認
      final finalTheme = find.textContaining('Theme:');
      expect(finalTheme, findsOneWidget);
      
      final Text finalText = tester.widget(finalTheme);
      final String? theme3 = finalText.data;
      
      // 2回目と違うテーマになっていることを確認
      expect(theme3, isNot(equals(theme2)));
      
      print('✅ テーマ変更フローのテストが成功しました: $theme1 → $theme2 → $theme3');
    });
  });
}
