# Purchase-Category関連のBackend実装パターン評価

**作成日**: 2026-02-24  
**対象**: PurchaseモデルにCategory情報を含める実装パターンの評価

## 現状の確認

### Backend (TypeScript + Drizzle ORM)
- **DB**: SQLite
- **Schema**: `purchases.category_id` は既に存在（外部キー）
- **現在のAPI**: `category_id`のみ返す（JOINなし）
- **Usecase**: `get_date_range()`, `get_by_id()` で `purchases` テーブルのみ取得

### Frontend (Flutter)
- **Purchaseモデル**: `category_id` フィールドなし
- **CalendarEventItem**: `category` フィールドあり（未使用）
- **CategoryListProvider**: 全カテゴリを取得可能

---

## パターン比較

### パターン1: category_idのみ返す

**Backend実装**:
```typescript
// 現在の実装のまま（変更不要）
async get_date_range(start_date: string, end_date: string) {
  const all_purchases = await this.db
    .select()
    .from(purchases)
    .where(...)
    .all();
  return all_purchases; // { id, title, cost, category_id, ... }
}
```

**Frontend実装**:
```dart
// Purchase model
class Purchase {
  required int id,
  required String title,
  required int cost,
  int? categoryId,  // 追加
  ...
}

// UI layer: カテゴリ名が必要な場合
final categoryList = ref.watch(categoryListProvider);
final category = categoryList.value?.firstWhere(
  (c) => c.id == purchase.categoryId
);
```

**メリット**:
- ✅ **最小限の変更**: Backend側は変更不要
- ✅ **軽量なレスポンス**: 必要最小限のデータのみ転送
- ✅ **キャッシュ効率**: カテゴリ一覧は一度取得すれば再利用可能
- ✅ **正規化されたデータ**: カテゴリマスタの更新が即座に反映
- ✅ **柔軟性**: Frontend側でカテゴリ情報の取得タイミングを制御可能

**デメリット**:
- ❌ **Frontend側で紐付け処理が必要**: `categoryId` → `Category` の変換
- ❌ **N+1的な考慮**: UI層でカテゴリリストとの突き合わせが必要
- ❌ **カテゴリ未取得時のハンドリング**: カテゴリリストが未ロードの場合の対応

**実装工数**: ★☆☆☆☆ (低)
- Backend: 変更なし
- Frontend: Purchase modelに `categoryId` 追加のみ

---

### パターン2: JOINしてcategoryデータすべてを返す

**Backend実装**:
```typescript
async get_date_range(start_date: string, end_date: string) {
  const all_purchases = await this.db
    .select({
      id: purchases.id,
      title: purchases.title,
      cost: purchases.cost,
      created_at: purchases.created_at,
      updated_at: purchases.updated_at,
      category: {
        id: categories.id,
        name: categories.name,
        description: categories.description,
        created_at: categories.created_at,
        updated_at: categories.updated_at,
      }
    })
    .from(purchases)
    .leftJoin(categories, eq(purchases.category_id, categories.id))
    .where(...)
    .all();
  return all_purchases;
}
```

**レスポンス例**:
```json
[
  {
    "id": 1,
    "title": "ランチ",
    "cost": 1000,
    "created_at": "2026-02-24T12:00:00Z",
    "updated_at": "2026-02-24T12:00:00Z",
    "category": {
      "id": 3,
      "name": "食費",
      "description": "食事代",
      "created_at": "2026-01-01T00:00:00Z",
      "updated_at": "2026-01-01T00:00:00Z"
    }
  },
  {
    "id": 2,
    "title": "電車代",
    "cost": 500,
    "category": null  // カテゴリ未設定の場合
  }
]
```

**Frontend実装**:
```dart
// Purchase model
class Purchase {
  required int id,
  required String title,
  required int cost,
  Category? category,  // ネストされたオブジェクト
  ...
}

// UI layer: カテゴリ名が直接取得可能
Text(purchase.category?.name ?? '未分類')
```

**メリット**:
- ✅ **Frontend実装がシンプル**: カテゴリ情報が即座に利用可能
- ✅ **データ整合性**: 取得時点のカテゴリ情報が確実に紐付いている
- ✅ **N+1問題の回避**: Backend側で1回のクエリで解決
- ✅ **null安全**: カテゴリ未設定の場合も明示的に `null` で表現

**デメリット**:
- ❌ **レスポンスサイズ増大**: 同じカテゴリ情報が複数のpurchaseで重複
- ❌ **Backend実装コスト**: JOIN処理の実装が必要
- ❌ **非正規化データ**: カテゴリ名変更時、過去のpurchaseには反映されない（※取得時点の情報）
- ❌ **オーバーフェッチング**: カテゴリの`description`, `created_at`, `updated_at`は不要な場合が多い

**実装工数**: ★★★☆☆ (中)
- Backend: JOIN処理実装、型定義変更
- Frontend: Purchase modelにネストされた `category` 追加

---

### パターン3: category_idとcategory_nameのみ返す（ハイブリッド）

**Backend実装**:
```typescript
async get_date_range(start_date: string, end_date: string) {
  const all_purchases = await this.db
    .select({
      id: purchases.id,
      title: purchases.title,
      cost: purchases.cost,
      created_at: purchases.created_at,
      updated_at: purchases.updated_at,
      category_id: purchases.category_id,
      category_name: categories.name,  // 最小限のJOIN
    })
    .from(purchases)
    .leftJoin(categories, eq(purchases.category_id, categories.id))
    .where(...)
    .all();
  return all_purchases;
}
```

**レスポンス例**:
```json
[
  {
    "id": 1,
    "title": "ランチ",
    "cost": 1000,
    "created_at": "2026-02-24T12:00:00Z",
    "updated_at": "2026-02-24T12:00:00Z",
    "category_id": 3,
    "category_name": "食費"
  }
]
```

**Frontend実装**:
```dart
// Purchase model
class Purchase {
  required int id,
  required String title,
  required int cost,
  int? categoryId,
  String? categoryName,  // 表示用
  ...
}

// UI layer
Text(purchase.categoryName ?? '未分類')

// 詳細なカテゴリ情報が必要な場合のみ
final category = categoryList.firstWhere((c) => c.id == purchase.categoryId);
```

**メリット**:
- ✅ **レスポンスコンパクト**: 表示に必要な最小限の情報のみ
- ✅ **Frontend実装簡易**: カテゴリ名は即座に利用可能
- ✅ **柔軟性**: `category_id`もあるため詳細情報取得も可能
- ✅ **実装コスト適度**: パターン2より簡単

**デメリット**:
- ❌ **半正規化**: `category_id`と`category_name`の二重管理
- ❌ **Backend実装必要**: JOIN処理は必要
- ⚠️ **用途が限定的**: カテゴリのdescriptionやアイコンが必要な場合は不足

**実装工数**: ★★☆☆☆ (中低)
- Backend: 軽量なJOIN処理実装
- Frontend: Purchase modelに2フィールド追加

---

### パターン4: GraphQL的アプローチ（将来案）

**概要**: クライアントが必要なフィールドを指定してリクエスト

```
GET /purchases?start_date=...&end_date=...&fields=id,title,cost,category{id,name}
```

**メリット**:
- ✅ **最適化**: 必要なデータのみ取得
- ✅ **柔軟性**: 用途に応じて取得内容を変更可能

**デメリット**:
- ❌ **実装コスト大**: GraphQLサーバーまたは類似機能の実装
- ❌ **オーバーエンジニアリング**: 現状の規模では不要

**実装工数**: ★★★★★ (非常に高)

---

## 推奨案: **パターン1** (category_idのみ)

### 推奨理由

1. **現在のアーキテクチャに適合**
   - 既存の設計思想（Repository/Provider分離）に沿っている
   - カテゴリマスタは `CategoryListProvider` で一元管理

2. **実装コストが最小**
   - Backend側は変更不要
   - Frontendは `Purchase` モデルに1フィールド追加のみ

3. **保守性が高い**
   - カテゴリマスタの更新が即座に全UIに反映
   - データの正規化が保たれる

4. **スケーラビリティ**
   - カテゴリ数が増えてもレスポンスサイズに影響なし
   - キャッシュ戦略が明確（カテゴリは長期キャッシュ可能）

5. **Flutter/Riverpodのベストプラクティス**
   - Providerでマスタデータを管理する一般的なパターン
   - UI層で必要に応じてデータを組み合わせる設計

### 実装イメージ

**1. Purchase modelの拡張**:
```dart
@freezed
abstract class Purchase with _$Purchase {
  const factory Purchase({
    required int id,
    required String title,
    required int cost,
    @JsonKey(name: 'category_id') int? categoryId,  // 追加
    @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)
    required DateTime createdAt,
    @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)
    required DateTime updatedAt,
  }) = _Purchase;

  factory Purchase.fromJson(Map<String, dynamic> json) =>
      _$PurchaseFromJson(json);
}
```

**2. CalendarEventItem.fromPurchaseの修正**:
```dart
factory CalendarEventItem.fromPurchase(Purchase purchase, Category? category) {
  return CalendarEventItem(
    createdAt: purchase.createdAt,
    itemType: CalendarEventItemType.purchase,
    id: purchase.id.toString(),
    title: purchase.title,
    data: purchase.cost.toString(),
    category: category,  // 渡されたcategoryを設定
  );
}
```

**3. HomeCalendarProviderでのカテゴリ紐付け**:
```dart
@override
Future<Map<DateTime, List<CalendarEventItem>>> build(
  DateTime focusedMonth,
) async {
  // ... 既存のコード ...

  final purchases = results[1] as List<Purchase>;
  final categories = await ref.watch(categoryRepositoryProvider).fetchCategories();
  
  // カテゴリマップを作成
  final categoryMap = {for (var c in categories) c.id: c};

  // CalendarEventItemに変換時にカテゴリを紐付け
  final eventItems = [
    ...links.map((e) => CalendarEventItem.fromLink(e)),
    ...purchases.map((p) => CalendarEventItem.fromPurchase(
      p, 
      p.categoryId != null ? categoryMap[p.categoryId] : null,
    )),
    ...notes.map((e) => CalendarEventItem.fromNote(e)),
  ];

  // ... 残りのコード ...
}
```

**4. UI層での使用例**:
```dart
// PurchaseSummaryページ
final purchase = ...;
final categoryName = purchase.category?.name ?? '未分類';

Text('カテゴリ: $categoryName')
```

### 将来的な拡張性

もし**パフォーマンス問題**が発生した場合の移行パス:
1. まずパターン3（category_nameも返す）を試す
2. それでも不足ならパターン2（full JOIN）を検討
3. 根本的な再設計が必要ならGraphQL的アプローチ

**重要**: 現時点では最もシンプルなパターン1から始め、実際のパフォーマンスを計測してから最適化するのが賢明

---

## 次のステップ

1. ✅ Purchaseモデルに `categoryId` フィールドを追加
2. ✅ CalendarEventItemの `fromPurchase` factoryにcategory引数追加
3. ✅ HomeCalendarProviderでカテゴリ紐付けロジック実装
4. ✅ PurchaseSummaryページでカテゴリ別集計処理実装
5. ⏭️ テストコードの追加・修正

---

## 補足: パターン2が適切なケース

以下の場合はパターン2（full JOIN）も検討価値あり:

- 📊 **レポート/分析特化API**: `/purchases/summary`のような集計専用エンドポイント
- 🔒 **データ保全**: 取得時点のカテゴリ名を記録したい（監査ログ的用途）
- 🌐 **オフライン対応**: カテゴリマスタへのアクセスが困難な環境

その場合は **エンドポイントを分ける** のが推奨:
- `GET /purchases`: パターン1（category_idのみ）
- `GET /purchases/detailed`: パターン2（category full JOIN）
