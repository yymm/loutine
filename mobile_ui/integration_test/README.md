# Integration Test 実行ガイド

## 🎯 現在の状態

✅ **完了した作業**:
- Integration testパッケージの追加
- テストヘルパー (`test_app.dart`) の作成
- タグ作成フローのテスト実装 (`tag_flow_test.dart`)

## 📋 実装したテスト

### 1. タグ作成フロー (`tag_flow_test.dart`)

**テストシナリオ**:
1. アプリ起動
2. タグタブへ遷移
3. 「Add new tag」ボタンをタップ
4. モーダルが表示される
5. Title、Descriptionを入力
6. 「Add」ボタンをタップ
7. API通信完了を待つ
8. タグが一覧に表示されることを確認

## 🚀 テスト実行方法

### 前提条件

1. **バックエンドAPIが起動している**
   ```bash
   # バックエンドサーバーを起動（別ターミナル）
   # デフォルトURL: http://10.0.2.2:8787 (Android Emulator)
   # または http://localhost:8787 (Desktop)
   ```

2. **デバイス/エミュレータが起動している**
   - Android Emulator
   - iOS Simulator
   - または Desktop環境 (Linux/macOS/Windows)

### 実行コマンド

```bash
# Android Emulatorで実行
flutter test integration_test/flows/tag_flow_test.dart

# iOS Simulatorで実行
flutter test integration_test/flows/tag_flow_test.dart -d "iPhone 15"

# macOSデスクトップで実行
flutter test integration_test/flows/tag_flow_test.dart -d macos

# Linuxデスクトップで実行（要: ビルドツール）
flutter test integration_test/flows/tag_flow_test.dart -d linux

# カスタムバックエンドURLを指定
flutter test integration_test/flows/tag_flow_test.dart --dart-define=baseUrl=http://localhost:8787
```

### デバッグ実行

テストを画面で確認しながら実行する場合:

```bash
# 通常のアプリとして起動してテストコードを手動実行
flutter run integration_test/flows/tag_flow_test.dart
```

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

## 📝 次のステップ

### Phase 1の残りタスク（推奨）

- [ ] カテゴリ作成フローのテスト実装
- [ ] テーマ変更フローのテスト実装

### Phase 2（オプション）

- [ ] リンク作成フローのテスト実装
- [ ] カレンダー表示フローのテスト実装

### 改善案

- [ ] UIにKeyを追加してテストの安定性向上
- [ ] モックAPI版のテスト実装（バックエンド不要）
- [ ] GitHub Actionsでの自動実行設定

## 🔍 テストコードの説明

### `integration_test/helpers/test_app.dart`

テスト用のアプリセットアップヘルパー。Providerのオーバーライドなどが可能。

```dart
final app = await setupTestApp(
  overrides: [
    // モックに置き換える場合
    tagApiClientProvider.overrideWithValue(mockApi),
  ],
);
```

### `integration_test/flows/tag_flow_test.dart`

タグ作成の完全なE2Eテスト。実際のユーザー操作をシミュレート。

**ポイント**:
- `find.text()` でテキストから要素を検索
- `find.widgetWithText()` で特定のWidgetタイプとテキストで検索
- `pumpAndSettle()` で画面の更新を待つ
- API通信は `Duration(seconds: 5)` で長めに待つ

## 📚 参考リンク

- [Flutter Integration Test公式ドキュメント](https://docs.flutter.dev/testing/integration-tests)
- [実装ガイド](../docs/agent_fix_guidelines/2026-01-21-integration-test-implementation-guide.md)

---

**作成日**: 2026-01-21  
**ブランチ**: `feature/add-integration-tests`
