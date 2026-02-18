# 簡易認証機構の実装

**実装日**: 2026-02-18  
**目的**: dev環境へのデプロイ時にAPIを保護する簡易的な認証機構

## 実装内容

### 1. 認証ミドルウェア

`src/middleware/auth.ts`を新規作成し、`X-Custom-Auth-Key`ヘッダーを検証するミドルウェアを実装。

**機能:**
- `X-Custom-Auth-Key`ヘッダーの存在を確認
- 環境変数`CUSTOM_AUTH_KEY`と照合
- 環境変数が未設定の場合は警告を出してスキップ（local開発時）
- 認証失敗時は401または403エラーを返却

### 2. 適用範囲

`src/index.ts`で全てのAPIエンドポイント（`/api/*`）に適用。

```typescript
app.use('/api/*', customAuthMiddleware);
```

### 3. 環境変数設定

`wrangler.dev.toml`に`CUSTOM_AUTH_KEY`を追加：

```toml
[vars]
CUSTOM_AUTH_KEY = "your-secret-key-here-change-in-production"
```

**重要:** 本番環境にデプロイする前に必ず変更すること。

### 4. 型定義の更新

`src/utils/app_factory.ts`の`Env`型に`CUSTOM_AUTH_KEY`を追加。

```typescript
Bindings: {
  DB: D1Database;
  CUSTOM_AUTH_KEY?: string;
};
```

## 使用方法

### APIリクエスト例

```bash
# 認証あり
curl -H "X-Custom-Auth-Key: your-secret-key-here-change-in-production" \
  https://backend-dev.your-domain.workers.dev/api/v1/links

# 認証なし（401エラー）
curl https://backend-dev.your-domain.workers.dev/api/v1/links
```

### レスポンス例

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

## ローカル開発環境での動作

`wrangler dev --local`で起動する場合、`CUSTOM_AUTH_KEY`が未設定だと警告が出ますが、認証チェックはスキップされます。

```
CUSTOM_AUTH_KEY is not configured. Skipping auth check.
```

これによりローカル開発時は認証なしでAPIを利用可能です。

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
- ⚠️ シンプルな共有鍵方式（本番環境では不十分）
- ⚠️ トークンのローテーション機能なし

**dev環境専用**として使用し、本番環境では必ずGoogle認証を実装してください。

## 関連ファイル

- `src/middleware/auth.ts` - 認証ミドルウェア
- `src/index.ts` - ミドルウェア適用
- `src/utils/app_factory.ts` - 型定義
- `wrangler.dev.toml` - 環境変数設定
- `README.md` - 使用方法のドキュメント

## テスト

型チェック:
```bash
npm run ci:type
```

手動テスト:
```bash
# dev環境起動
npm run dev

# 別ターミナルで
curl -H "X-Custom-Auth-Key: your-secret-key-here-change-in-production" \
  http://localhost:8787/api/v1/links
```

## 変更履歴

| 日付 | 変更内容 |
|------|---------|
| 2026-02-18 | 初版作成、簡易認証機構実装 |
