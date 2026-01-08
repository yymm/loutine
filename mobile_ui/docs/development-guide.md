# 開発ガイド

## Riverpod コード生成について

### コード生成のタイミング

Riverpod 3.0以降では、`@riverpod`アノテーションを使用したコード生成が推奨されます。以下のタイミングでコード生成を実行する必要があります：

#### 1. **初回セットアップ時**
```bash
make setup
# または
make get && make build
```

#### 2. **開発中（監視モード・推奨）**
```bash
make watch
```
- ファイルの変更を監視して自動的にコードを再生成します
- 開発中はこのコマンドを**別のターミナルで常時実行**することを推奨します
- エディタで`.dart`ファイルを保存すると自動的に`.g.dart`ファイルが更新されます

#### 3. **手動で一度だけ生成**
```bash
make build
```
- 監視モードを使わない場合
- CI/CDパイプラインで使用
- コード生成が必要かわからない場合に試す

#### 4. **コード生成がうまくいかない場合**
```bash
make clean-build
```
- 既存の生成ファイルをクリーンしてから再生成
- エラーが解決しない場合に試す

### コード生成が必要なケース

以下のファイルを編集した場合、コード生成が必要です：

- `@riverpod`アノテーションを使用しているファイル
- `part 'filename.g.dart';`を含むファイル
- プロバイダーの定義を変更したファイル

**例：**
```dart
// lib/state/example_state.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'example_state.g.dart'; // ← これがあればコード生成が必要

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  
  void increment() => state++;
}
```

### 開発ワークフロー

#### 推奨フロー（監視モード）

1. **ターミナル1: 監視モード起動**
   ```bash
   cd mobile_ui
   make watch
   ```

2. **ターミナル2: アプリ実行**
   ```bash
   cd mobile_ui
   make emulator
   # または
   make local
   ```

3. **エディタでコード編集**
   - `.dart`ファイルを編集して保存
   - 自動的に`.g.dart`ファイルが更新される
   - ホットリロードで変更が反映される

#### 手動フロー

1. **コード編集**
2. **コード生成実行**
   ```bash
   make build
   ```
3. **アプリ実行/リロード**

### トラブルシューティング

#### エラー: "undefined_identifier"
```
error • Undefined name 'exampleProvider' • lib/ui/example.dart:10:20
```

**原因**: コード生成がされていない、または古い

**解決方法**:
```bash
make build
# または監視モードを再起動
```

#### エラー: ビルドが失敗する
```
error: Conflicting outputs were detected...
```

**解決方法**:
```bash
make clean-build
```

#### 生成ファイルが更新されない

**解決方法**:
1. 監視モードを停止（Ctrl+C）
2. キャッシュをクリア
   ```bash
   make clean
   make get
   make build
   ```

## Makefile コマンド一覧

### 基本コマンド

| コマンド | 説明 | 使用タイミング |
|---------|------|--------------|
| `make help` | ヘルプ表示 | コマンドを忘れた時 |
| `make setup` | 初回セットアップ | プロジェクトのクローン後 |
| `make get` | 依存関係取得 | pubspec.yaml更新後 |

### コード生成

| コマンド | 説明 | 使用タイミング |
|---------|------|--------------|
| `make build` | コード生成（1回） | 手動生成が必要な時 |
| `make watch` | コード生成（監視） | **開発中（推奨）** |
| `make clean-build` | クリーン＋再生成 | エラー解決時 |

### 開発・実行

| コマンド | 説明 | 使用タイミング |
|---------|------|--------------|
| `make local` | ローカル環境で実行 | 物理デバイスで開発 |
| `make emulator` | エミュレーターで実行 | エミュレーターで開発 |
| `make fmt` | コードフォーマット | コミット前 |
| `make analyze` | 静的解析 | コミット前 |
| `make test` | テスト実行 | コミット前 |

### ビルド・その他

| コマンド | 説明 | 使用タイミング |
|---------|------|--------------|
| `make dev` | 開発環境ビルド | APK配布時 |
| `make prod` | 本番環境ビルド | リリース時 |
| `make icons` | アイコン生成 | アイコン変更時 |
| `make clean` | Flutterクリーン | キャッシュクリア時 |

## FVM対応

Makefileは自動的にFVMの有無を検出します：

- **FVMがインストールされている場合**: `fvm flutter`を使用
- **FVMがインストールされていない場合**: `flutter`を使用

特別な設定は不要です。

## 推奨開発環境セットアップ

### 1. 初回セットアップ
```bash
cd mobile_ui
make setup
```

### 2. 開発中の標準フロー
```bash
# ターミナル1
make watch

# ターミナル2
make emulator  # または make local
```

### 3. コミット前
```bash
make fmt
make analyze
# make test  # テストがある場合
git add .
git commit -m "your message"
```

## よくある質問

### Q: watchモードは常に起動しておくべき？
**A**: はい、開発中は常に起動しておくことを推奨します。ファイルを保存するたびに自動的にコード生成されるため、開発効率が大幅に向上します。

### Q: watchモードを使わずに開発できる？
**A**: 可能ですが、ファイルを編集するたびに`make build`を手動で実行する必要があり、非効率です。

### Q: CI/CDではどのコマンドを使うべき？
**A**: `make build`を使用してください。watchモードはCI/CD環境では不要です。

### Q: コード生成ファイル（.g.dart）はGitにコミットすべき？
**A**: はい、コミットすべきです。他の開発者がすぐに開発を始められるようにするためです。

### Q: エラーが解決しない場合は？
**A**: 以下を順番に試してください：
```bash
# 1. クリーンビルド
make clean-build

# 2. それでもダメなら完全クリーン
make clean
make get
make build

# 3. それでもダメならキャッシュ削除
flutter clean
flutter pub cache repair
make setup
```

## 参考リンク

- [Riverpod公式ドキュメント](https://riverpod.dev/)
- [build_runner公式ドキュメント](https://pub.dev/packages/build_runner)
- [Riverpod 3.0マイグレーションガイド](https://riverpod.dev/docs/whats_new)
