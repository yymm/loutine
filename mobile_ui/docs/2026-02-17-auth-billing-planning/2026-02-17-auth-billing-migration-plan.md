# Google認証＋課金機能実装計画

## 概要

現状の無認証システムから、段階的に機能を拡張し、最終的にGoogle認証＋課金機能を実装する。

### リリース計画

- **v1.0 (無料版)**: ローカルDB（Drift/SQLite）のみ、認証なし
- **v2.0 (課金版)**: Google認証＋Sign in with Apple、サーバー同期、課金機能

### ユーザー体験

- **無料ユーザー**: ローカルDB（Drift/SQLite）のみを使用
- **有料ユーザー**: ローカルDBをキャッシュとして高速に利用しつつ、サーバーと同期してデータを永続化

## 目標アーキテクチャ

```
┌─────────────────────────────────────────────────────┐
│                     UI Layer                        │
│              (既存のConsumerWidget)                  │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│              Provider Layer                         │
│        (既存のRiverpod Providers)                    │
└─────────────────┬───────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────┐
│            Repository Layer (新規)                   │
│  ┌──────────────────────────────────────────────┐  │
│  │  Auth判定: 有料ユーザー？無料ユーザー？        │  │
│  └──────┬──────────────────────────┬────────────┘  │
│         │                          │               │
│    [有料]│                          │[無料]          │
│         │                          │               │
│  ┌──────▼──────────┐      ┌────────▼──────────┐   │
│  │ Remote + Local  │      │   Local Only      │   │
│  │  Sync Strategy  │      │   (Drift/SQLite)  │   │
│  └──────┬──────────┘      └───────────────────┘   │
│         │                                          │
└─────────┼──────────────────────────────────────────┘
          │
┌─────────▼──────────────────────────────────────────┐
│              Data Source Layer                      │
│  ┌─────────────────┐      ┌──────────────────┐    │
│  │  Local DB       │      │  Remote API      │    │
│  │  (Drift)        │      │  (HTTP/REST)     │    │
│  └─────────────────┘      └──────────────────┘    │
└─────────────────────────────────────────────────────┘
```

## 実装フェーズ

### 🎯 v1.0 リリース目標: Phase 2完了時点 (約7週間)

無料版として以下の機能を提供:
- ローカルDBによるデータ管理
- 認証なし（App Store審査リスク回避）
- 既存の全機能が動作

### 🎯 v2.0 リリース目標: Phase 6完了時点 (約19週間)

課金版として以下の機能を追加:
- Google認証 + Sign in with Apple
- サーバー同期
- 課金機能

---

### Phase 0: 準備・調査 (1-2週間)

**目的**: 技術選定と設計の確定（v1.0向け）

#### タスク
1. **パッケージ調査**
   - [ ] Drift (SQLite): ローカルDB実装 ← v1.0
   - [ ] google_sign_in: Google認証 ← v2.0で使用
   - [ ] firebase_auth: 認証管理 ← v2.0で使用
   - [ ] sign_in_with_apple: Apple認証 ← v2.0で使用
   - [ ] in_app_purchase: App Store/Play Store課金 ← v2.0で使用
   - [ ] shared_preferences: 認証状態の永続化 ← v2.0で使用

2. **設計ドキュメント作成**
   - [ ] データベーススキーマ設計（DriftのTable定義）
   - [ ] Repository抽象化インターフェース設計
   - [ ] 認証フロー設計
   - [ ] 同期戦略設計（オンライン/オフライン、競合解決）

3. **バックエンドAPI設計**
   - [ ] 認証エンドポイント設計
   - [ ] ユーザー管理API設計
   - [ ] 課金状態確認API設計

**成果物**: 
- `docs/database-schema.md`
- `docs/repository-design.md`
- `docs/auth-flow.md` ← v2.0で詳細化
- `docs/sync-strategy.md` ← v2.0で詳細化

---

### Phase 1: ローカルDB実装 (2-3週間) ← v1.0の核心機能

**目的**: v1.0無料版のデータ管理基盤

#### タスク
1. **Driftのセットアップ**
   ```
   dependencies:
     drift: ^2.x.x
     sqlite3_flutter_libs: ^0.x.x
     path_provider: ^2.x.x
     path: ^1.x.x
   
   dev_dependencies:
     drift_dev: ^2.x.x
     build_runner: ^2.x.x
   ```

2. **データベーステーブル定義**
   - Links, Notes, Purchases, Tags, Categories
   - 既存のモデルをベースにDrift Tableを作成
   - `lib/database/tables/` に配置

3. **Database Access Object (DAO) 実装**
   - CRUD操作の実装
   - `lib/database/daos/` に配置

4. **既存モデルとの変換レイヤー**
   - Drift Entity ↔ 既存Models の変換
   - `lib/database/converters/` に配置

**ディレクトリ構成**:
```
lib/
├── database/
│   ├── app_database.dart         # メインDB定義
│   ├── tables/
│   │   ├── links.dart
│   │   ├── notes.dart
│   │   ├── purchases.dart
│   │   ├── tags.dart
│   │   └── categories.dart
│   ├── daos/
│   │   ├── link_dao.dart
│   │   ├── note_dao.dart
│   │   ├── purchase_dao.dart
│   │   ├── tag_dao.dart
│   │   └── category_dao.dart
│   └── converters/
│       └── model_converters.dart
```

**成果物**:
- 完全に動作するローカルDB
- 既存のAPIレイヤーを経由せずローカルのみで動作する状態

---

### Phase 2: Repository抽象化レイヤー実装 (2週間) ← v1.0完成

**目的**: データソースの切り替えを可能にする抽象レイヤーを構築

**v1.0時点での実装:**
- LocalRepository（ローカルDB使用）のみ実装
- RemoteRepository、SyncRepositoryはインターフェースのみ定義

#### タスク
1. **Repository Interfaceの定義**
   ```dart
   abstract class LinkRepository {
     Future<List<Link>> fetchLinks(DateTime start, DateTime end);
     Future<Link> createLink(String url, String title, List<int> tagIds);
     Future<void> deleteLink(int id);
     // ... その他のメソッド
   }
   ```

2. **実装クラスの作成**
   - `LocalLinkRepository`: Drift使用
   - `RemoteLinkRepository`: 既存のAPI使用
   - `SyncLinkRepository`: ローカル+リモート同期

3. **既存のRepositoryをリファクタリング**
   - `lib/repositories/` 内のファイルをインターフェースベースに書き換え
   - 既存のAPI呼び出しは `RemoteXxxRepository` に移動

**ディレクトリ構成**:
```
lib/
├── repositories/
│   ├── interfaces/              # 新規
│   │   ├── link_repository.dart
│   │   ├── note_repository.dart
│   │   ├── purchase_repository.dart
│   │   ├── tag_repository.dart
│   │   └── category_repository.dart
│   ├── local/                   # 新規
│   │   ├── local_link_repository.dart
│   │   ├── local_note_repository.dart
│   │   └── ...
│   ├── remote/                  # 既存を移動
│   │   ├── remote_link_repository.dart
│   │   └── ...
│   └── sync/                    # 新規
│       ├── sync_link_repository.dart
│       └── ...
```

4. **Repository Provider切り替えロジック（v1.0時点）**
   ```dart
   @riverpod
   LinkRepository linkRepository(LinkRepositoryRef ref) {
     // v1.0: ローカルのみ
     return LocalLinkRepository();
     
     // v2.0で以下を実装予定
     // final authState = ref.watch(authStateProvider);
     // if (authState.isPremium) {
     //   return SyncLinkRepository();
     // } else {
     //   return LocalLinkRepository();
     // }
   }
   ```

**成果物**:
- データソース切り替え可能なRepository層
- v1.0時点ではLocalRepositoryのみ動作
- 既存のProviderは変更なし（依存するRepositoryが差し替わるだけ）

**📦 v1.0リリース (Phase 2完了時点)**

---

## v2.0 実装フェーズ (Phase 3以降)

### Phase 3: 認証機能実装 (3-4週間) ← v2.0開始

**目的**: Google認証 + Sign in with Apple の実装

#### タスク (フロントエンド)
1. **パッケージ追加**
   ```yaml
   dependencies:
     firebase_core: ^2.x.x
     firebase_auth: ^4.x.x
     google_sign_in: ^6.x.x
     sign_in_with_apple: ^6.x.x  # iOS対応
   ```

2. **認証Provider実装**
   ```
   lib/
   ├── auth/
   │   ├── auth_service.dart        # 認証ロジック（Google + Apple）
   │   ├── auth_state.dart          # 認証状態モデル
   │   └── auth_provider.dart       # Riverpod Provider
   ```

3. **ログイン画面UI実装**
   - `lib/ui/auth/login_page.dart`
   - Sign in with Appleボタン（iOS: 上に配置）
   - Google Sign Inボタン
   - ログアウト機能

4. **v1.0からv2.0への移行フロー**
   - 既存のローカルデータをサーバーにアップロード
   - 「ログインしてデータをバックアップ」プロンプト表示

4. **認証状態の永続化**
   - SharedPreferencesで認証トークン保存
   - アプリ起動時の自動ログイン

5. **認証状態に応じたUI切り替え**
   - ログイン前: ローカルのみ使用を通知
   - ログイン後: 同期機能の説明

#### タスク (バックエンド)
1. **Firebase Admin SDK統合**
2. **Google IDトークン検証エンドポイント**
3. **ユーザー登録・管理API**
4. **認証ミドルウェア実装**

**成果物**:
- Google認証 + Sign in with Appleでログイン可能
- 認証状態がRiverpodで管理される
- バックエンドでトークン検証が完了
- v1.0ユーザーのデータ移行完了

---

### Phase 4: 課金機能実装 (2-3週間) ← v2.0課金機能追加

**目的**: In-App Purchaseによる課金

#### タスク (フロントエンド)
1. **パッケージ追加**
   ```yaml
   dependencies:
     in_app_purchase: ^3.x.x
   ```

2. **課金Provider実装**
   ```
   lib/
   ├── billing/
   │   ├── billing_service.dart      # 課金ロジック
   │   ├── billing_state.dart        # 課金状態モデル
   │   └── billing_provider.dart     # Riverpod Provider
   ```

3. **課金画面UI実装**
   - `lib/ui/billing/subscription_page.dart`
   - プラン選択
   - 購入ボタン
   - レシート検証

4. **App Store / Play Console設定**
   - サブスクリプション商品登録
   - テスターアカウント設定

#### タスク (バックエンド)
1. **レシート検証API実装**
   - App Store Server API統合
   - Google Play Developer API統合
2. **ユーザーのサブスクリプション状態管理**
3. **Webhook実装（サブスク更新・キャンセル通知）**

**成果物**:
- 課金が完了し、サーバー側でサブスク状態を管理
- 課金ユーザーのみリモート同期が有効化

---

### Phase 5: 同期機能実装 (3-4週間)

**目的**: ローカル⇔リモートの双方向同期

#### タスク
1. **同期戦略の実装**
   - **書き込み**: ローカルに即座に保存 → バックグラウンドでリモートに送信
   - **読み込み**: ローカルから即座に表示 → バックグラウンドでリモートから最新を取得
   - **競合解決**: Last-Write-Wins または ユーザー選択

2. **同期状態の管理**
   - 各レコードに `synced: bool`, `updatedAt: DateTime` を追加
   - 未同期データの検出・リトライ

3. **オフライン対応**
   - ネットワーク状態監視
   - オフライン時はローカルのみ使用
   - オンライン復帰時に自動同期

4. **バックグラウンド同期**
   - `workmanager` パッケージでバックグラウンド処理

**ディレクトリ構成**:
```
lib/
├── sync/
│   ├── sync_manager.dart          # 同期管理
│   ├── sync_strategy.dart         # 同期戦略
│   ├── conflict_resolver.dart     # 競合解決
│   └── sync_provider.dart         # Riverpod Provider
```

**成果物**:
- 有料ユーザーはローカルとリモートが常に同期
- オフラインでも快適に動作
- 競合が発生しても適切に解決

---

### Phase 6: 統合テストとv2.0リリース (2週間)

#### タスク
1. **全Providerの動作確認**
   - 無料ユーザーとしてローカルのみで動作
   - 有料ユーザーとして同期動作

2. **データ移行機能**
   - 既存のAPIデータをローカルDBにインポート
   - 初回起動時のマイグレーション処理

3. **エラーハンドリング強化**
   - ネットワークエラー
   - 認証エラー
   - 課金エラー

4. **統合テスト**
   - 無料→有料へのアップグレードフロー
   - ログアウト→ログインでのデータ復元

**成果物**:
- 全機能が新アーキテクチャで動作
- v1.0ユーザーがv2.0にスムーズにアップグレード
- 無料ユーザーと有料ユーザーの両方が快適に利用

**📦 v2.0リリース (Phase 6完了時点)**

---

## 実装優先順位

### v1.0 リリース（Phase 1-2）
- **期間**: 約7週間
- **内容**: ローカルDBのみの無料版
- **目的**: 早期リリース、ユーザーフィードバック取得、審査リスク回避

### v2.0 リリース（Phase 3-6）
- **期間**: 約12週間（v1.0リリース後）
- **内容**: 認証・課金・同期機能
- **目的**: 収益化、クロスデバイス対応

---

## リスクと対策

### リスク1: データ同期の複雑性
- **対策**: Phase 5を細かく分割し、まずは単純なLast-Write-Winsから開始

### リスク2: 既存コードの大規模リファクタリング
- **対策**: Phase 2でRepositoryを抽象化することで、既存のProvider層は変更最小限

### リスク3: 課金機能のテストが困難
- **対策**: サンドボックス環境を活用し、テストアカウントで十分に検証

### リスク4: 認証トークンの安全な管理
- **対策**: flutter_secure_storageを使用し、トークンを暗号化して保存

---

## 技術スタック（追加分）

| 機能 | パッケージ |
|------|-----------|
| ローカルDB | `drift`, `sqlite3_flutter_libs` |
| 認証 | `firebase_auth`, `google_sign_in` |
| 課金 | `in_app_purchase` |
| セキュア保存 | `flutter_secure_storage` |
| バックグラウンド同期 | `workmanager` |
| ネットワーク監視 | `connectivity_plus` |

---

## マイルストーン

| Phase | 期間 | 完了予定 | リリース |
|-------|------|---------|---------|
| Phase 0 | 1-2週間 | Week 2 | - |
| Phase 1 | 2-3週間 | Week 5 | - |
| Phase 2 | 2週間 | Week 7 | **📦 v1.0 無料版** |
| Phase 3 | 3-4週間 | Week 11 | - |
| Phase 4 | 2-3週間 | Week 14 | - |
| Phase 5 | 3-4週間 | Week 18 | - |
| Phase 6 | 2週間 | Week 20 | **📦 v2.0 課金版** |

**v1.0リリース: 約7週間（2ヶ月弱）**
**v2.0リリース: 約20週間（5ヶ月）**

---

## リリース戦略

### v1.0 無料版の位置づけ

**目的:**
1. 早期リリースでユーザーフィードバック取得
2. App Store審査リスク回避（認証機能なし = Sign in with Apple不要）
3. 市場での存在感を早期に確立

**制約:**
- 認証なし → 機種変更時のデータ移行不可
- ローカルのみ → 複数デバイス同期不可
- アプリ説明文で「v2.0で認証・課金機能追加予定」と明記

**v1.0での収益化:**
- 広告表示（オプション）
- 「v2.0のプレビュー」として宣伝

### v2.0 課金版の位置づけ

**目的:**
1. 収益化開始
2. 機種変更・複数デバイス対応
3. 長期利用ユーザーの獲得

**v1.0からの移行:**
- 「ログインしてデータをバックアップ」プロンプト
- ローカルデータを自動的にサーバーにアップロード
- シームレスな移行体験

---

## 次のステップ

1. ✅ このドキュメントをレビュー・確認（完了）
2. Phase 0の調査を開始
3. v1.0向けの詳細な技術仕様書を作成
4. Phase 1のタスクをissue化して開発開始
5. v1.0リリース後、Phase 3以降の詳細設計

---

## 参考資料

- [Drift Documentation](https://drift.simonbinder.eu/)
- [Firebase Auth for Flutter](https://firebase.google.com/docs/auth/flutter/start)
- [In-App Purchase Plugin](https://pub.dev/packages/in_app_purchase)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
