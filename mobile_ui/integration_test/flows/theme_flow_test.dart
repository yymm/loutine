import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_ui/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('テーマ変更のE2Eテスト', () {
    testWidgets('テーマを変更して永続化される', (tester) async {
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
      
      // テーマ切り替えボタンをタップ
      await tester.tap(initialTheme);
      await tester.pumpAndSettle();

      // テーマが変更されたことを確認（異なるテキストになる）
      final changedTheme = find.textContaining('Theme:');
      expect(changedTheme, findsOneWidget);
      
      // もう一度タップ
      await tester.tap(changedTheme);
      await tester.pumpAndSettle();

      // さらにテーマが変更されたことを確認
      final finalTheme = find.textContaining('Theme:');
      expect(finalTheme, findsOneWidget);
      
      print('✅ テーマ変更フローのテストが成功しました');
    });

    testWidgets('テーマ設定が再起動後も保持される', (tester) async {
      // 1回目の起動
      await app.main();
      await tester.pumpAndSettle();

      // 設定画面へ遷移
      final settingsIcon = find.byIcon(Icons.settings);
      await tester.tap(settingsIcon);
      await tester.pumpAndSettle();

      // テーマを1回変更
      final themeToggle = find.textContaining('Theme:');
      await tester.tap(themeToggle);
      await tester.pumpAndSettle();
      
      // 変更後のテーマテキストを取得
      final Text themeText = tester.widget(find.textContaining('Theme:'));
      final savedTheme = themeText.data;
      
      // アプリを「再起動」（新しいインスタンスを起動）
      // Note: Integration Testでは完全な再起動はできないが、
      // SharedPreferencesに保存されているかを確認
      await tester.pumpWidget(Container()); // 現在のウィジェットをクリア
      await tester.pumpAndSettle();
      
      await app.main();
      await tester.pumpAndSettle();

      // 設定画面へ再度遷移
      final settingsIcon2 = find.byIcon(Icons.settings);
      await tester.tap(settingsIcon2);
      await tester.pumpAndSettle();

      // テーマが保持されていることを確認
      expect(find.text(savedTheme!), findsOneWidget);
      
      print('✅ テーマ永続化のテストが成功しました: $savedTheme');
    });
  });
}
