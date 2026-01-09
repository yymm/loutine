# Flutter E2Eテスト戦略

## FlutterにおけるE2Eテストの選択肢

### 1. Integration Test（公式、推奨）

**概要**：
- Flutter公式のE2Eテストフレームワーク
- Widget Test の拡張で、実デバイス/エミュレータ上で動作
- `integration_test` パッケージを使用

**メリット**：
- ✅ 公式サポートで安定性が高い
- ✅ 既存のWidget Testの知識を活用できる
- ✅ CI/CDでの実行が容易（Firebase Test Lab、GitHub Actionsなど）
- ✅ 追加の学習コストが低い
- ✅ Riverpodとの相性が良い

**デメリット**：
- ❌ ネイティブUIとのインタラクションが複雑（カメラ、位置情報など）
- ❌ 実行速度がやや遅い

**使用例**：
```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_ui/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('カテゴリ管理のE2E', () {
    testWidgets('カテゴリを新規作成して一覧に表示される', (tester) async {
      await app.main();
      await tester.pumpAndSettle();

      // カテゴリ作成画面へ遷移
      await tester.tap(find.text('カテゴリ'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // フォーム入力
      await tester.enterText(find.byKey(Key('categoryNameField')), 'テストカテゴリ');
      await tester.enterText(find.byKey(Key('categoryDescriptionField')), '説明');
      
      // 保存ボタンをタップ
      await tester.tap(find.text('保存'));
      await tester.pumpAndSettle();

      // 一覧に表示されることを確認
      expect(find.text('テストカテゴリ'), findsOneWidget);
    });
  });
}
```

**セットアップ**：
```yaml
# pubspec.yaml
dev_dependencies:
  integration_test:
    sdk: flutter
```

---

### 2. Patrol（コミュニティ製、モダン）

**概要**：
- Integration Testをベースにした高機能なE2Eフレームワーク
- より直感的なAPI、ネイティブ機能のサポート強化
- LeanCode社が開発・メンテナンス

**メリット**：
- ✅ より直感的なAPI（`$`シンタックス）
- ✅ ネイティブ機能のテストが容易（権限、通知など）
- ✅ スクリーンショット、動画録画のサポート
- ✅ Hot Restart対応で開発効率が高い
- ✅ Shorebird（コードプッシュ）との統合

**デメリット**：
- ❌ コミュニティ製（公式ではない）
- ❌ 学習コストがやや高い
- ❌ ネイティブ機能を使うため、セットアップが複雑

**使用例**：
```dart
// integration_test/app_test.dart
import 'package:patrol/patrol.dart';
import 'package:mobile_ui/main.dart' as app;

void main() {
  patrolTest('カテゴリを新規作成して一覧に表示される', (PatrolTester $) async {
    await app.main();
    
    // より直感的なAPI
    await $('カテゴリ').tap();
    await $(Icons.add).tap();
    
    await $('カテゴリ名').enterText('テストカテゴリ');
    await $('説明').enterText('説明');
    
    await $('保存').tap();
    
    expect($('テストカテゴリ'), findsOneWidget);
  });
}
```

**セットアップ**：
```yaml
# pubspec.yaml
dev_dependencies:
  patrol: ^3.0.0
```

---

### 3. Maestro（クロスプラットフォーム）

**概要**：
- YAML形式でテストシナリオを記述
- Flutter、React Native、ネイティブアプリに対応
- Mobile.devが開発

**メリット**：
- ✅ コード不要でテストシナリオを記述
- ✅ 非エンジニアでも理解しやすい
- ✅ マルチプラットフォーム対応
- ✅ Cloud実行環境あり

**デメリット**：
- ❌ 複雑なロジックのテストが困難
- ❌ Flutterの内部状態にアクセスできない
- ❌ Riverpodのモック化などが不可能

**使用例**：
```yaml
# flows/create_category.yaml
appId: com.example.mobile_ui
---
- launchApp
- tapOn: "カテゴリ"
- tapOn: "+"
- inputText: "テストカテゴリ"
- tapOn: "保存"
- assertVisible: "テストカテゴリ"
```

**セットアップ**：
```bash
brew install maestro
maestro test flows/
```

---

## 推奨アプローチ

### このプロジェクトでの推奨：**Integration Test**

**理由**：
1. ✅ Flutter公式で安定性が高い
2. ✅ すでにRiverpodを使っているため、状態管理のテストが重要
3. ✅ 既存のWidget Testの知識を活用できる
4. ✅ CI/CD統合が容易
5. ✅ バックエンドAPIとの統合テストが必要（モック化も可能）

**Patrolは次の場合に検討**：
- ネイティブ機能（カメラ、位置情報、プッシュ通知など）を多用する場合
- より直感的なAPIを求める場合

**Maestroは次の場合に検討**：
- QAチームが非エンジニア中心の場合
- スモークテスト程度で十分な場合

---

## E2Eテストの設計方針

### テスト対象の選定

**優先度高**：
- ✅ **クリティカルパス**：カテゴリ/タグの作成→一覧表示
- ✅ **複雑なフロー**：リンク作成（クリップボード→タイトル取得→タグ選択→保存）
- ✅ **状態連携**：テーマモード変更→永続化→再起動後も保持

**優先度中**：
- カレンダー表示→イベント一覧
- 購入記録作成
- ナビゲーション全体

**優先度低**：
- 細かいUIの見た目
- エッジケース

### テストシナリオ例

#### シナリオ1: カテゴリ作成フロー
```
1. アプリ起動
2. カテゴリタブへ遷移
3. 「+」ボタンタップ
4. カテゴリ名、説明を入力
5. 保存ボタンタップ
6. カテゴリ一覧に表示されることを確認
7. (オプション) バックエンドAPIに保存されたことを確認
```

#### シナリオ2: リンク作成フロー
```
1. アプリ起動
2. リンク作成画面へ遷移
3. クリップボードから貼り付けボタンタップ
4. URLが入力されることを確認
5. タイトル取得ボタンタップ
6. タイトルが自動入力されることを確認
7. タグを選択
8. 保存ボタンタップ
9. カレンダーに表示されることを確認
```

#### シナリオ3: テーマモード永続化
```
1. アプリ起動（初期状態：system）
2. テーマ切り替えボタンタップ（system → light）
3. テーマがライトモードになることを確認
4. アプリを再起動
5. テーマがライトモードのまま維持されることを確認
```

---

## テストデータ戦略

### 1. バックエンドAPIのモック化

Integration Testでは、実APIまたはモックAPIを選択可能：

**実API使用**：
- テスト用データベースを用意
- テスト前後でデータクリーンアップ
- より現実的なテスト

**モックAPI使用**：
- `http.Client`をモック化（`mockito`または`http_mock_adapter`）
- テストが高速
- ネットワーク不要

**推奨**: 両方を組み合わせ
- ローカル開発：モックAPI
- CI/CD：実API（テスト環境）

### 2. SharedPreferencesのモック化

```dart
setUp(() {
  SharedPreferences.setMockInitialValues({});
});
```

---

## ディレクトリ構成

```
test/
├── unit/                          # ユニットテスト
│   └── state/                     # Stateレイヤー
│       ├── theme_mode_state_test.dart
│       └── ...
├── widget/                        # Widgetテスト（今回は対象外）
│   └── ...
└── helpers/
    ├── mock_api_client.dart
    └── test_utils.dart

integration_test/
├── app_test.dart                  # メインE2Eテスト
├── flows/
│   ├── category_flow_test.dart    # カテゴリ関連フロー
│   ├── tag_flow_test.dart         # タグ関連フロー
│   ├── link_flow_test.dart        # リンク関連フロー
│   ├── theme_flow_test.dart       # テーマ変更フロー
│   └── calendar_flow_test.dart    # カレンダー関連フロー
└── helpers/
    ├── test_app.dart              # テスト用アプリセットアップ
    └── test_data.dart             # テストデータ生成
```

---

## CI/CD統合

### GitHub Actions例

```yaml
# .github/workflows/integration_test.yml
name: Integration Tests

on: [push, pull_request]

jobs:
  integration_test_android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.5'
      - name: Run Integration Tests
        uses: reactivecircus/android-emulator-runner@v2
        with:
          api-level: 29
          script: |
            cd mobile_ui
            flutter test integration_test/
```

---

## 実装スケジュール（Phase 1内で実施する場合）

### Option A: E2Eテストも含める（Phase 1を延長）
- Week 1-2: ユニットテスト（State層）
- Week 3: E2Eテスト（クリティカルパス）
- **合計**: 3週間

### Option B: E2Eテストは別Phase（推奨）
- **Phase 1**: ユニットテスト（State層）のみ - 2週間
- **Phase 2**: Flutter + Riverpod アップデート - 1-2週間
- **Phase 3（新規）**: E2Eテスト追加 - 1-2週間

**推奨はOption B**：
- Phase 1でState層を固める
- Phase 2でRiverpod移行
- Phase 3でE2E追加（新しいRiverpod実装に対して）

---

## 次のステップ

1. **E2Eテストを導入するか決定**
   - 導入する場合：Integration Test vs Patrolを選択
   - スケジュールをOption AまたはBで調整

2. **Phase 1の範囲を確定**
   - ユニットテストのみ
   - または、ユニットテスト + E2Eテスト

3. **実装開始**
   - まずは`theme_mode_state_test.dart`から

どのように進めますか？
