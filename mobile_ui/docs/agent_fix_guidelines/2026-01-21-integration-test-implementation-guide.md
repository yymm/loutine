# Flutter Integration Test 実装ガイド

作成日: 2026-01-21
更新日: 2026-01-21

## 🎯 目的

リファクタリング作業中のデグレ（機能退行）を防ぐため、主要なユーザーフローをE2Eテストでカバーする。

## 📊 選択したテスト手法

### Integration Test（Flutter公式）

**選定理由**:
1. ✅ Flutter公式で安定性が高い
2. ✅ Riverpodとの相性が抜群（Providerのオーバーライドが可能）
3. ✅ 実装時間が短い（3-5日）
4. ✅ 既存のWidget Testの知識を活用できる
5. ✅ CI/CD統合が容易

### 他の選択肢との比較

| 手段 | 難易度 | 実装時間 | メンテナンス | Riverpod対応 | 推奨度 |
|------|--------|----------|-------------|--------------|--------|
| **Integration Test** | 低 | 3-5日 | 低 | ✅ 優秀 | ⭐⭐⭐⭐⭐ |
| **Patrol** | 中 | 1週間 | 中 | ✅ 良好 | ⭐⭐⭐⭐ |
| **Maestro** | 低 | 1-2日 | 低 | ❌ 不可 | ⭐⭐⭐ |
| **Appium** | 高 | 2-3週間 | 高 | ❌ 不可 | ⭐⭐ |

## 🏗️ ディレクトリ構成

```
mobile_ui/
├── integration_test/
│   ├── app_test.dart                    # 全体のスモークテスト
│   ├── flows/
│   │   ├── tag_flow_test.dart           # タグ作成フロー ← まずはこれから
│   │   ├── category_flow_test.dart      # カテゴリ作成フロー
│   │   ├── link_flow_test.dart          # リンク作成フロー
│   │   ├── calendar_flow_test.dart      # カレンダー表示
│   │   └── theme_flow_test.dart         # テーマ変更・永続化
│   └── helpers/
│       ├── test_app.dart                # テスト用アプリセットアップ
│       ├── mock_api_client.dart         # モックAPI
│       └── test_data.dart               # テストデータ生成
├── test/                                # 既存（ユニットテスト）
└── lib/
```

## 🎯 テスト優先順位

### 🔴 Phase 1: 必須（デグレ防止）- 1-2日

1. **タグ作成フロー** - 新規作成→一覧表示 ← 最初に実装
2. **カテゴリ作成フロー** - 新規作成→一覧表示
3. **テーマ変更フロー** - 切り替え→永続化→再起動

### 🟡 Phase 2: 推奨（安心感向上）- +1日

4. **リンク作成フロー** - URL入力→タイトル取得→タグ選択→保存
5. **カレンダー表示フロー** - イベント作成→カレンダー表示

### 🟢 Phase 3: 理想（完璧を目指す）- +1-2日

6. **ナビゲーション全体** - 全画面遷移確認
7. **エラーケース** - ネットワークエラー時の挙動

## 📝 実装手順

### Step 1: セットアップ

```yaml
# pubspec.yaml に追加
dev_dependencies:
  integration_test:
    sdk: flutter
  flutter_test:
    sdk: flutter
```

### Step 2: ヘルパー作成

```dart
// integration_test/helpers/test_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/router.dart';
import 'package:mobile_ui/storage.dart';

/// テスト用のアプリをセットアップ
Future<Widget> setupTestApp({
  List<Override> overrides = const [],
}) async {
  await SharedPreferencesInstance.initialize();
  
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.light(),
    ),
  );
}
```

### Step 3: 最初のテスト実装（タグ作成フロー）

```dart
// integration_test/flows/tag_flow_test.dart
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
      await tester.tap(find.text('タグ'));
      await tester.pumpAndSettle();

      // 新規作成ボタンタップ
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // フォーム入力
      await tester.enterText(
        find.byKey(const Key('tagNameField')),
        'E2Eテストタグ',
      );
      await tester.enterText(
        find.byKey(const Key('tagDescriptionField')),
        'テスト用の説明',
      );

      // 保存ボタンタップ
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle(const Duration(seconds: 3)); // API通信待ち

      // 一覧に表示されることを確認
      expect(find.text('E2Eテストタグ'), findsOneWidget);
    });

    testWidgets('作成したタグがアプリ再起動後も残っている', (tester) async {
      // 1回目の起動
      await app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('タグ'));
      await tester.pumpAndSettle();

      // タグが存在することを確認
      expect(find.text('E2Eテストタグ'), findsOneWidget);
    });
  });
}
```

### Step 4: UI側にKeyを追加（必要な場合）

テストで要素を特定するため、UIにKeyを追加する必要がある場合があります。

```dart
// lib/ui/tag/widgets/tag_form.dart (例)
TextField(
  key: const Key('tagNameField'),  // ← これを追加
  decoration: InputDecoration(labelText: 'タグ名'),
  onChanged: (value) => ref.read(tagFormNameProvider.notifier).update(value),
)

TextField(
  key: const Key('tagDescriptionField'),  // ← これを追加
  decoration: InputDecoration(labelText: '説明'),
  onChanged: (value) => ref.read(tagFormDescriptionProvider.notifier).update(value),
)
```

### Step 5: テスト実行

```bash
# デバイス/エミュレータで実行
flutter test integration_test/flows/tag_flow_test.dart

# macOS上で実行（開発時）
flutter test integration_test/flows/tag_flow_test.dart -d macos

# 特定のバックエンドURLを指定
flutter test integration_test/flows/tag_flow_test.dart --dart-define=baseUrl=http://localhost:8787
```

## 🧪 テストパターン

### パターン1: 実APIを使用（推奨）

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('タグ管理（実API）', () {
    testWidgets('タグを作成して一覧に表示される', (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      
      // ... テストコード
    });
  });
}
```

**メリット**: より現実的なテスト  
**デメリット**: バックエンドが必要、データのクリーンアップが必要

### パターン2: モックAPIを使用（高速）

```dart
// integration_test/helpers/mock_api_client.dart
import 'package:mocktail/mocktail.dart';
import 'package:mobile_ui/api/vanilla_api.dart';

class MockTagApiClient extends Mock implements TagApiClient {
  @override
  Future<String> list() async {
    return '''
    [
      {
        "id": 1,
        "name": "既存タグ",
        "description": "説明",
        "created_at": "2026-01-21T00:00:00Z",
        "updated_at": "2026-01-21T00:00:00Z"
      }
    ]
    ''';
  }

  @override
  Future<String> post(String name, String description) async {
    return '''
    {
      "id": 2,
      "name": "$name",
      "description": "$description",
      "created_at": "2026-01-21T00:00:00Z",
      "updated_at": "2026-01-21T00:00:00Z"
    }
    ''';
  }
}

// integration_test/flows/tag_flow_mock_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import '../helpers/test_app.dart';
import '../helpers/mock_api_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('タグ管理（モックAPI）', () {
    testWidgets('タグを作成して一覧に表示される', (tester) async {
      // モックAPIを準備
      final mockApi = MockTagApiClient();
      
      // Providerをオーバーライド
      final app = await setupTestApp(
        overrides: [
          tagApiClientProvider.overrideWithValue(mockApi),
        ],
      );

      await tester.pumpWidget(app);
      await tester.pumpAndSettle();

      // タグタブへ遷移
      await tester.tap(find.text('タグ'));
      await tester.pumpAndSettle();

      // 新規作成ボタンタップ
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // フォーム入力
      await tester.enterText(
        find.byKey(const Key('tagNameField')),
        'モックテストタグ',
      );

      // 保存ボタンタップ
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 一覧に表示されることを確認
      expect(find.text('モックテストタグ'), findsOneWidget);
      
      // APIが呼ばれたことを検証
      verify(() => mockApi.post('モックテストタグ', any())).called(1);
    });
  });
}
```

**メリット**: 高速、バックエンド不要  
**デメリット**: モックの実装が必要

## 💡 実践的なTips

### 1. Keyの命名規則

```dart
// 推奨: 機能_フィールド名_Field/Button の形式
Key('tagName_Field')
Key('tagDescription_Field')
Key('tagSave_Button')
Key('categoryName_Field')
Key('categorySave_Button')
```

### 2. pumpAndSettleのタイムアウト設定

API通信がある場合は長めに設定：

```dart
// デフォルト（100ms × 100回 = 10秒）
await tester.pumpAndSettle();

// カスタム（API通信を考慮）
await tester.pumpAndSettle(const Duration(seconds: 5));
```

### 3. スクリーンショット撮影（デバッグ用）

```dart
import 'package:integration_test/integration_test.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  testWidgets('テスト', (tester) async {
    // ... テストコード
    
    // スクリーンショット撮影
    await binding.takeScreenshot('tag_list');  // screenshots/tag_list.png
  });
}
```

### 4. デバッグ出力

```dart
// 現在の画面に何があるか確認
debugPrint(tester.allWidgets.toString());

// 特定のWidgetを検索
final tagWidgets = find.byType(Chip);
debugPrint('タグの数: ${tagWidgets.evaluate().length}');
```

### 5. エラー時の対処

**「要素が見つからない」エラー**:
```dart
// ❌ 即座に検索
expect(find.text('タグ'), findsOneWidget);

// ✅ 画面が安定するまで待つ
await tester.pumpAndSettle();
expect(find.text('タグ'), findsOneWidget);
```

**「複数の要素が見つかった」エラー**:
```dart
// ❌ 曖昧な検索
await tester.tap(find.byIcon(Icons.add));

// ✅ Keyで特定
await tester.tap(find.byKey(const Key('tagAdd_Button')));
```

## 🤖 CI/CD統合（GitHub Actions）

```yaml
# .github/workflows/integration_test.yml
name: Integration Tests

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  integration_test_macos:
    runs-on: macos-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.1'
          
      - name: Install dependencies
        working-directory: mobile_ui
        run: flutter pub get
        
      - name: Run Integration Tests
        working-directory: mobile_ui
        run: flutter test integration_test/
        
      - name: Upload Screenshots (on failure)
        if: failure()
        uses: actions/upload-artifact@v3
        with:
          name: integration-test-screenshots
          path: mobile_ui/screenshots/

  integration_test_linux:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.1'
          
      - name: Install dependencies
        working-directory: mobile_ui
        run: |
          sudo apt-get update
          sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
          flutter pub get
        
      - name: Run Integration Tests
        working-directory: mobile_ui
        run: flutter test integration_test/ -d linux
```

## 📅 実装スケジュール

### Day 1: セットアップ + タグ作成フロー（今日）

- [ ] `pubspec.yaml`に`integration_test`追加
- [ ] ディレクトリ構成作成
- [ ] `helpers/test_app.dart`作成
- [ ] `flows/tag_flow_test.dart`作成
- [ ] UI側にKey追加（必要な場合）
- [ ] テスト実行・デバッグ

**所要時間**: 4-6時間

### Day 2: カテゴリ・テーマ変更フロー

- [ ] `flows/category_flow_test.dart`作成
- [ ] `flows/theme_flow_test.dart`作成
- [ ] テスト実行・デバッグ

**所要時間**: 4-6時間

### Day 3-4: 複雑なフロー（オプション）

- [ ] `flows/link_flow_test.dart`作成
- [ ] `flows/calendar_flow_test.dart`作成

**所要時間**: 1日

### Day 5: CI/CD + ドキュメント（オプション）

- [ ] GitHub Actions設定
- [ ] README更新
- [ ] モック版テスト作成

**所要時間**: 4-6時間

## 🎯 成功の基準

### 最小限の成功（Phase 1完了）

- ✅ タグ作成フローのテストが通る
- ✅ カテゴリ作成フローのテストが通る
- ✅ テーマ変更フローのテストが通る

これにより、リファクタリング中の主要な機能のデグレを検出できる。

### 理想的な成功（Phase 2-3完了）

- ✅ 全ての主要フローがカバーされている
- ✅ CI/CDで自動実行される
- ✅ モック版テストで高速実行できる

## 📚 参考リソース

- [Flutter Integration Test公式ドキュメント](https://docs.flutter.dev/testing/integration-tests)
- [Riverpodテストガイド](https://riverpod.dev/docs/cookbooks/testing)
- [既存ドキュメント](./2026-01-09-e2e-test-options.md) - 詳細な比較検討

## 🔄 次のステップ

1. ✅ このドキュメント作成
2. 🏃 ブランチ作成 (`feature/add-integration-tests`)
3. 🏃 タグ作成フローのテスト実装
4. 🏃 テスト実行・デバッグ
5. ⏭️ カテゴリ・テーマフローの実装（Day 2以降）

---

**作成日**: 2026-01-21  
**最終更新**: 2026-01-21  
**関連ドキュメント**: 
- [E2Eテスト選択肢の詳細比較](./2026-01-09-e2e-test-options.md)
- [アーキテクチャ改善ロードマップ](./2026-01-19-architecture-improvement-roadmap.md)
