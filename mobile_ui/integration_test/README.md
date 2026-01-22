# Integration Test 実行ガイド

## 🎯 現在の状態

✅ **実装済みのテスト**:
- メインフローテスト (`flows/main_flow_test.dart`) - 全シナリオを1つのtestWidgets内で実行

## 📋 実装したテスト

### `flows/main_flow_test.dart` - メインフローテスト

**テストシナリオ** (1つのtestWidgets内で連続実行):

1. **シナリオ1: タグ作成**
   - 設定 → タグ管理 → 新規作成
   - タイトル・説明を入力して保存
   - 一覧に表示されることを確認

2. **シナリオ2: カテゴリ作成**
   - タグ画面 → 設定 → カテゴリ管理
   - タイトル・説明を入力して保存
   - 一覧に表示されることを確認

3. **シナリオ3: Link作成**
   - Linkタブへ移動
   - URL・タイトルを入力して保存
   - 成功メッセージを確認

4. **シナリオ4: Purchase作成**
   - Purchaseタブへ移動
   - 金額・タイトルを入力して保存
   - 成功メッセージを確認

5. **シナリオ5: カレンダー操作とイベント確認**
   - Homeタブのカレンダーで複数の日付をタップ
   - 翌月へ移動して日付をタップ
   - 前月に戻って当日を選択
   - LinkとPurchaseが表示されることを確認

**重要な設計判断**:
- **単一testWidgets設計**: 全シナリオを1つのtestWidgets内で実行
- **理由**: 複数のtestWidgetsを使うとSharedPreferencesの初期化エラーが発生
- **パターン**: app.main()を1回だけ実行し、その後は画面遷移で全シナリオをテスト

## 🚀 テスト実行方法

### 前提条件

1. **バックエンドAPIが起動している**
   ```bash
   # バックエンドサーバーを起動（別ターミナル）
   cd backend
   npx wrangler dev --local --ip 127.0.0.1 --port 8787
   ```

2. **デバイス/エミュレータが起動している**
   - Linux Desktop (CI/CDで使用)
   - Android Emulator
   - または他のプラットフォーム

### 実行コマンド

```bash
# 全テストを実行（推奨）
flutter test integration_test/ -d linux --dart-define=baseUrl=http://127.0.0.1:8787

# メインフローテストのみ実行
flutter test integration_test/flows/main_flow_test.dart -d linux --dart-define=baseUrl=http://127.0.0.1:8787

# Android Emulatorで実行
flutter test integration_test/flows/main_flow_test.dart -d emulator-5554 --dart-define=baseUrl=http://10.0.2.2:8787
```

## 🤖 GitHub Actionsでの自動実行

PRを作成すると自動でテストが実行されます：

- **トリガー**: `mobile_ui/`または`backend/`の変更を含むPR
- **環境**: Ubuntu + Linux Desktop + Backend on Cloudflare Workers
- **実行時間**: 約3-4分

ワークフロー: `.github/workflows/mobile-integration-test.yml`

## 🤖 GitHub Actionsでの自動実行

PRを作成すると自動でテストが実行されます：

- **トリガー**: `mobile_ui/`または`backend/`の変更を含むPR
- **環境**: Ubuntu + Linux Desktop + Backend on Cloudflare Workers
- **実行時間**: 約3-4分

ワークフロー: `.github/workflows/mobile-integration-test.yml`

## 🐛 よくある問題と解決方法

### 1. 「No devices found」エラー

**原因**: デバイス/エミュレータが起動していない

**解決方法**:
```bash
# 利用可能なデバイスを確認
flutter devices

# Android Emulatorを起動
# (Android Studioから起動、またはコマンドライン)

# iOS Simulatorを起動
open -a Simulator
```

### 2. 「Timeout waiting for application」エラー

**原因**: アプリのビルドに時間がかかっている

**解決方法**: `initial_wait`を長く設定（既に90秒に設定済み）

### 3. 「Widget not found」エラー

**原因**: 
- 画面遷移のタイミングがずれている
- 要素の識別子が間違っている

**解決方法**:
```dart
// pumpAndSettleを追加
await tester.pumpAndSettle();

// デバッグ出力で確認
debugPrint(tester.allWidgets.toString());
```

### 4. API通信エラー

**原因**: バックエンドサーバーが起動していない

**解決方法**:
```bash
# バックエンドサーバーの状態を確認
curl http://localhost:8787/api/v1/tags

# サーバーを起動
# (プロジェクト固有の起動コマンド)
```

### 5. Linux環境でビルドエラー

**原因**: 必要なビルドツールが不足

**解決方法**:
```bash
# 必要なツールをインストール
sudo apt-get update
sudo apt-get install -y clang cmake ninja-build pkg-config libgtk-3-dev
```

## 🏗️ テスト設計の背景

### なぜ全てのテストが1つのファイル（`flows/main_flow_test.dart`）にあるのか？

**技術的な制約**:
- Flutter Integration Testで複数の`testWidgets`を実行すると、SharedPreferencesの初期化エラーが発生
- 各testWidgetsでapp.main()を呼ぶと、2回目以降で`SharedPreferencesInstance already being initialized`エラー

**採用したパターン**:
```dart
testWidgets('全シナリオ', () {
  await app.main();  // 1回だけ実行
  
  // シナリオ1
  { /* タグ作成 */ }
  
  // シナリオ2  
  { /* カテゴリ作成 */ }
  
  // ...
});
```

**メリット**:
- 1つのアプリインスタンスで全シナリオをテスト
- 実際のユーザー体験に近い（アプリを閉じずに複数の操作を実行）
- SharedPreferencesなどの状態が保持される

**デメリット**:
- 1つのテストが失敗すると後続のシナリオも実行されない
- テストの独立性が低い

### flowsディレクトリの役割

- **目的**: フローテスト（シナリオテスト）を配置
- **現状**: `main_flow_test.dart`のみ（メインの統合フロー）
- **将来**: 必要に応じて他のフローテストを追加可能（例: `onboarding_flow_test.dart`など）

## 📝 次のステップ

### 今後の改善案

- [ ] 各シナリオを独立したヘルパー関数に分割してテストコードの可読性向上
- [ ] UIにKeyを追加してテストの安定性向上
- [ ] モックAPI版のテスト実装（バックエンド不要）
- [ ] スクリーンショット撮影機能の追加

## 📚 参考リンク

- [Flutter Integration Test公式ドキュメント](https://docs.flutter.dev/testing/integration-tests)
- [table_calendar パッケージ](https://pub.dev/packages/table_calendar)

---

**最終更新日**: 2026-01-22  
**現在のブランチ**: `feature/add-more-integration-tests`

