import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_ui/main.dart' as app;
import 'package:table_calendar/table_calendar.dart';

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

        // Snackbarを閉じる
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).clearSnackBars();
        await tester.pumpAndSettle();

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

        // Snackbarを閉じる
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).clearSnackBars();
        await tester.pumpAndSettle();

        // 一覧にカテゴリが表示されることを確認
        final categoryCard = find.widgetWithText(Card, uniqueCategoryName);
        expect(categoryCard, findsOneWidget);
        
        print('✅ シナリオ2完了: カテゴリ作成成功 - $uniqueCategoryName');
      }

      // ======================
      // シナリオ3: Link作成
      // ======================
      {
        print('📝 シナリオ3: Link作成を開始');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueLinkTitle = 'E2Eリンク_$timestamp';
        final testUrl = 'https://example.com/test_$timestamp';
        
        // カテゴリ画面からHomeに戻る
        await tester.pumpAndSettle(const Duration(seconds: 1));
        final homeTab = find.text('Home');
        expect(homeTab, findsOneWidget);
        await tester.tap(homeTab);
        await tester.pumpAndSettle();

        // Linkタブへ移動
        final linkTab = find.text('Link');
        expect(linkTab, findsOneWidget);
        await tester.tap(linkTab);
        await tester.pumpAndSettle();

        // Link Form画面にいることを確認
        expect(find.text('Link Form'), findsOneWidget);

        // URLフィールドに入力
        final urlField = find.widgetWithText(TextFormField, 'URL');
        expect(urlField, findsOneWidget);
        await tester.enterText(urlField, testUrl);
        await tester.pumpAndSettle();

        // Titleフィールドに入力
        final titleField = find.widgetWithText(TextFormField, 'Title');
        expect(titleField, findsOneWidget);
        await tester.enterText(titleField, uniqueLinkTitle);
        await tester.pumpAndSettle();

        // Submitボタンをタップ
        final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
        expect(submitButton, findsOneWidget);
        await tester.tap(submitButton);
        
        // API通信を待つ
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // 成功メッセージを確認
        expect(find.text('Success to add link'), findsOneWidget);

        // Snackbarを閉じる
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).clearSnackBars();
        await tester.pumpAndSettle();
        
        print('✅ シナリオ3完了: Link作成成功 - $uniqueLinkTitle');
      }

      // ======================
      // シナリオ4: Purchase作成
      // ======================
      {
        print('📝 シナリオ4: Purchase作成を開始');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniquePurchaseTitle = 'E2E購入_$timestamp';
        final testCost = '1234';
        
        // LinkタブからPurchaseタブへ移動
        await tester.pumpAndSettle(const Duration(seconds: 1));
        final purchaseTab = find.text('Purchase');
        expect(purchaseTab, findsOneWidget);
        await tester.tap(purchaseTab);
        await tester.pumpAndSettle();

        // Purchase Form画面にいることを確認
        expect(find.text('Purchase Form'), findsOneWidget);

        // Costフィールドに入力
        final costField = find.widgetWithText(TextFormField, 'Cost');
        expect(costField, findsOneWidget);
        await tester.enterText(costField, testCost);
        await tester.pumpAndSettle();

        // Titleフィールドに入力
        final titleField = find.widgetWithText(TextFormField, 'Title');
        expect(titleField, findsOneWidget);
        await tester.enterText(titleField, uniquePurchaseTitle);
        await tester.pumpAndSettle();

        // Submitボタンをタップ
        final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
        expect(submitButton, findsOneWidget);
        await tester.tap(submitButton);
        
        // API通信を待つ
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // 成功メッセージを確認
        expect(find.text('Success to add purchase'), findsOneWidget);

        // Snackbarを閉じる
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).clearSnackBars();
        await tester.pumpAndSettle();
        
        print('✅ シナリオ4完了: Purchase作成成功 - $uniquePurchaseTitle (¥$testCost)');
      }

      // ======================
      // シナリオ5: カレンダー操作とイベント確認
      // ======================
      {
        print('📝 シナリオ5: カレンダー操作とイベント確認を開始');
        
        // PurchaseタブからHomeタブに戻る
        await tester.pumpAndSettle(const Duration(seconds: 1));
        final homeTab = find.text('Home');
        expect(homeTab, findsOneWidget);
        await tester.tap(homeTab);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // TableCalendarを確認
        final tableCalendar = find.byType(TableCalendar);
        expect(tableCalendar, findsOneWidget);
        print('  ✓ カレンダーが表示されています');

        // 今日の日付
        final today = DateTime.now();
        print('  📅 今日: ${today.year}年${today.month}月${today.day}日');

        // 同月内で別の日付をいくつかタップ
        final testDates = ['15', '20'];
        for (final dateStr in testDates) {
          final dateFinder = find.descendant(
            of: tableCalendar,
            matching: find.text(dateStr),
          );
          if (dateFinder.evaluate().isNotEmpty) {
            await tester.tap(dateFinder.first);
            await tester.pumpAndSettle();
            print('  ✓ ${dateStr}日をタップ');
          }
        }

        // 翌月に移動
        final nextMonthButton = find.descendant(
          of: tableCalendar,
          matching: find.byIcon(Icons.chevron_right),
        );
        expect(nextMonthButton, findsOneWidget);
        await tester.tap(nextMonthButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('  ✓ 翌月に移動');

        // 翌月でいくつかの日付をタップ
        final nextMonthDates = ['5', '10', '25'];
        for (final dateStr in nextMonthDates) {
          final dateFinder = find.descendant(
            of: tableCalendar,
            matching: find.text(dateStr),
          );
          if (dateFinder.evaluate().isNotEmpty) {
            await tester.tap(dateFinder.first);
            await tester.pumpAndSettle();
            print('  ✓ 翌月の${dateStr}日をタップ');
          }
        }

        // 前月に戻る
        final prevMonthButton = find.descendant(
          of: tableCalendar,
          matching: find.byIcon(Icons.chevron_left),
        );
        expect(prevMonthButton, findsOneWidget);
        await tester.tap(prevMonthButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('  ✓ 前月に戻る');

        // 今日の日付をタップ（LinkとPurchaseを作成した日）
        final todayStr = today.day.toString();
        final todayFinder = find.descendant(
          of: tableCalendar,
          matching: find.text(todayStr),
        );
        expect(todayFinder, findsOneWidget);
        await tester.tap(todayFinder.first);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        print('  ✓ 今日($todayStr日)をタップ');

        // イベントリストにLinkとPurchaseが表示されることを確認
        // Linkのアイコンを確認
        final linkIcon = find.byIcon(Icons.link);
        expect(linkIcon, findsAtLeastNWidgets(1));
        print('  ✓ Linkイベントが表示されています');

        // Purchaseのアイコンを確認
        final purchaseIcon = find.byIcon(Icons.shopping_cart);
        expect(purchaseIcon, findsAtLeastNWidgets(1));
        print('  ✓ Purchaseイベントが表示されています');

        print('✅ シナリオ5完了: カレンダー操作とイベント確認成功');
      }

      print('🎉 全テストシナリオ完了！');
    });
  });
}
