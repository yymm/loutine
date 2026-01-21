import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_ui/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('タグ管理のE2Eテスト', () {
    testWidgets('タグを作成して一覧に表示される', (tester) async {
      // ユニークなタグ名を生成（タイムスタンプ使用）
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueTagName = 'E2Eテスト_$timestamp';
      
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

      // 設定画面でタグ管理をタップ
      final tagManagement = find.text('Tag Management');
      expect(tagManagement, findsOneWidget);
      await tester.tap(tagManagement);
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
      await tester.enterText(titleField, uniqueTagName);
      await tester.pumpAndSettle();

      // Descriptionフィールドに入力
      final descriptionField = find.widgetWithText(TextFormField, 'Description');
      expect(descriptionField, findsOneWidget);
      await tester.enterText(descriptionField, 'テスト用の説明');
      await tester.pumpAndSettle();

      // 保存ボタンをタップ
      final saveButton = find.widgetWithText(ElevatedButton, 'Add');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      
      // API通信を待つ（さらに長めに設定）
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // 一覧にタグが表示されることを確認（Chipウィジェットを検索）
      final tagChip = find.widgetWithText(Chip, uniqueTagName);
      expect(tagChip, findsOneWidget);
      
      print('✅ タグ作成フローのテストが成功しました: $uniqueTagName');
    });
  });
}
