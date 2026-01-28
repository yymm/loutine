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

        final descriptionField = find.widgetWithText(
          TextFormField,
          'Description',
        );
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

        final descriptionField = find.widgetWithText(
          TextFormField,
          'Description',
        );
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
        await tester.pumpAndSettle(const Duration(seconds: 2));

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

        // Tagフィールドまでスクロール
        final tagIcon = find.byIcon(Icons.tag);
        await tester.ensureVisible(tagIcon);
        await tester.pumpAndSettle();

        // Tagを選択 - MultiDropdownフィールドをタップして開く
        await tester.tap(tagIcon);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // ドロップダウンメニューが開いたら、ListTileを探して最初のアイテムをタップ
        final listTiles = find.byType(ListTile);
        if (listTiles.evaluate().isNotEmpty) {
          await tester.tap(listTiles.first);
          await tester.pumpAndSettle();
          print('  ✓ タグを選択しました');

          // ドロップダウンを閉じる（外側をタップ）
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();
        } else {
          // ListTileがない場合はCheckboxを試す
          final checkboxes = find.byType(Checkbox);
          if (checkboxes.evaluate().isNotEmpty) {
            await tester.tap(checkboxes.first);
            await tester.pumpAndSettle();
            print('  ✓ タグを選択しました');

            // ドロップダウンを閉じる
            await tester.tapAt(const Offset(10, 10));
            await tester.pumpAndSettle();
          } else {
            print('  ⚠ タグのアイテムが見つかりませんでした');
          }
        }

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
        await tester.pumpAndSettle(const Duration(seconds: 2));

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

        // Categoryを選択 - DropdownButtonFormFieldをタップ
        final categoryDropdown = find.ancestor(
          of: find.text('Category'),
          matching: find.byType(DropdownButtonFormField<String>),
        );
        if (categoryDropdown.evaluate().isNotEmpty) {
          await tester.tap(categoryDropdown.first);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // ドロップダウンメニューが開いたら、最初のカテゴリを選択
          final dropdownItems = find.byType(DropdownMenuItem<String>);
          if (dropdownItems.evaluate().isNotEmpty) {
            await tester.tap(dropdownItems.first);
            await tester.pumpAndSettle();
            print('  ✓ カテゴリを選択しました');
          }
        }

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
      // シナリオ5: Note作成
      // ======================
      {
        print('📝 シナリオ5: Note作成を開始');
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final uniqueNoteTitle = 'E2Eノート_$timestamp';
        final testNoteContent = 'これはE2Eテストで作成されたノートです。';

        // Noteタブへ移動
        await tester.pumpAndSettle(const Duration(seconds: 1));
        final noteTab = find.text('Note');
        expect(noteTab, findsOneWidget);
        await tester.tap(noteTab);
        await tester.pumpAndSettle(const Duration(seconds: 2));

        print('  ✓ Noteタブに移動');

        // Note画面にいることを確認
        expect(find.text('Note'), findsWidgets);

        // Titleフィールドに入力
        final titleField = find.widgetWithText(TextFormField, 'Title');
        expect(titleField, findsOneWidget);
        await tester.enterText(titleField, uniqueNoteTitle);
        await tester.pumpAndSettle();
        print('  ✓ タイトルを入力: $uniqueNoteTitle');

        // Quillエディタに内容を入力
        // QuillEditorを見つける
        final quillEditor = find.byType(TextField).last;
        expect(quillEditor, findsOneWidget);
        await tester.tap(quillEditor);
        await tester.pumpAndSettle();
        await tester.enterText(quillEditor, testNoteContent);
        await tester.pumpAndSettle();
        print('  ✓ 本文を入力: $testNoteContent');

        // 保存ボタン（FloatingActionButton）をタップ
        final saveButton = find.byType(FloatingActionButton);
        expect(saveButton, findsOneWidget);
        await tester.tap(saveButton);
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // タグ選択ダイアログが表示されることを確認
        expect(find.text('Select tags'), findsOneWidget);
        print('  ✓ タグ選択ダイアログが表示');

        // タグ選択はスキップして直接保存
        // （タグなしでも保存できることを確認）

        // Submitボタンをタップ
        final dialogSaveButton = find.widgetWithText(ElevatedButton, 'Submit');
        expect(dialogSaveButton, findsOneWidget);
        await tester.tap(dialogSaveButton);

        // API通信を待つ（長めに設定）
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // 成功メッセージを確認
        // エラーが表示されていないことも確認
        final successMessage = find.text('Success to save note');
        final errorText = find.textContaining('エラー');

        if (errorText.evaluate().isNotEmpty) {
          print('  ❌ エラーメッセージが表示されています');
          // エラー内容を確認するため、全てのTextウィジェットを列挙
          final allTexts = find.byType(Text);
          for (final textWidget in allTexts.evaluate()) {
            final widget = textWidget.widget as Text;
            if (widget.data != null && widget.data!.contains('エラー')) {
              print('  エラー内容: ${widget.data}');
            }
          }
        }

        expect(successMessage, findsOneWidget);
        print('  ✓ 保存成功メッセージを確認');

        // Snackbarを閉じる
        ScaffoldMessenger.of(
          tester.element(find.byType(Scaffold).first),
        ).clearSnackBars();
        await tester.pumpAndSettle();

        // タイトルがクリアされていることを確認（新規作成時）
        final clearedTitleField = find.widgetWithText(TextFormField, 'Title');
        final titleWidget = tester.widget<TextFormField>(clearedTitleField);
        expect(titleWidget.controller?.text, isEmpty);

        print('✅ シナリオ5完了: Note作成成功 - $uniqueNoteTitle');
      }

      // ======================
      // シナリオ6: カレンダー操作とイベント確認
      // ======================
      {
        print('📝 シナリオ6: カレンダー操作とイベント確認を開始');

        // NoteタブからHomeタブに戻る
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
            print('  ✓ $dateStr日をタップ');
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
            print('  ✓ 翌月の$dateStr日をタップ');
          }
        }

        // 今月に戻る
        final prevMonthButton = find.descendant(
          of: tableCalendar,
          matching: find.byIcon(Icons.chevron_left),
        );
        expect(prevMonthButton, findsOneWidget);
        await tester.tap(prevMonthButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('  ✓ 今月に戻る');

        // 今日の日付をタップ（LinkとPurchaseとNoteを作成した日）
        final todayStr = today.day.toString();
        final todayFinder = find.descendant(
          of: tableCalendar,
          matching: find.text(todayStr),
        );
        // 月をまたぐ場合、同じ日付が複数表示される可能性があるため、findsWidgetsを使用
        expect(todayFinder, findsWidgets);

        // 月初（1-7日）の場合は前月の日付も表示されるため.last（当月）を使用
        // 月末（21-31日）の場合は翌月の日付も表示されるため.first（当月）を使用
        // 月中（8-20日）の場合は.firstで問題なし
        final todayIndex = today.day > 7
            ? todayFinder.evaluate().length -
                  1 // 月初: last
            : 0; // 月中・月末: first

        await tester.tap(todayFinder.at(todayIndex));
        await tester.pumpAndSettle(const Duration(seconds: 3));
        print('  ✓ 今日($todayStr日)をタップ');

        // イベント一覧の読み込みを待つ
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // イベントリストにLink、Purchase、Noteが表示されることを確認
        // Linkのアイコンを確認
        final linkIcon = find.byIcon(Icons.link);
        expect(linkIcon, findsAtLeastNWidgets(1));
        print('  ✓ Linkイベントが表示されています');

        // Purchaseのアイコンを確認
        final purchaseIcon = find.byIcon(Icons.shopping_cart);
        expect(purchaseIcon, findsAtLeastNWidgets(1));
        print('  ✓ Purchaseイベントが表示されています');

        // Noteのアイコンを確認
        final noteIcon = find.byIcon(Icons.note);
        expect(noteIcon, findsAtLeastNWidgets(1));
        print('  ✓ Noteイベントが表示されています');

        print('✅ シナリオ6完了: カレンダー操作とイベント確認成功');
      }

      print('🎉 全テストシナリオ完了！');
    });
  });
}
