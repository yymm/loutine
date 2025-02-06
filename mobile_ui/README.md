# mobile_ui

A new Flutter project.

## Architecture

ref: https://docs.flutter.dev/app-architecture

ref: https://github.com/flutter/samples/blob/main/compass_app/README.md

```

```

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
