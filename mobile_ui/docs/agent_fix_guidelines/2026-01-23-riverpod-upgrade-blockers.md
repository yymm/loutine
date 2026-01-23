# Riverpod 3.x/4.x アップグレードの阻害要因と解決策

## 現状の問題

Riverpod 3.x/4.xへのアップグレードが以下の依存関係の競合により不可能：

```
riverpod_generator 4.0.2 → analyzer ^9.0.0 が必要
custom_lint 0.8.1       → analyzer ^8.0.0 が必要
riverpod_lint 3.1.2     → analyzer ^9.0.0 が必要

Flutter SDK 3.38.7
  └─ flutter_test
      └─ test_api 0.7.7 (固定)

riverpod 3.2.0
  └─ test ^1.0.0 (dev_dependency)
      └─ test_api との競合
```

## アップグレード可能にする方法

### 方法1: Flutter SDKの次期アップデートを待つ ⭐️ 推奨

**概要**: Flutter SDKの次のメジャー/マイナーリリースで `test_api` のバージョン制約が緩和される可能性が高い

**利点**:
- ✅ 最も安全で確実
- ✅ 全ての依存関係が公式にサポートされる
- ✅ 追加の作業や回避策が不要

**実施手順**:
1. Flutter SDKのリリースノートを監視
   - https://github.com/flutter/flutter/releases
   - https://docs.flutter.dev/release/release-notes
2. 新しい安定版リリース時に再度アップグレードを試行
3. 期待される時期：次のFlutter安定版リリース（通常3-4ヶ月周期）

**確認コマンド**:
```bash
# 定期的に実行して互換性をチェック
cd mobile_ui
rm pubspec.lock
flutter pub upgrade --dry-run flutter_riverpod riverpod_annotation riverpod_generator
```

---

### 方法2: custom_lint と riverpod_lint を一時的に削除 ⚠️

**概要**: Lintツールを諦めて、Riverpod 3.x/4.xにアップグレード

**トレードオフ**:
- ✅ Riverpod 3.x/4.xの新機能が使える
- ❌ Riverpod特有のlintルールが効かなくなる
- ❌ コード品質チェックが弱くなる

**実施手順**:

1. **pubspec.yaml から削除**:
```yaml
dev_dependencies:
  # custom_lint: ^0.7.6  # 削除
  # riverpod_lint: ^2.6.5  # 削除
```

2. **analysis_options.yaml から削除**:
```yaml
analyzer:
  # plugins:
  #   - custom_lint  # コメントアウト
```

3. **Riverpod アップグレード**:
```bash
flutter pub upgrade --major-versions flutter_riverpod riverpod_annotation riverpod_generator
```

4. **コード生成**:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**注意事項**:
- riverpod_lintが提供するルール（不適切なProvider使用の検出など）が失われる
- 手動でのコードレビューが必要
- 将来互換性のあるバージョンが出たら戻す

---

### 方法3: Flutter beta/master チャンネルを使用 ⚠️⚠️

**概要**: Flutter beta/masterチャンネルで最新のtest_apiを使用

**トレードオフ**:
- ✅ Riverpod 3.x/4.xが使える可能性
- ❌ 不安定なFlutter SDKを使用（本番非推奨）
- ❌ CIの設定も変更が必要
- ❌ 他の依存関係で問題が発生する可能性

**実施手順**:
```bash
# beta チャンネルに切り替え
fvm install beta
fvm use beta

# 依存関係を再解決
flutter pub get
```

**注意**: 本番環境には推奨されません。

---

### 方法4: 依存関係のオーバーライド（非推奨）

**概要**: `pubspec.yaml` で依存関係を強制的にオーバーライド

```yaml
dependency_overrides:
  analyzer: ^9.0.0
  test_api: ^0.7.9
```

**トレードオフ**:
- ❌ 未テストの組み合わせを強制
- ❌ 実行時エラーの可能性
- ❌ 将来のアップデートで問題が起きる可能性

**注意**: 実験的な目的以外では使用を避けるべき

---

## 推奨アプローチ

現時点では **方法1（Flutter SDKの更新を待つ）** を推奨します。

**理由**:
1. **Riverpod 2.6.xで十分**: 既にコードジェネレーター方式に移行済み
2. **リスクが低い**: 安定したSDKとライブラリの組み合わせ
3. **時間の問題**: 次のFlutterリリースで解決する可能性が高い

### 現在のRiverpod 2.6.xの状況

✅ **既に実装済みの機能**:
- `@riverpod` アノテーションによるコード生成
- 自動的な型推論
- AsyncNotifier のサポート
- Provider の自動dispose

❌ **Riverpod 3.x/4.xの新機能（現在使えない）**:
- より良いエラーメッセージ
- パフォーマンス改善
- いくつかの新しいAPI

**結論**: 現状の2.6.xで開発上の問題はほとんどない

---

## 定期確認タスク

以下を定期的に確認してアップグレードのタイミングを逃さない：

### 月次チェック（毎月1回）

```bash
# 1. Flutter最新安定版を確認
fvm releases | grep stable | head -3

# 2. 依存関係の互換性をドライラン
cd mobile_ui
flutter pub upgrade --dry-run --major-versions flutter_riverpod

# 3. Riverpodの最新バージョンを確認
curl -s https://pub.dev/api/packages/flutter_riverpod | jq -r '.latest.version'
```

### アップグレード可能かの判定

以下のコマンドが成功すればアップグレード可能：

```bash
cd mobile_ui
rm pubspec.lock

# 一時的にpubspec.yamlを変更
# flutter_riverpod: ^3.2.0
# riverpod_annotation: ^4.0.1
# riverpod_generator: ^4.0.2

flutter pub get

# 成功 → アップグレード可能！
# 失敗 → まだ待つ
```

---

## 参考リンク

- [Riverpod Migration Guide](https://riverpod.dev/docs/migration/from_state_notifier)
- [Flutter Release Notes](https://docs.flutter.dev/release/release-notes)
- [Pub.dev: riverpod_generator](https://pub.dev/packages/riverpod_generator)
- [GitHub Issue: analyzer version conflicts](https://github.com/rrousselGit/riverpod/issues)

---

## 更新履歴

- 2026-01-23: 初版作成（Flutter 3.38.7時点）
