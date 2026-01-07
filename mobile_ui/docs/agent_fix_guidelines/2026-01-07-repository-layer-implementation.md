# Repository層の導入ガイドライン

## 目的
API層とState層の間にRepository層を導入し、以下を実現する:
- JSON変換処理をState層から分離し、責務を明確化
- 将来のプロトコル変更（GraphQL/gRPC等）への対応を容易にする
- シンプルさを維持しながらテスタビリティを向上させる

## 基本方針
- **DTOは作らない**: 現状のModelをそのまま使用（Too Muchを避ける）
- **fromJsonは活用**: 既存の`fromJson`factoryメソッドを継続使用
- **フラットな構造**: フォルダ分けは不要、`lib/api/`配下にRepositoryファイルを配置
- **段階的導入**: 新規実装から適用し、既存コードは必要に応じてリファクタリング

## アーキテクチャ構造

### 変更前
```
State層 -> API Client (String返却) -> JSON decode -> Model変換 -> State層
```

### 変更後
```
State層 -> Repository (Model返却) -> API Client -> JSON decode -> Model変換 -> Repository
```

## 実装パターン

### 1. Repository実装例

```dart
// lib/api/category_repository.dart
import 'dart:convert';
import 'package:mobile_ui/api/vanilla_api.dart';
import 'package:mobile_ui/models/category.dart';

class CategoryRepository {
  final CategoryApiClient _client = CategoryApiClient();

  /// カテゴリ一覧を取得
  Future<List<Category>> getCategories() async {
    final resBody = await _client.list();
    final List<dynamic> json = jsonDecode(resBody);
    return json.map((e) => Category.fromJson(e)).toList();
  }

  /// カテゴリを作成
  Future<Category> createCategory(String name, String description) async {
    final resBody = await _client.post(name, description);
    final json = jsonDecode(resBody);
    return Category.fromJson(json);
  }
}
```

### 2. State層の実装例

```dart
// lib/state/category_list_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_ui/api/category_repository.dart';
import 'package:mobile_ui/models/category.dart';

class CategoryListNotifier extends StateNotifier<List<Category>> {
  final CategoryRepository _repository = CategoryRepository();
  
  CategoryListNotifier() : super([]);

  Future<void> add(String name, String description) async {
    final category = await _repository.createCategory(name, description);
    state = [...state, category];
  }

  Future<List<Category>> getList() async {
    final categories = await _repository.getCategories();
    state = categories;
    return categories;
  }
}

final categoryListProvider = StateNotifierProvider<CategoryListNotifier, List<Category>>(
  (ref) => CategoryListNotifier()
);

final categoryListFutureProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  return ref.read(categoryListProvider.notifier).getList();
});
```

### 3. パターン別実装ガイド

#### パターンA: 単一オブジェクト返却（作成・取得）
```dart
Future<Category> createCategory(String name, String description) async {
  final resBody = await _client.post(name, description);
  return Category.fromJson(jsonDecode(resBody));
}
```

#### パターンB: リスト返却（一覧取得）
```dart
Future<List<Tag>> getTags() async {
  final resBody = await _client.list();
  final List<dynamic> json = jsonDecode(resBody);
  return json.map((e) => Tag.fromJson(e)).toList();
}
```

#### パターンC: 日付範囲付き取得
```dart
Future<List<Link>> getLinks(DateTime startDate, DateTime endDate) async {
  final resBody = await _client.list(startDate, endDate);
  final List<dynamic> json = jsonDecode(resBody);
  return json.map((e) => Link.fromJson(e)).toList();
}
```

#### パターンD: オプショナルパラメータ
```dart
Future<Purchase> createPurchase(double cost, String title, int? categoryId) async {
  final resBody = await _client.post(cost, title, categoryId);
  return Purchase.fromJson(jsonDecode(resBody));
}
```

## ファイル命名規則
- `{entity}_repository.dart`: 例 `category_repository.dart`, `tag_repository.dart`
- 配置場所: `lib/api/`配下（既存のAPI Clientと同じフォルダ）

## 移行手順

### ステップ1: Repository作成
1. `lib/api/{entity}_repository.dart`を作成
2. 既存のAPI Clientをprivateフィールドとして保持
3. 必要なメソッドを実装（get, create, update等）

### ステップ2: State層の修正
1. API Clientへの直接参照を削除
2. Repositoryインスタンスを生成
3. `jsonDecode`と`fromJson`の呼び出しを削除（Repositoryに移譲）

### ステップ3: 動作確認
1. 既存のUIが正常に動作することを確認
2. データの取得・作成が問題なく行えることを確認

## 実装対象リスト

現在のAPIに対して以下のRepositoryを作成する:

- [ ] `category_repository.dart`
  - `Future<List<Category>> getCategories()`
  - `Future<Category> createCategory(String name, String description)`
  
- [ ] `tag_repository.dart`
  - `Future<List<Tag>> getTags()`
  - `Future<Tag> createTag(String name, String description)`
  
- [ ] `link_repository.dart`
  - `Future<List<Link>> getLinks(DateTime startDate, DateTime endDate)`
  - `Future<Link> createLink(String url, String title, List<int> tagIds)`
  
- [ ] `purchase_repository.dart`
  - `Future<List<Purchase>> getPurchases(DateTime startDate, DateTime endDate)`
  - `Future<Purchase> createPurchase(double cost, String title, int? categoryId)`
  
- [ ] `note_repository.dart`
  - `Future<List<Note>> getNotes(DateTime startDate, DateTime endDate)`
  - `Future<Note> createNote(String text, String title, List<int> tagIds)`
  
- [ ] `url_repository.dart`
  - `Future<String> getTitleFromUrl(String url)`

## エラーハンドリング

現状はAPI Client内で`StateError`をthrowしているため、Repositoryはそのまま伝播させる:

```dart
Future<Category> createCategory(String name, String description) async {
  // API Clientが投げるStateErrorはそのまま伝播
  final resBody = await _client.post(name, description);
  return Category.fromJson(jsonDecode(resBody));
}
```

将来的により詳細なエラーハンドリングが必要になった場合は、Repository層で統一的に処理を追加することを検討。

## DTO分離が必要になる判断基準

現時点ではDTO不要だが、以下の状況が発生した場合は分離を検討:

1. `fromJson`内のロジックが10行を超える
2. 複数APIレスポンスの結合が必要
3. UI用の計算プロパティが3つ以上必要
4. APIとModelの構造に大きなギャップが発生（例: 単位変換、フォーマット変換）
5. GraphQL/gRPC移行を本格的に決定

## テスト戦略

Repository層導入により、モックが容易になる:

```dart
// テスト用のMock Repository
class MockCategoryRepository extends CategoryRepository {
  @override
  Future<List<Category>> getCategories() async {
    return [
      Category(id: 1, name: 'Test', description: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
    ];
  }
}
```

State層のテスト時にMock Repositoryを注入することで、API呼び出しなしでテスト可能。

## 参考: 既存のState層実装

移行前の実装例（参考用）:
```dart
// 変更前: State層でJSON処理を実施
Future<void> add(String name, String description) async {
  CategoryApiClient apiClient = CategoryApiClient();
  final resBody = await apiClient.post(name, description);
  final Map<String, dynamic> decodedString = json.decode(resBody);
  final category = Category.fromJson(decodedString);
  state = [...state, category];
}
```

移行後:
```dart
// 変更後: Repository層がModel返却
Future<void> add(String name, String description) async {
  final category = await _repository.createCategory(name, description);
  state = [...state, category];
}
```

## まとめ

- Repository層はAPI ClientとState層の橋渡し役
- JSON処理の責務を集約し、State層をシンプルに保つ
- プロトコル変更時はRepository内部のみ修正すればよい
- 現在の規模ではDTOは不要、シンプルさを維持
