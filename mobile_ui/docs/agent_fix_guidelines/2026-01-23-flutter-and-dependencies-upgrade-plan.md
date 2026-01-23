# Flutter and Dependencies Upgrade Plan (2026-01-23)

## 現状

### Flutter / Dart バージョン
- **現在**: Flutter 3.24.3 / Dart 3.5.3
- **CI**: Flutter 3.27.1 (mobile-unit-test.yml)
- **最新安定版**: Flutter 3.38.7

### アップグレード状況
- ✅ Phase 1完了: Riverpodコードジェネレーター移行 + テスト拡充
  - `lib/state` → `lib/providers` へリファクタリング済み
  - 全Providerが `@riverpod` アノテーション方式に移行済み
  - Provider単体テストが8ファイル存在

### 依存関係の状況
`flutter pub outdated` の結果から、以下の主要な更新が必要：

#### 主要な依存関係のアップグレード
1. **Riverpod関連** (メジャーバージョンアップ)
   - `flutter_riverpod`: 2.6.1 → 3.2.0
   - `riverpod_annotation`: 2.6.1 → 4.0.1
   - `riverpod_generator`: 2.6.3 → 4.0.2
   - `riverpod_lint`: 2.6.3 → 3.1.2

2. **go_router** (メジャーバージョンアップ)
   - 現在: 14.8.0 → 最新: 17.0.1
   - Resolvable: 15.1.2

3. **build_runner周辺** (メジャーバージョンアップ)
   - `build_runner`: 2.4.13 → 2.10.5
   - `custom_lint`: 0.7.0 → 0.8.1

4. **その他のマイナーアップグレード**
   - `http`: 1.3.0 → 1.6.0
   - `flutter_lints`: 5.0.0 → 6.0.0
   - `flutter_launcher_icons`: 0.14.3 → 0.14.4
   - `shared_preferences`: 2.5.1 → 2.5.4
   - `url_launcher`: 6.3.1 → 6.3.2

#### 廃止パッケージ (transitive dependencies)
以下のパッケージは廃止されているが、直接依存していないため影響は限定的：
- `build_resolvers`
- `build_runner_core`
- `js`
- `macros`

## アップグレード戦略

### 前提条件の確認

1. **技術的制約**（2026-01-23の調査結果）
   - **重要な発見**: Riverpod 3.x/4.x は現在のFlutter SDK 3.38.7と依存関係の競合がある
   - `riverpod_generator 4.x` は `analyzer ^9.0.0` が必要
   - `custom_lint 0.7.x` は `analyzer ^7.0.0` が必要
   - `custom_lint 0.8.x` は `analyzer ^8.0.0` が必要
   - `flutter_test` (Flutter SDK) の `test_api` バージョン固定により、これらの間で依存関係が解決できない
   - **結論**: Riverpod 2.6.xを維持し、互換性のある他のパッケージのみをアップグレードする

2. **リスク軽減策**
   - ✅ Riverpodコードジェネレーター移行済み
   - ✅ Provider単体テスト存在
   - ✅ CI/CDパイプライン稼働中

### 修正されたアップグレード手順

#### Step 1: Flutter本体のアップグレード (完了 ✅)
- ローカル環境: Flutter 3.24.3 → 3.38.7 (fvmを使用)
- CI環境: Flutter 3.27.1 → 3.38.7
- Dart SDK: 3.5.3 → 3.10.7

#### Step 2: 互換性のある依存関係のアップグレード (go_router、http、その他)
**理由**: Riverpod 3.x/4.xは現在互換性がないため、2.6.xを維持しつつ他をアップグレード

更新対象:
- `go_router`: 14.8.0 → 17.0.1 (メジャーアップデート)
- `http`: 1.3.0 → 1.6.0
- `flutter_launcher_icons`: 0.14.3 → 0.14.4
- `shared_preferences`: 2.5.1 → 2.5.4
- `url_launcher`: 6.3.1 → 6.3.2

**Riverpod関連は現行バージョンを維持**:
- `flutter_riverpod`: 2.6.1 (最新3.2.0は互換性なし)
- `riverpod_annotation`: 2.6.1 (最新4.0.1は互換性なし)
- `riverpod_generator`: 2.6.5 (最新4.0.2は互換性なし)
- `riverpod_lint`: 2.6.5 (最新3.1.2は互換性なし)
- `custom_lint`: 0.7.6 (最新0.8.1は互換性なし)

作業内容:
1. `pubspec.yaml` の互換性のある依存関係を更新
2. `flutter pub get`
3. Breaking changesの対応（特にgo_router）
4. 全テスト実行: `flutter test`
5. Lint実行: `flutter analyze`

#### Step 3: build_runner / flutter_lints のアップグレード (必要に応じて)
**理由**: 開発ツールの更新

更新対象:
- `build_runner`: 2.4.13 → 2.10.5 (互換性を確認)
- `flutter_lints`: 5.0.0 → 6.0.0 (互換性を確認)

## 各Stepの検証項目

### 全Step共通の検証
1. ✅ `flutter pub get` が成功
2. ✅ `flutter pub run build_runner build --delete-conflicting-outputs` が成功
3. ✅ `flutter test` が全て通過
4. ✅ `flutter analyze` でエラーなし
5. ✅ Integration Testが通過（CIでの実行でも可）
6. ✅ アプリが起動できる（手動確認）

### Step 2 (Riverpod) 追加検証
- Provider単体テスト8ファイルが全て通過
- コード生成された `.g.dart` ファイルに問題がないか確認

### Step 3 (go_router) 追加検証
- アプリ内の画面遷移が正常に動作するか確認
- Integration Testでのルーティング動作を確認

## Breaking Changes対応のガイドライン

### Riverpod 2.x → 3.x
参考: https://riverpod.dev/docs/migration/0.14.0_to_1.0.0 (最新のマイグレーションガイドを確認)

主な変更点の可能性:
- Provider参照方法の変更
- AsyncValue APIの変更
- ProviderContainer APIの変更

### go_router 14.x → 17.x
参考: https://pub.dev/packages/go_router/changelog

確認事項:
- ルーティング定義の構文変更
- パラメータ渡しの方法
- リダイレクト処理の変更

## 想定スケジュール

- Step 1 (Flutter本体): 30分
- Step 2 (Riverpod): 1-2時間（Breaking changes対応含む）
- Step 3 (go_router): 1時間
- Step 4 (build_runner/lint): 30分
- Step 5 (その他): 30分

**合計**: 3.5-4.5時間

## ロールバック戦略

各Stepはコミットを分けているため、問題が発生した場合は該当コミットをrevertする。

## 注意事項

1. **CIの更新**: `.github/workflows/*.yml` のFlutterバージョンも忘れずに更新
2. **mise.toml**: プロジェクトルートの `mise.toml` にFlutterバージョン指定がある場合は更新
3. **ドキュメント**: このファイルの内容を作業後に実績ベースで更新
4. **Breaking changes**: 各ライブラリのCHANGELOGを必ず確認

## 成功基準

- ✅ 全てのテストが通過
- ✅ Lintエラーなし
- ✅ アプリが正常に起動・動作
- ✅ CI/CDパイプラインが成功
- ✅ Flutter 3.38.7で動作確認完了
