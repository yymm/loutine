# mobile_ui

A new Flutter project.

## 📚 ドキュメント

- **[開発ガイド](docs/development-guide.md)** - Riverpodコード生成、Makefileコマンド、開発ワークフロー
- **[アーキテクチャガイド](docs/2026-01-17-architecture-guide.md)** - アプリケーション設計

## 🚀 クイックスタート

### 初回セットアップ
```bash
cd mobile_ui
make setup  # 依存関係取得 + コード生成
```

### 開発中
```bash
# ターミナル1: コード生成の監視モード（推奨）
make watch

# ターミナル2: アプリ実行
make emulator  # または make local
```

### よく使うコマンド
```bash
make help         # コマンド一覧を表示
make build        # コード生成（1回のみ）
make watch        # コード生成（監視モード）
make fmt          # コードフォーマット
make analyze      # 静的解析
```

詳しくは[開発ガイド](docs/development-guide.md)を参照してください。

## Architecture

ref: https://docs.flutter.dev/app-architecture

ref: https://github.com/flutter/samples/blob/main/compass_app/README.md

## 技術スタック

- **Flutter**: 3.38.5
- **Dart**: 3.8.0
- **状態管理**: Riverpod 3.1.0（コード生成）
- **ルーティング**: go_router 17.0.1

## Disclaimer

これは初めて作ったFlutterアプリなのでね...

- エラーハンドリングはAsyncNotifierのみやるよ
- 単体テストは諦めています

api -> state -> ui の区分けを意識しています。

- apiは文字列型のjson bodyを返すだけ
- stateは型を持ち、riverpodのnotifierとproviderを定義します
- uiはいわゆるviewです

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
