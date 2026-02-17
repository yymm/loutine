# Phase順序の設計理由

## 現在の順序

```
Phase 0: 準備・調査 (1-2週間)
Phase 1: ローカルDB実装 (2-3週間)
Phase 2: Repository抽象化 (2週間)
Phase 3: 認証機能 (2-3週間)
Phase 4: 課金機能 (2-3週間)
Phase 5: 同期機能 (3-4週間)
Phase 6: 移行とテスト (2週間)
```

---

## なぜこの順序なのか？

### 原則1: **依存関係の下から実装する**

システムの依存関係は以下のような階層構造:

```
┌─────────────────────────────────────┐
│         Phase 5: 同期機能            │ ← 最上位（全てに依存）
├─────────────────────────────────────┤
│    Phase 3: 認証  │  Phase 4: 課金   │ ← 中間層
├─────────────────────────────────────┤
│    Phase 2: Repository抽象化         │ ← データアクセス層
├─────────────────────────────────────┤
│    Phase 1: ローカルDB               │ ← 基盤層（依存なし）
└─────────────────────────────────────┘
```

**下から実装しないと、上位の実装ができない**

---

## 各Phaseの配置理由

### Phase 1: ローカルDB が最初の理由

#### 理由1: 他の全機能の基盤
```dart
// Phase 2のRepositoryはPhase 1のDBに依存
class LocalLinkRepository implements LinkRepository {
  final AppDatabase db; // ← Phase 1で作成
  
  Future<List<Link>> fetchLinks() {
    return db.linkDao.getAll(); // ← Phase 1のDAOを使用
  }
}

// Phase 5の同期機能もPhase 1のDBに依存
class SyncManager {
  Future<void> syncToRemote() {
    final unsyncedData = await db.getUnsyncedRecords(); // ← Phase 1
    // ...
  }
}
```

#### 理由2: 単独でテスト・検証できる
- DBだけ作れば、認証や課金なしで動作確認できる
- 早い段階でデータ構造の問題を発見できる

#### 理由3: 無料ユーザー向け機能として独立
- Phase 1が完了すれば、**無料版として一部リリース可能**
- 認証・課金の実装を待たずに価値提供できる

---

### Phase 2: Repository抽象化 が次の理由

#### 理由1: Phase 1のDBを使う準備
```dart
// Phase 1で作ったDBを
abstract class LinkRepository {
  Future<List<Link>> fetchLinks();
}

// 既存のAPIとPhase 1のDBの両方で実装できる
class LocalLinkRepository implements LinkRepository { /* Phase 1のDB */ }
class RemoteLinkRepository implements LinkRepository { /* 既存API */ }
```

#### 理由2: Phase 3-5の切り替えロジックを実装できる
```dart
@riverpod
LinkRepository linkRepository(LinkRepositoryRef ref) {
  final authState = ref.watch(authStateProvider); // ← Phase 3で実装
  final billingState = ref.watch(billingStateProvider); // ← Phase 4で実装
  
  if (authState.isAuthenticated && billingState.isPremium) {
    return SyncLinkRepository(); // ← Phase 5で実装
  } else {
    return LocalLinkRepository(); // ← Phase 1で実装済み
  }
}
```

#### 理由3: 既存コードへの影響を最小化
- Repositoryを抽象化しておけば、Provider層は**ほぼ変更不要**
- Phase 3以降で認証や課金を追加しても、UIレイヤーは影響を受けない

---

### Phase 3: 認証 と Phase 4: 課金 の順序

#### なぜ認証が先？

**Option A: 認証 → 課金 (現在の順序)**
```dart
// 認証が先
await signInWithGoogle(); // ← Phase 3
final user = getCurrentUser(); // userId取得

// 課金はuserIdに紐付ける
await purchaseSubscription(userId: user.id); // ← Phase 4
```

**メリット:**
- 課金時に必ずuserIdがある
- サーバー側の実装がシンプル
- レシート検証時にユーザーと紐付けやすい

**Option B: 課金 → 認証 (逆順)**
```dart
// 課金が先
await purchaseSubscription(); // ← Phase 4
// でも誰が課金した？ → 匿名ID?

// 後で認証
await signInWithGoogle(); // ← Phase 3
// 既存の課金をどう紐付ける？ → マイグレーション地獄
```

**デメリット:**
- 課金したレシートをどのユーザーに紐付けるか不明
- 後から認証を追加すると、既存課金の移行が複雑
- サーバー側で課金管理が困難

#### 実装上の依存関係

```dart
// 課金機能は認証情報を使う
class BillingService {
  Future<void> purchaseSubscription() async {
    final user = authService.currentUser; // ← Phase 3の認証情報
    
    final receipt = await InAppPurchase.instance.buyNonConsumable(...);
    
    // サーバーに送信してユーザーと紐付け
    await api.verifyReceipt(
      userId: user.id,  // ← Phase 3で取得
      receipt: receipt,
    );
  }
}
```

**結論: 認証→課金の順序が自然**

---

### Phase 5: 同期機能 が最後の理由

#### 理由1: 全ての機能に依存している

```dart
class SyncManager {
  // Phase 1: ローカルDB
  final AppDatabase localDb;
  
  // Phase 2: Repository
  final LinkRepository remoteRepository;
  
  // Phase 3: 認証状態
  final AuthService authService;
  
  // Phase 4: 課金状態
  final BillingService billingService;
  
  Future<void> sync() async {
    // 認証確認 (Phase 3)
    if (!authService.isAuthenticated) return;
    
    // 課金確認 (Phase 4)
    if (!billingService.isPremium) return;
    
    // ローカルからデータ取得 (Phase 1)
    final unsyncedData = await localDb.getUnsyncedRecords();
    
    // リモートに送信 (Phase 2)
    await remoteRepository.createBatch(unsyncedData);
  }
}
```

#### 理由2: 最も複雑で時間がかかる
- 競合解決ロジック
- オフライン対応
- バックグラウンド同期
- エラーハンドリング

Phase 1-4が完成してから、集中して取り組むべき

#### 理由3: 段階的リリースが可能
- Phase 4完了時点で「課金機能付き」としてリリース可能
- Phase 5は後から追加（v2.0として）

---

## 代替案の検討

### 代替案1: 認証と課金を並行実施

```
Phase 1: ローカルDB
Phase 2: Repository抽象化
Phase 3+4: 認証と課金を並行実装 ← 統合
Phase 5: 同期機能
```

**メリット:**
- 期間短縮（2-3週間削減）

**デメリット:**
- 複雑度が上がる
- バックエンド実装も並行で進める必要
- デバッグが困難

**推奨度: △** スキルが高ければあり

---

### 代替案2: Repository抽象化を後回し

```
Phase 1: ローカルDB
Phase 2: 認証機能
Phase 3: 課金機能
Phase 4: Repository抽象化 ← 後回し
Phase 5: 同期機能
```

**メリット:**
- 早く認証・課金を実装できる

**デメリット:**
- ❌ Phase 2-3でRepositoryなしで実装→Phase 4で大規模リファクタリング
- ❌ 既存のProvider層への影響が大きくなる
- ❌ Phase 5の同期実装時に再度大規模修正

**推奨度: ✕** リファクタリング地獄になる

---

### 代替案3: 同期機能を先に実装

```
Phase 1: ローカルDB
Phase 2: 同期機能 ← 先に
Phase 3: Repository抽象化
Phase 4: 認証機能
Phase 5: 課金機能
```

**デメリット:**
- ❌ 認証なしで同期？ → セキュリティリスク
- ❌ 課金確認なしで同期？ → 無料ユーザーがサーバー使い放題
- ❌ 実装不可能

**推奨度: ✕✕✕** 論理的に破綻

---

## Phase順序の決定要因まとめ

### 1. **技術的依存関係**
```
同期機能 → 認証・課金・Repository・DB
認証・課金 → Repository・DB
Repository → DB
DB → (依存なし)
```
→ **下から順に実装するしかない**

### 2. **リスク管理**
- 簡単で確実なもの（DB）から実装
- 複雑なもの（同期）は基盤ができてから

### 3. **段階的リリース**
- Phase 1完了 → 無料版リリース可能
- Phase 4完了 → 課金版リリース可能
- Phase 5完了 → 完全版リリース

### 4. **開発効率**
- 並行作業よりも、直列で確実に
- 各Phaseが前Phaseの成果物を使う

---

## 例外: カスタマイズ可能な部分

### カスタマイズ1: Phase 3と4を並行
条件:
- バックエンド開発者が複数いる
- フロントエンド開発者のスキルが高い

→ **2-3週間短縮可能**

### カスタマイズ2: Phase 5を分割
```
Phase 5a: 単方向同期（リモート→ローカルのみ）
Phase 5b: 双方向同期
Phase 5c: 競合解決
```
→ **段階的リリースでリスク低減**

### カスタマイズ3: Phase 1を簡略化
もし以下が不要なら:
- タグ、カテゴリなど一部機能を後回し
- 最小限のテーブルだけ実装

→ **1週間短縮可能**

---

## 結論

### なぜこの順序なのか？

1. **技術的依存関係を守るため** - 下から実装しないと上が作れない
2. **リスクを最小化するため** - 簡単なものから確実に
3. **段階的リリースを可能にするため** - Phase毎に価値提供
4. **開発効率を上げるため** - 並行よりも直列で確実に

### 推奨される変更

- **Phase 3と4を並行**: リソースがあればOK
- **Phase 5を分割**: リスク低減のため推奨

### 変更してはいけないこと

- **Phase 1, 2の順序**: 絶対に変更不可（依存関係が壊れる）
- **Phase 5を前倒し**: 認証・課金なしで同期は不可能

---

## 次のステップ

この順序理解をベースに:
1. カスタマイズが必要か検討
2. 各Phaseの詳細タスクを定義
3. リソース（人員・時間）を割り当て

---

この説明で Phase順序の理由が明確になりましたか？
他に疑問があれば教えてください！
