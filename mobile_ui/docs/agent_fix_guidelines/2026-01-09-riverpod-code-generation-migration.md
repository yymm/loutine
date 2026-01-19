# Riverpod コードジェネレーター移行ガイド

**作成日**: 2026-01-09  
**対象**: Riverpod初学者〜中級者  
**目的**: 手動実装からコードジェネレーター(`@riverpod`)への段階的移行

---

## 📚 背景知識

### Riverpodとは？

Riverpodは、Flutterの状態管理ライブラリです。現在、2つの書き方があります：

1. **手動実装** (従来の方法)
   - `StateNotifierProvider`, `NotifierProvider`などを手動で定義
   - ボイラープレートが多い
   - タイプミスのリスクあり

2. **コードジェネレーター** (推奨の方法) 👈 **これに移行します**
   - `@riverpod`アノテーションを使用
   - 自動でコード生成
   - タイプセーフ
   - 公式ドキュメント推奨

### なぜコードジェネレーターを使うべきか？

公式ドキュメント ([About code generation](https://riverpod.dev/docs/concepts/about_code_generation)) より：

> **Should I use code generation?**
> 
> Riverpod is designed with code-generation in mind. By using code-generation, you will:
> - Get better syntax, more readable and flexible
> - Get better auto-complete in your IDE
> - Get better error messages
> - Remove some common usage mistakes

**メリット**:
- ✅ **構文がシンプル**: ボイラープレートが減る
- ✅ **IDEの補完が充実**: 開発効率UP
- ✅ **エラーメッセージが分かりやすい**
- ✅ **よくある間違いを防げる**: コンパイル時にチェック
- ✅ **パラメータ付きProvider (Family)** が簡潔に書ける
- ✅ **AutoDispose** の制御が簡単

---

## 🔍 現在のプロジェクト状況

### 依存関係

すでに必要なパッケージは**インストール済み**です (`pubspec.yaml`):

```yaml
dependencies:
  flutter_riverpod: ^2.6.1          # Riverpod本体
  riverpod_annotation: ^2.6.1       # アノテーション定義

dev_dependencies:
  riverpod_generator: ^2.6.3        # コード生成器
  build_runner: ^2.4.13              # ビルドツール
  riverpod_lint: ^2.6.3              # Lintルール
  custom_lint: ^0.7.0                # カスタムLint
```

### 移行対象ファイル一覧

```
lib/state/
├── category_new_state.dart        ← シンプル (Notifier × 2個)
├── tag_new_state.dart             ← シンプル (Notifier × 2個)
├── purchase_new_state.dart        ← StateNotifier
├── link_new_state.dart            ← StateNotifier (非同期処理あり)
├── category_list_state.dart       ← StateNotifier + FutureProvider
├── tag_list_state.dart            ← StateNotifier + FutureProvider
├── home_calendar_state.dart       ← 複雑 (複数Notifier + StateNotifier)
├── theme_mode_state.dart          ← StateNotifier (SharedPreferences使用)
└── note_new_state.dart            ← 空ファイル
```

**推奨移行順序**: 
1. `tag_new_state.dart` (最もシンプル) ⭐️ **ここから開始**
2. `category_new_state.dart`
3. `purchase_new_state.dart`
4. 他のファイル...

---

## 🎯 移行例: `tag_new_state.dart`

### STEP 1: 現在のコード (移行前)

```dart
// lib/state/tag_new_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 手動実装: Notifierクラスを自分で定義
class TagNewNameNotifier extends Notifier<String> {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}

class TagNewDescriptionNotifier extends Notifier<String> {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}

// 手動実装: Providerも自分で定義
final tagNewNameNotifierProvider
  = NotifierProvider<TagNewNameNotifier, String>(TagNewNameNotifier.new);

final tagNewDescriptionNotifierProvider
  = NotifierProvider<TagNewDescriptionNotifier, String>(TagNewDescriptionNotifier.new);
```

**問題点**:
- Providerの定義が冗長 (型を2回書いている)
- クラス名とProvider名を別々に管理
- タイプミスのリスク

---

### STEP 2: コードジェネレーター版に書き換え

```dart
// lib/state/tag_new_state.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 重要: この行を追加 (生成されるファイルを指定)
part 'tag_new_state.g.dart';

// @riverpodアノテーションを追加
// クラス名の先頭に _ は不要
@riverpod
class TagNewName extends _$TagNewName {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}

@riverpod
class TagNewDescription extends _$TagNewDescription {
  @override
  String build() => '';

  void change(String v) => state = v;

  void reset() => state = '';
}

// Providerの手動定義は不要！
// 自動生成される名前: tagNewNameProvider, tagNewDescriptionProvider
```

**変更点の説明**:

1. **importの変更**
   ```dart
   // 前: flutter_riverpod
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   
   // 後: riverpod_annotation
   import 'package:riverpod_annotation/riverpod_annotation.dart';
   ```

2. **part宣言を追加**
   ```dart
   part 'tag_new_state.g.dart';  // 生成されるファイル名
   ```
   - `.g.dart`ファイルが自動生成されます
   - このファイルにProviderの定義が含まれます

3. **@riverpodアノテーションを追加**
   ```dart
   @riverpod  // これを追加
   class TagNewName extends _$TagNewName {  // 継承元が変わる
   ```

4. **継承元クラスが変わる**
   ```dart
   // 前: extends Notifier<String>
   // 後: extends _$TagNewName
   ```
   - `_$`で始まるクラスはコードジェネレーターが自動生成
   - 実際のNotifierの型情報は自動推論されます

5. **Provider定義は不要**
   - 自動で`tagNewNameProvider`が生成されます
   - 命名規則: クラス名の頭文字を小文字 + `Provider`

---

### STEP 3: コードを生成

ターミナルで以下のコマンドを実行:

```bash
# ワンショット生成
dart run build_runner build --delete-conflicting-outputs

# または、監視モード (ファイル保存時に自動生成)
dart run build_runner watch --delete-conflicting-outputs
```

**オプション説明**:
- `build`: 一度だけ生成
- `watch`: ファイル変更を監視して自動生成
- `--delete-conflicting-outputs`: 既存の`.g.dart`を削除してから生成

**成功すると**:
```
lib/state/tag_new_state.g.dart  ← このファイルが生成される
```

---

### STEP 4: 生成されたコードを確認

`lib/state/tag_new_state.g.dart` (自動生成・編集禁止):

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_new_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tagNewNameHash() => r'...';

/// See also [TagNewName].
@ProviderFor(TagNewName)
final tagNewNameProvider =
    AutoDisposeNotifierProvider<TagNewName, String>.internal(
  TagNewName.new,
  name: r'tagNewNameProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$tagNewNameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TagNewName = AutoDisposeNotifier<String>;

// ... TagNewDescription も同様に生成される
```

**ポイント**:
- `tagNewNameProvider`が自動生成されている
- デフォルトで`AutoDisposeNotifier`になる (使われなくなったら自動破棄)
- このファイルは**絶対に手動編集しない**

---

### STEP 5: UI側のコードを更新

**変更不要です！** Provider名は同じなので、既存のUIコードはそのまま動きます。

```dart
// lib/ui/tag/tag_new_widget.dart
// これらは変更不要
ref.watch(tagNewNameProvider)
ref.read(tagNewNameProvider.notifier).change('新しい名前')
ref.read(tagNewDescriptionProvider.notifier).reset()
```

---

## 🔧 よくあるパターン

### パターン1: シンプルなNotifier (今回の例)

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;  // 初期値

  void increment() => state++;
  void decrement() => state--;
}

// 使用: counterProvider
```

### パターン2: 非同期データの取得

```dart
@riverpod
Future<List<User>> userList(UserListRef ref) async {
  final apiClient = UserApiClient();
  return apiClient.fetchUsers();
}

// 使用: userListProvider (FutureProviderとして機能)
```

### パターン3: パラメータ付き (Family)

```dart
@riverpod
Future<User> user(UserRef ref, int userId) async {
  final apiClient = UserApiClient();
  return apiClient.fetchUser(userId);
}

// 使用: userProvider(123)  ← パラメータを渡せる
```

### パターン4: AutoDisposeを無効化

```dart
@Riverpod(keepAlive: true)  // 破棄されない
class GlobalSettings extends _$GlobalSettings {
  @override
  Settings build() => Settings();
}
```

---

## ⚙️ build_runnerコマンド集

```bash
# 1回だけ生成 (通常はこれ)
dart run build_runner build --delete-conflicting-outputs

# 監視モード (開発中に便利)
dart run build_runner watch --delete-conflicting-outputs

# 生成ファイルをクリーンアップ
dart run build_runner clean

# 強制的に再生成
dart run build_runner build --delete-conflicting-outputs --verbose
```

---

## 🚨 トラブルシューティング

### エラー1: `part of 'xxx.dart';`が見つからない

```
Error: Can't use 'tag_new_state.g.dart' as a part, because it has no 'part of' directive.
```

**解決策**: `part 'tag_new_state.g.dart';`を追加し忘れています。

---

### エラー2: Conflicting outputs

```
[WARNING] Conflicting outputs were detected...
```

**解決策**: `--delete-conflicting-outputs`オプションを付ける。

---

### エラー3: Provider名が変わった

生成されるProvider名:
- クラス名: `TagNewName` → Provider名: `tagNewNameProvider`
- クラス名: `UserList` → Provider名: `userListProvider`

**ルール**: キャメルケース + `Provider`

---

## ✅ 移行チェックリスト

`tag_new_state.dart`を移行する場合:

- [x] `import 'package:riverpod_annotation/riverpod_annotation.dart';`に変更
- [x] `part 'tag_new_state.g.dart';`を追加
- [x] クラスに`@riverpod`アノテーションを追加
- [x] `extends Notifier<T>` → `extends _$ClassName`に変更
- [x] 手動のProvider定義を削除
- [x] `dart run build_runner build --delete-conflicting-outputs`を実行
- [x] `.g.dart`ファイルが生成されたことを確認
- [ ] アプリをビルドしてエラーがないか確認
- [ ] 動作確認 (UIで状態が正しく更新されるか)

---

## 📖 参考リンク

- [公式: About code generation](https://riverpod.dev/docs/concepts/about_code_generation)
- [公式: Getting started with code generation](https://riverpod.dev/docs/introduction/getting_started#enabling-riverpod_generatorriverpod_lint)
- [公式: Migrating from non-code generation](https://riverpod.dev/docs/concepts/about_code_generation#migrate-from-non-code-generation-variant)

---

## 🎯 次のステップ

1. **このガイドで`tag_new_state.dart`を移行**
2. **同じ要領で`category_new_state.dart`を移行**
3. **より複雑なStateNotifierの移行に挑戦** (`purchase_new_state.dart`など)

---

## 💡 実践例: tag_new_state.dartの完全な移行手順

### 手順1: ファイルを編集

```bash
# エディタで lib/state/tag_new_state.dart を開く
```

### 手順2: コードを書き換える

上記の「STEP 2」の新しいコードに置き換え。

### 手順3: コード生成

```bash
cd /home/yano/Documents/loutine/mobile_ui
dart run build_runner build --delete-conflicting-outputs
```

### 手順4: 確認

```bash
# 生成されたか確認
ls -l lib/state/tag_new_state.g.dart

# アプリをビルド
flutter build apk --debug
# または
flutter run
```

### 手順5: 動作確認

- タグ作成画面を開く
- 名前・説明を入力
- 正しく動作するか確認

---

## 📝 まとめ

| 項目 | 手動実装 | コードジェネレーター |
|------|----------|---------------------|
| import | `flutter_riverpod` | `riverpod_annotation` |
| Provider定義 | 手動 | 自動生成 |
| 継承 | `Notifier<T>` | `_$ClassName` |
| ボイラープレート | 多い | 少ない |
| タイプセーフ性 | 普通 | 高い |
| 学習コスト | 低い | やや高い |
| 公式推奨 | ❌ | ✅ |

**結論**: 初期学習は必要ですが、長期的にはコードジェネレーターの方が保守しやすいコードになります。
