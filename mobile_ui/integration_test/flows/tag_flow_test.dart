import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_ui/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('タグ管理のE2Eテスト', () {
    testWidgets('タグを作成して一覧に表示される', (tester) async {
      // アプリ起動
      await app.main();
      await tester.pumpAndSettle();

      // タグタブへ遷移
      // BottomNavigationBarの「タグ」をタップ
      final tagTab = find.text('タグ');
      expect(tagTab, findsOneWidget);
      await tester.tap(tagTab);
      await tester.pumpAndSettle();

      // 新規作成ボタンをタップ
      final addButton = find.text('Add new tag');
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // モーダルが表示されることを確認
      expect(find.text('Add new tag'), findsNWidgets(2)); // ボタンとモーダルのタイトル

      // フォーム入力
      // Titleフィールドに入力
      final titleField = find.widgetWithText(TextFormField, 'Title');
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, 'E2Eテストタグ');
      await tester.pumpAndSettle();

      // Descriptionフィールドに入力
      final descriptionField = find.widgetWithText(TextFormField, 'Description');
      expect(descriptionField, findsOneWidget);
      await tester.enterText(descriptionField, 'テスト用の説明');
      await tester.pumpAndSettle();

      // Addボタンをタップ
      final saveButton = find.widgetWithText(ElevatedButton, 'Add');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      
      // API通信を待つ（長めに設定）
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // モーダルが閉じることを確認
      expect(find.text('Add new tag'), findsOneWidget); // ボタンのみ残る

      // 一覧に表示されることを確認
      expect(find.text('E2Eテストタグ'), findsOneWidget);
      
      print('✅ タグ作成フローのテストが成功しました');
    });
  });
}
