# Flutter & Dependencies Upgrade Guide

## 概要
このドキュメントは、mobile_uiプロジェクトのFlutter SDKと依存ライブラリを最新バージョンにアップデートする手順をまとめたものです。

**更新日**: 2026-01-07  
**対象プロジェクト**: mobile_ui

---

## 📋 現在の状況

### Flutter SDK
- **現在**: Flutter 3.24.3 (Dart 3.5.3)
- **最新**: Flutter 3.38.5 (Dart 3.8+)
- **管理方法**: FVM (Flutter Version Management)

### 主要な依存関係の更新

#### Direct Dependencies

| パッケージ名 | 現在 | 最新 | アップデート種類 |
|------------|------|------|----------------|
| `go_router` | 14.8.0 | 17.0.1 | ⚠️ Major |
| `flutter_riverpod` | 2.6.1 | 3.1.0 | ⚠️ Major |
| `riverpod_annotation` | 2.6.1 | 4.0.0 | ⚠️ Major |
| `http` | 1.3.0 | 1.6.0 | Minor |
| `shared_preferences` | 2.5.1 | 2.5.4 | Patch |
| `url_launcher` | 6.3.1 | 6.3.2 | Patch |
| `flutter_launcher_icons` | 0.14.3 | 0.14.4 | Patch |
| `intl` | 0.20.2 | - | - |
| `table_calendar` | 3.2.0 | - | - |
| `faker` | 2.2.0 | - | - |
| `multi_dropdown` | 3.0.1 | - | - |

#### Dev Dependencies

| パッケージ名 | 現在 | 最新 | アップデート種類 |
|------------|------|------|----------------|
| `flutter_lints` | 5.0.0 | 6.0.0 | ⚠️ Major |
| `build_runner` | 2.4.13 | 2.10.4 | Minor |
| `custom_lint` | 0.7.0 | 0.8.1 | Minor |
| `riverpod_generator` | 2.6.3 | 4.0.0+1 | ⚠️ Major |
| `riverpod_lint` | 2.6.3 | 3.1.0 | Major |

---

## 🚨 Breaking Changes

### 1. Riverpod 3.0 (flutter_riverpod, riverpod_annotation, riverpod_generator)

Riverpod 2.x → 3.x は多数のbreaking changesを含むメジャーアップデートです。

#### 主要な変更点

**1.1 StateProvider / StateNotifierProvider の非推奨化**
```dart
// ❌ 削除される（legacyパッケージに移動）
import 'package:flutter_riverpod/flutter_riverpod.dart';

final counterProvider = StateProvider<int>((ref) => 0);
final myNotifierProvider = StateNotifierProvider<MyNotifier, MyState>(...);

// ✅ 代わりにNotifierProviderを使用
import 'package:riverpod_annotation/riverpod_annotation.dart';

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  
  void increment() => state++;
}
```

**1.2 Refのサブクラスの廃止**
```dart
// ❌ 廃止
FutureProviderRef<int> ref;
StreamProviderRef<String> ref;

// ✅ 統一
Ref ref;
```

**1.3 AsyncValue の変更**
```dart
// ❌ 削除
asyncValue.valueOrNull

// ✅ 使用
asyncValue.value  // エラー時はnullを返す

// ❌ 変更
asyncValue.value  // 以前はエラー時に例外をスロー

// ✅ 新機能
asyncValue.retrying  // リトライ中かどうかをチェック
```

**1.4 Notifierのライフサイクル変更**
- プロバイダが再ビルドされるたびに新しいNotifierインスタンスが作成される
- `Ref.mounted` を使用してプロバイダが破棄されたかチェック可能

```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  MyState build() {
    // 初期化処理
    ref.onDispose(() {
      // クリーンアップ処理
    });
    return MyState();
  }
  
  Future<void> someAsyncMethod() async {
    // 処理...
    if (!ref.mounted) return;  // 破棄済みならreturn
    state = newState;
  }
}
```

**1.5 自動リトライ機能**
- 失敗したプロバイダは自動的にリトライされる（設定可能）

**1.6 等価性チェックの変更**
- すべてのプロバイダが `==` を使用して前の値と新しい値を比較
- 以前の動作に戻す場合は `updateShouldNotify` をオーバーライド

**1.7 テスト機能の改善**
```dart
// ✅ 新しいテストヘルパー
final container = ProviderContainer.test();

// ✅ buildメソッドのみをモック化
provider.overrideWithBuild((ref) => MyState());
```

#### 影響を受けるコード
プロジェクト内では以下のファイルで `StateNotifier` を使用している可能性があります：
- `lib/state/home_calendar_state.dart`
- `lib/state/tag_new_state.dart`
- `lib/state/theme_mode_state.dart`
- `lib/state/purchase_new_state.dart`
- その他 `lib/state/` 配下のファイル

### 2. go_router 15.0 / 16.0 / 17.0

#### 15.0.0 の変更
**URLが大文字小文字を区別するように変更**
```dart
// ❌ 以前は同一として扱われた
/home == /Home == /HOME

// ✅ 15.0以降は別のルートとして扱われる
/home != /Home != /HOME

// 必要に応じて無効化可能
GoRouter(
  caseSensitive: false,  // 以前の動作に戻す
  // ...
)
```

#### 16.0.0 の変更
**GoRouteData の拡張**
- `.location`, `.go(context)`, `.push(context)`, `.pushReplacement(context)`, `.replace(context)` が追加
- Type-safe routing の強化
- **go_router_builder >= 3.0.0** が必要

#### 17.0.0 の変更
**ShellRoute のオブザーバー通知**
```dart
// ⚠️ Breaking: ShellRouteのナビゲーション変更がデフォルトでGoRouterのオブザーバーに通知される

// 以前の動作に戻す場合
ShellRoute(
  notifyRootObserver: false,  // 追加
  // ...
)
```

#### 影響を受けるコード
- `lib/router.dart` - StatefulShellRouteの設定

### 3. flutter_lints 6.0

#### 追加されるLintルール
1. **`strict_top_level_inference`** - トップレベル変数の型推論を厳格化
2. **`unnecessary_underscores`** - 不要なアンダースコアを警告

#### Dart SDKの最低バージョン要件
- **Flutter 3.32 / Dart 3.8** 以上が必要

---

## 📝 アップデート手順

### ステップ 1: バックアップとブランチ作成

```bash
# 現在の状態をコミット
cd /home/yano/Documents/loutine/mobile_ui
git status
git add .
git commit -m "chore: commit before upgrade"

# アップデート用ブランチを作成
git checkout -b feature/upgrade-flutter-and-deps
```

### ステップ 2: Flutter SDKのアップデート

```bash
# 最新のFlutter stableをインストール
fvm install 3.38.5

# プロジェクトのFlutterバージョンを変更
fvm use 3.38.5

# .fvmrcが更新されることを確認
cat .fvmrc
```

### ステップ 3: 依存関係の更新（段階的アプローチ推奨）

#### オプション A: 段階的更新（推奨）

**3-A-1: パッチ/マイナー更新のみ実行**
```bash
# pubspec.yamlを編集せずに、制約内で更新
fvm flutter pub upgrade

# ビルドとテスト
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter analyze
fvm flutter test
```

**3-A-2: Riverpodを3.xにアップデート**
```bash
# pubspec.yamlを編集
# flutter_riverpod: ^3.1.0
# riverpod_annotation: ^4.0.0

# dev_dependencies
# riverpod_generator: ^4.0.0+1
# riverpod_lint: ^3.1.0

fvm flutter pub upgrade
```

この時点で `StateNotifier` を使用しているコードの移行が必要です（後述）。

**3-A-3: go_routerをアップデート**
```bash
# pubspec.yamlを編集
# go_router: ^17.0.1

fvm flutter pub upgrade
```

**3-A-4: flutter_lintsをアップデート**
```bash
# pubspec.yamlを編集
# dev_dependencies:
#   flutter_lints: ^6.0.0

fvm flutter pub upgrade
fvm flutter analyze
```

新しいLintエラーに対応します。

**3-A-5: 残りのパッケージをアップデート**
```bash
# pubspec.yamlを編集して全ての依存関係を最新版に更新
# http: ^1.6.0
# shared_preferences: ^2.5.4
# url_launcher: ^6.3.2
# flutter_launcher_icons: ^0.14.4
# build_runner: ^2.10.4
# custom_lint: ^0.8.1

fvm flutter pub upgrade
```

#### オプション B: 一括更新

```bash
# pubspec.yamlを一度に全て更新してから実行
fvm flutter pub upgrade --major-versions

# ⚠️ この方法は多くのエラーが一度に発生する可能性があります
```

### ステップ 4: コード移行

#### 4.1 StateNotifier → Notifier への移行

**Before (StateNotifier):**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CalendarState {
  CalendarState({
    required this.calendarEvents,
    required this.linkList,
  });
  Map<DateTime, List<CalendarEventItem>> calendarEvents;
  List<Link> linkList;
}

class CalendarStateNotifier extends StateNotifier<CalendarState> {
  CalendarStateNotifier() : super(CalendarState(calendarEvents: {}, linkList: []));

  Future<void> getAllEventItem(DateTime dateTime) async {
    final linkList = await getLinkList(dateTime);
    // ...
    state = CalendarState(calendarEvents: newEvents, linkList: linkList);
  }
}

final calendarStateProvider = StateNotifierProvider<CalendarStateNotifier, CalendarState>((ref) {
  return CalendarStateNotifier();
});
```

**After (Notifier with riverpod_annotation):**
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_calendar_state.g.dart';

class CalendarState {
  CalendarState({
    required this.calendarEvents,
    required this.linkList,
  });
  Map<DateTime, List<CalendarEventItem>> calendarEvents;
  List<Link> linkList;
}

@riverpod
class CalendarStateNotifier extends _$CalendarStateNotifier {
  @override
  CalendarState build() {
    return CalendarState(calendarEvents: {}, linkList: []);
  }

  Future<void> getAllEventItem(DateTime dateTime) async {
    final linkList = await getLinkList(dateTime);
    // ...
    if (!ref.mounted) return;  // 破棄チェック
    state = CalendarState(calendarEvents: newEvents, linkList: linkList);
  }
}
```

**使用側の変更:**
```dart
// ❌ Before
ref.read(calendarStateProvider.notifier).getAllEventItem(DateTime.now());
final state = ref.watch(calendarStateProvider);

// ✅ After
ref.read(calendarStateNotifierProvider.notifier).getAllEventItem(DateTime.now());
final state = ref.watch(calendarStateNotifierProvider);
```

#### 4.2 コード生成の実行

```bash
# 全てのコード生成ファイルを再生成
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

#### 4.3 go_router の caseSensitive 設定

```dart
// lib/router.dart
final router = GoRouter(
  caseSensitive: true,  // 明示的に指定（デフォルトはtrue）
  // または false にして以前の動作を保持
  // ...
);
```

### ステップ 5: ビルドとテスト

```bash
# 依存関係の取得
fvm flutter pub get

# 静的解析
fvm flutter analyze

# テスト実行
fvm flutter test

# ビルド確認
fvm flutter build apk --debug
# または
fvm flutter build ios --debug
```

### ステップ 6: Lint エラーの修正

新しい Lint ルールによるエラーを修正します。

```bash
# Lint エラーの確認
fvm flutter analyze

# 自動修正可能なものを修正
dart fix --apply
```

### ステップ 7: 動作確認

1. アプリを起動して基本機能を確認
2. 各画面の遷移を確認
3. 状態管理が正常に動作することを確認
4. ルーティングが正常に動作することを確認

### ステップ 8: コミットとPR

```bash
git add .
git commit -m "feat: upgrade Flutter to 3.38.5 and dependencies

- Upgrade Flutter SDK from 3.24.3 to 3.38.5
- Upgrade Riverpod from 2.6.x to 3.1.0/4.0.0
- Migrate StateNotifier to Notifier with riverpod_annotation
- Upgrade go_router from 14.8.0 to 17.0.1
- Upgrade flutter_lints from 5.0.0 to 6.0.0
- Update other dependencies to latest versions"

git push origin feature/upgrade-flutter-and-deps
```

---

## 🔍 トラブルシューティング

### ビルドエラーが発生する場合

```bash
# キャッシュをクリア
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner clean
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### FVMがFlutterを見つけられない場合

```bash
# FVMのグローバル設定を確認
fvm global 3.38.5

# または環境変数を設定
export PATH="$HOME/.fvm/versions/3.38.5/bin:$PATH"
```

### Riverpod のコード生成エラー

```bash
# 既存の生成ファイルを全て削除
find . -name "*.g.dart" -delete

# 再生成
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

### Lint エラーが多数発生する場合

```bash
# 一時的にLintを無効化して段階的に修正
# analysis_options.yaml に以下を追加
# linter:
#   rules:
#     strict_top_level_inference: false
#     unnecessary_underscores: false
```

---

## 📚 参考リンク

### 公式ドキュメント
- [Riverpod 3.0 Migration Guide](https://riverpod.dev/docs/whats_new)
- [go_router Migration to 15.0.0](https://flutter.dev/go/go-router-v15-breaking-changes)
- [Flutter Release Notes](https://docs.flutter.dev/release/release-notes)

### Changelog
- [Riverpod Changelog](https://github.com/rrousselGit/riverpod/blob/master/packages/flutter_riverpod/CHANGELOG.md)
- [go_router Changelog](https://github.com/flutter/packages/blob/main/packages/go_router/CHANGELOG.md)
- [flutter_lints Changelog](https://github.com/flutter/packages/blob/main/packages/flutter_lints/CHANGELOG.md)

---

## ⚠️ 注意事項

1. **テストの重要性**: 特にRiverpodの移行は影響範囲が広いため、十分なテストが必要です
2. **段階的な更新**: 一度に全てを更新せず、パッケージごとに更新して動作確認することを推奨
3. **バックアップ**: 更新前に必ず現在の状態をコミットまたはバックアップしてください
4. **チーム共有**: FVMのバージョンを `.fvmrc` で管理しているため、チームメンバーも同じバージョンを使用する必要があります

---

## ✅ チェックリスト

アップデート完了後、以下を確認してください：

- [ ] Flutter SDKが3.38.5にアップデートされた
- [ ] `.fvmrc` が更新された
- [ ] 全ての依存関係が最新版になった
- [ ] `pubspec.lock` が更新された
- [ ] StateNotifierがNotifierに移行された
- [ ] コード生成ファイル（.g.dart）が再生成された
- [ ] `flutter analyze` がエラーなく完了する
- [ ] `flutter test` が全て成功する
- [ ] アプリが正常にビルドできる
- [ ] 各画面の動作確認が完了した
- [ ] ルーティングが正常に動作する
- [ ] 状態管理が正常に動作する
- [ ] 変更がコミットされた

---

**最終更新**: 2026-01-07  
**作成者**: GitHub Copilot CLI
