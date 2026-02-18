# 簡易認証機構の実装

**実装日**: 2026-02-18  
**目的**: dev環境へのデプロイ時にAPIを保護する簡易的な認証機構

## 実装内容

### 1. 認証ミドルウェア

`src/middleware/auth.ts`を新規作成し、`X-Custom-Auth-Key`ヘッダーを検証するミドルウェアを実装。

**機能:**
- `X-Custom-Auth-Key`ヘッダーの存在を確認
- 環境変数`CUSTOM_AUTH_KEY`と照合
- 環境変数が未設定の場合は警告を出してスキップ（**local開発時**）
- 認証失敗時は401または403エラーを返却

### 2. 適用範囲

`src/index.ts`で全てのAPIエンドポイント（`/api/*`）に適用。

```typescript
app.use('/api/*', customAuthMiddleware);
```

### 3. 環境変数設定

**ローカル開発**: `wrangler.dev.toml`では`CUSTOM_AUTH_KEY`を設定しない（デフォルトでコメントアウト）

**dev環境**: Cloudflare Dashboardで環境変数`CUSTOM_AUTH_KEY`を設定

```bash
# Cloudflare Dashboard > Workers > backend > Settings > Variables
CUSTOM_AUTH_KEY = "your-secret-key"
```

### 4. 型定義の更新

`src/utils/app_factory.ts`の`Env`型に`CUSTOM_AUTH_KEY`を追加。

```typescript
Bindings: {
  DB: D1Database;
  CUSTOM_AUTH_KEY?: string;
};
```

### 5. mobile_ui側の対応

`mobile_ui/lib/api/vanilla_api.dart`を更新し、環境変数から認証キーを読み込んで自動的にヘッダーに追加。

```dart
const envCustomAuthKey = String.fromEnvironment('customAuthKey');

Map<String, String> _createHeaders() {
  final headers = <String, String>{
    'content-type': 'application/json',
  };
  if (envCustomAuthKey.isNotEmpty) {
    headers['X-Custom-Auth-Key'] = envCustomAuthKey;
  }
  return headers;
}
```

環境ごとの設定:
- `mobile_ui/dart_defines/local.env`: `customAuthKey=""`（空文字）
- `mobile_ui/dart_defines/dev.env`: `customAuthKey="your-secret-key"`
- `mobile_ui/dart_defines/prod.env`: `customAuthKey=""`（空文字、将来はGoogle OAuth）

### 6. runnテストの対応

全てのテストファイルに環境変数からauth keyを読み込む設定を追加。

```yaml
vars:
  authKey: '{{ env "CUSTOM_AUTH_KEY" "" }}'
steps:
- req:
    /api/v1/links:
      get:
        headers:
          X-Custom-Auth-Key: '{{ vars.authKey }}'
```

## 使用方法

### ローカル開発（認証なし）

```bash
# backend起動
cd backend
npm run local  # または npm run dev

# mobile_ui起動
cd mobile_ui
flutter run --dart-define-from-file=dart_defines/local.env

# runnテスト実行
cd backend
npm run test:runn
```

### dev環境（認証あり）

**1. Cloudflare Dashboardで環境変数設定**

```
CUSTOM_AUTH_KEY = "your-dev-secret-key"
```

**2. mobile_uiの設定**

```env
# mobile_ui/dart_defines/dev.env
customAuthKey="your-dev-secret-key"
```

**3. APIリクエスト例**

```bash
curl -H "X-Custom-Auth-Key: your-dev-secret-key" \
  https://backend-dev.your-domain.workers.dev/api/v1/links
```

**4. runnテスト実行**

```bash
CUSTOM_AUTH_KEY="your-dev-secret-key" npm run test:runn
```

## レスポンス例

**成功:**
```json
{
  "success": true,
  "data": [...]
}
```

**認証失敗（ヘッダーなし）:**
```json
{
  "message": "Missing X-Custom-Auth-Key header"
}
```
HTTP Status: 401

**認証失敗（キー不一致）:**
```json
{
  "message": "Invalid authentication key"
}
```
HTTP Status: 403

## 動作フロー

```
┌────────────────────────────────────────────────┐
│ ローカル開発 (npm run local)                    │
│ → CUSTOM_AUTH_KEY未設定 → 認証スキップ          │
│ → 開発が楽                                      │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│ dev環境 (Cloudflare Workers)                   │
│ → CUSTOM_AUTH_KEY設定済み → 認証必須            │
│ → APIを保護                                     │
└────────────────────────────────────────────────┘

┌────────────────────────────────────────────────┐
│ prod環境 (将来)                                 │
│ → Google OAuth + JWT → 本格的な認証            │
└────────────────────────────────────────────────┘
```

## 今後の拡張

Phase 3（Google認証実装）時に本格的な認証機構に置き換える予定：

1. **usersテーブルの追加**
2. **Google OAuth + Firebase Auth**
3. **JWT/JWKSによるトークン検証**
4. **既存テーブルへの`user_id`追加**

現在の簡易認証はdev環境専用の一時的な実装です。

## セキュリティ考慮事項

- ✅ HTTPS通信必須（Cloudflare WorkersはデフォルトでHTTPS）
- ✅ 環境変数を使用（ハードコードなし）
- ✅ ローカル開発では認証スキップ（開発効率向上）
- ⚠️ シンプルな共有鍵方式（本番環境では不十分）
- ⚠️ トークンのローテーション機能なし

**dev環境専用**として使用し、本番環境では必ずGoogle認証を実装してください。

## 関連ファイル

**backend:**
- `src/middleware/auth.ts` - 認証ミドルウェア
- `src/index.ts` - ミドルウェア適用
- `src/utils/app_factory.ts` - 型定義
- `wrangler.dev.toml` - 環境変数設定（コメントアウト）
- `test/runn/**/*.yml` - テストファイル（認証ヘッダー追加）
- `README.md` - 使用方法のドキュメント

**mobile_ui:**
- `lib/api/vanilla_api.dart` - APIクライアント（認証ヘッダー追加）
- `dart_defines/*.env` - 環境ごとの認証キー設定

## テスト

型チェック:
```bash
npm run ci:type
```

ローカル開発テスト:
```bash
# backend起動
npm run local

# 別ターミナルで
curl http://localhost:8787/api/v1/links  # 認証なしでOK
```

dev環境テスト:
```bash
# backend起動（認証キー設定済みの場合）
npm run dev

# 別ターミナルで
curl -H "X-Custom-Auth-Key: your-key" http://localhost:8787/api/v1/links
```

## 変更履歴

| 日付 | 変更内容 |
|------|---------|
| 2026-02-18 | 初版作成、簡易認証機構実装 |
| 2026-02-18 | 環境ベースの認証制御に変更、mobile_ui対応、runnテスト対応 |
