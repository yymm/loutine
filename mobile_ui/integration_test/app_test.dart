import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_ui/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('全体のE2Eテスト', () {
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

    testWidgets('カテゴリを作成して一覧に表示される', (tester) async {
      // ユニークなカテゴリ名を生成（タイムスタンプ使用）
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueCategoryName = 'E2Eカテゴリ_$timestamp';
      
      // 設定画面に戻る
      final backButton = find.byIcon(Icons.settings);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // 設定画面でカテゴリ管理をタップ
      final categoryManagement = find.text('Catagory Management');
      expect(categoryManagement, findsOneWidget);
      await tester.tap(categoryManagement);
      await tester.pumpAndSettle();

      // 新規作成ボタンをタップ
      final addButton = find.text('Show Modal');
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // モーダルが表示されることを確認
      expect(find.text('Add new category'), findsNWidgets(2)); // ボタンとモーダルのタイトル

      // フォーム入力
      // Titleフィールドに入力
      final titleField = find.widgetWithText(TextFormField, 'Title');
      expect(titleField, findsOneWidget);
      await tester.enterText(titleField, uniqueCategoryName);
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
      
      // API通信を待つ（長めに設定）
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // 一覧にカテゴリが表示されることを確認（Chipウィジェットを検索）
      final categoryChip = find.widgetWithText(Chip, uniqueCategoryName);
      expect(categoryChip, findsOneWidget);
      
      print('✅ カテゴリ作成フローのテストが成功しました: $uniqueCategoryName');
    });

    testWidgets('テーマを複数回切り替えできる', (tester) async {
      // カテゴリ画面から設定画面に戻る（戻るボタンを使用）
      await tester.pageBack();
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
