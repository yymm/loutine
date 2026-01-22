import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_ui/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('全体のE2Eテスト', () {
    testWidgets('タグとカテゴリの作成フロー', (tester) async {
      // ======================
      // アプリ起動（1回のみ）
      // ======================
      await app.main();
      await tester.pumpAndSettle();

      // ======================
      // シナリオ1: タグ作成
      // ======================
      {
        print('📝 シナリオ1: タグ作成を開始');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueTagName = 'E2Eテスト_$timestamp';
        
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
        expect(find.text('Add new tag'), findsNWidgets(2));

        // フォーム入力
        final titleField = find.widgetWithText(TextFormField, 'Title');
        expect(titleField, findsOneWidget);
        await tester.enterText(titleField, uniqueTagName);
        await tester.pumpAndSettle();

        final descriptionField = find.widgetWithText(TextFormField, 'Description');
        expect(descriptionField, findsOneWidget);
        await tester.enterText(descriptionField, 'テスト用の説明');
        await tester.pumpAndSettle();

        // 保存ボタンをタップ
        final saveButton = find.widgetWithText(ElevatedButton, 'Add');
        expect(saveButton, findsOneWidget);
        await tester.tap(saveButton);
        
        // API通信を待つ
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // 一覧にタグが表示されることを確認
        final tagChip = find.widgetWithText(Chip, uniqueTagName);
        expect(tagChip, findsOneWidget);
        
        print('✅ シナリオ1完了: タグ作成成功 - $uniqueTagName');
      }

      // ======================
      // シナリオ2: カテゴリ作成
      // ======================
      {
        print('📝 シナリオ2: カテゴリ作成を開始');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueCategoryName = 'E2Eカテゴリ_$timestamp';
        
        // タグ画面から設定画面に戻る
        await tester.pumpAndSettle(const Duration(seconds: 2));
        expect(find.text('Tag List'), findsOneWidget);
        
        final settingsIcon = find.descendant(
          of: find.byType(AppBar),
          matching: find.byIcon(Icons.settings),
        );
        expect(settingsIcon, findsOneWidget);
        await tester.tap(settingsIcon);
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
        expect(find.text('Add new category'), findsAtLeastNWidgets(1));

        // フォーム入力
        final titleField = find.widgetWithText(TextFormField, 'Title');
        expect(titleField, findsOneWidget);
        await tester.enterText(titleField, uniqueCategoryName);
        await tester.pumpAndSettle();

        final descriptionField = find.widgetWithText(TextFormField, 'Description');
        expect(descriptionField, findsOneWidget);
        await tester.enterText(descriptionField, 'テスト用の説明');
        await tester.pumpAndSettle();

        // 保存ボタンをタップ
        final saveButton = find.widgetWithText(ElevatedButton, 'Add');
        expect(saveButton, findsOneWidget);
        await tester.tap(saveButton);
        
        // API通信を待つ
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // 一覧にカテゴリが表示されることを確認
        final categoryCard = find.widgetWithText(Card, uniqueCategoryName);
        expect(categoryCard, findsOneWidget);
        
        print('✅ シナリオ2完了: カテゴリ作成成功 - $uniqueCategoryName');
      }

      print('🎉 全テストシナリオ完了！');
    });
  });
}
