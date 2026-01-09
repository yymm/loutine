# Riverpod State Management Test Strategy

## 目的

Phase 1として、既存のRiverpod StateNotifierに対するテストを作成し、Phase 2のFlutter + Riverpodアップデート時にリグレッションを検出できるようにする。

## テスト対象のState一覧

| ファイル名 | Provider名 | 複雑度 | 優先度 | 説明 |
|----------|-----------|--------|--------|------|
| `theme_mode_state.dart` | `themeModeProvider` | 低 | 高 | テーマモード切り替え + SharedPreferences連携 |
| `category_list_state.dart` | `categoryListProvider` | 中 | 高 | カテゴリ一覧の取得・追加（API連携） |
| `tag_list_state.dart` | `tagListProvider` | 中 | 高 | タグ一覧の取得・追加（API連携） |
| `category_new_state.dart` | `categoryNewNameNotifierProvider`, `categoryNewDescriptionNotifierProvider` | 低 | 中 | カテゴリ作成フォームの状態管理 |
| `tag_new_state.dart` | `tagNewNameNotifierProvider`, `tagNewDescriptionNotifierProvider` | 低 | 中 | タグ作成フォームの状態管理 |
| `link_new_state.dart` | `linkNewProvider` | 高 | 高 | リンク作成（クリップボード、URL解析、API連携） |
| `purchase_new_state.dart` | `purchaseNewProvider` | 中 | 中 | 購入記録作成の状態管理 |
| `home_calendar_state.dart` | `calendarStateProvider`, 他4つ | 高 | 高 | カレンダー表示・イベント一覧（複数API連携） |
| `note_new_state.dart` | - | - | 低 | 空ファイル（未実装） |

## テスト方針

### 1. ユニットテストの基本構成

各StateNotifierに対して以下をテストする：

1. **初期状態の検証**
   - Providerが正しく初期化されること
   - 初期値が期待通りであること

2. **状態変更の検証**
   - メソッド呼び出し後、状態が正しく更新されること
   - 副作用（API呼び出し、永続化）が正しく実行されること

3. **エッジケースの検証**
   - 空文字列、null、エラーレスポンスなどの処理

### 2. 依存関係のモック化

外部依存を持つStateNotifierはモックを使用：

#### API呼び出しのモック
- `http.Client`をモック化
- テスト用のレスポンスを返す
- エラーケースもテスト可能にする

#### SharedPreferencesのモック
- `shared_preferences`パッケージの`SharedPreferences.setMockInitialValues()`を使用
- テストごとに初期値を設定

#### Clipboardのモック
- `TestDefaultBinaryMessengerBinding`を使用
- プラットフォームチャネルをモック化

### 3. テストケース設計

#### 低複雑度（theme_mode_state, category_new_state, tag_new_state）

**テスト項目**：
- ✅ 初期状態の確認
- ✅ 状態変更メソッドの動作確認
- ✅ リセットメソッドの動作確認
- ✅ 永続化処理の確認（theme_mode_stateのみ）

**テストケース例（theme_mode_state）**：
```dart
test('初期状態はThemeMode.system', () {
  final container = ProviderContainer();
  final themeMode = container.read(themeModeProvider);
  expect(themeMode, ThemeMode.system);
});

test('toggleでlight→dark→system→lightと循環', () async {
  final container = ProviderContainer();
  final notifier = container.read(themeModeProvider.notifier);
  
  await notifier.toggle(); // system -> light
  expect(container.read(themeModeProvider), ThemeMode.light);
  
  await notifier.toggle(); // light -> dark
  expect(container.read(themeModeProvider), ThemeMode.dark);
  
  await notifier.toggle(); // dark -> system
  expect(container.read(themeModeProvider), ThemeMode.system);
});

test('SharedPreferencesに保存される', () async {
  SharedPreferences.setMockInitialValues({});
  final container = ProviderContainer();
  final notifier = container.read(themeModeProvider.notifier);
  
  await notifier.toggle();
  final prefs = await SharedPreferences.getInstance();
  expect(prefs.getString('theme_mdoe'), 'light'); // typoも含めて既存実装に合わせる
});
```

#### 中複雑度（category_list_state, tag_list_state, purchase_new_state）

**テスト項目**：
- ✅ 初期状態の確認
- ✅ API呼び出し成功時の状態更新
- ✅ API呼び出し失敗時のエラーハンドリング
- ✅ JSONパース処理の確認
- ✅ 状態への追加処理

**テストケース例（category_list_state）**：
```dart
test('getList成功時、stateが更新される', () async {
  final mockClient = MockClient((request) async {
    return http.Response(
      '[{"id": 1, "name": "Test Category", "description": "Test"}]',
      200,
    );
  });
  
  // API ClientにmockClientを注入する仕組みが必要
  final container = ProviderContainer();
  final notifier = container.read(categoryListProvider.notifier);
  
  await notifier.getList();
  
  final state = container.read(categoryListProvider);
  expect(state.length, 1);
  expect(state[0].name, 'Test Category');
});

test('add成功時、stateにカテゴリが追加される', () async {
  // 同様にモック化してテスト
});

test('API呼び出し失敗時、StateErrorをthrowする', () async {
  // エラーケースのテスト
});
```

#### 高複雑度（link_new_state, home_calendar_state）

**テスト項目**：
- ✅ 初期状態の確認
- ✅ 複数の状態変更メソッドの動作確認
- ✅ クリップボード操作のモック（link_new_state）
- ✅ 複数API呼び出しの統合処理（home_calendar_state）
- ✅ データ変換処理の検証（日付グルーピングなど）

**テストケース例（link_new_state）**：
```dart
test('pasteByClipBoardでクリップボードからURLを取得', () async {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
    .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.getData') {
        return {'text': 'https://example.com'};
      }
      return null;
    });
  
  final container = ProviderContainer();
  final notifier = container.read(linkNewProvider.notifier);
  
  final url = await notifier.pasteByClipBoard();
  
  expect(url, 'https://example.com');
  expect(container.read(linkNewProvider).url, 'https://example.com');
});

test('getTitleFromUrlでタイトルを取得', () async {
  // URLからタイトル取得のAPI呼び出しをモック化してテスト
});
```

**テストケース例（home_calendar_state）**：
```dart
test('getAllEventItemで複数種類のイベントを取得しグルーピング', () async {
  // Link, Purchase, NoteのAPIをすべてモック化
  // 日付ごとにグルーピングされることを確認
  // calendarEventsのMapが正しく構築されることを確認
});
```

## テストファイル構成

```
test/
├── state/
│   ├── theme_mode_state_test.dart
│   ├── category_list_state_test.dart
│   ├── category_new_state_test.dart
│   ├── tag_list_state_test.dart
│   ├── tag_new_state_test.dart
│   ├── link_new_state_test.dart
│   ├── purchase_new_state_test.dart
│   └── home_calendar_state_test.dart
└── helpers/
    ├── mock_api_client.dart  # API Clientのモック基底クラス
    └── test_utils.dart        # テスト用ユーティリティ
```

## 課題と対応方針

### 課題1: API Clientの依存性注入が未実装

**現状**：
```dart
class CategoryListNotifier extends StateNotifier<List<Category>> {
  Future<void> add(String name, String description) async {
    CategoryApiClient apiClient = CategoryApiClient();  // ハードコーディング
    // ...
  }
}
```

**対応方針**：
1. **Phase 1（テスト作成時）**: APIレスポンスを外部から注入できるようテストヘルパーを作成
   - または、`http.Client`のグローバルモック化（`mockito`の`build_runner`使用）
2. **Phase 2（Riverpod移行時）**: コードジェネレーター方式で依存性注入を実装
   ```dart
   @riverpod
   class CategoryList extends _$CategoryList {
     @override
     List<Category> build() => [];
     
     Future<void> add(String name, String description) async {
       final apiClient = ref.read(categoryApiClientProvider); // DI
       // ...
     }
   }
   ```

### 課題2: SharedPreferencesInstanceがSingleton

**対応方針**：
- `SharedPreferences.setMockInitialValues()`を各テストの`setUp()`で呼び出し
- テスト後に`SharedPreferencesInstance.initialize()`を再実行

### 課題3: テストカバレッジ目標

**目標**: State管理層80%以上

**測定方法**：
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## 実装順序

優先度順に実装：

1. **Week 1**: 低〜中複雑度の実装
   - Day 1-2: `theme_mode_state_test.dart`（学習用）
   - Day 2-3: `category_new_state_test.dart`, `tag_new_state_test.dart`
   - Day 3-4: `category_list_state_test.dart`, `tag_list_state_test.dart`
   - Day 4-5: `purchase_new_state_test.dart`

2. **Week 2**: 高複雑度の実装
   - Day 1-3: `link_new_state_test.dart`
   - Day 3-5: `home_calendar_state_test.dart`

3. **Week 2末**: カバレッジ測定・レビュー・mainへマージ

## 成功基準

- ✅ 全8ファイルに対するテストが作成される
- ✅ State管理層のカバレッジが80%以上
- ✅ すべてのテストがCIで通過
- ✅ モック化の方針が統一されている
- ✅ テストコードが可読性高く、メンテナンスしやすい

## 参考リンク

- [Riverpod Testing Documentation](https://riverpod.dev/docs/essentials/testing)
- [Flutter Testing Guide](https://docs.flutter.dev/cookbook/testing/unit/introduction)
- [Mockito Documentation](https://pub.dev/packages/mockito)
