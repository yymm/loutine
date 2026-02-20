# development for local

開発用サーバーの起動(local の d1 emulator を利用)

```
npm run local
```

認証キーは`wrangler.toml`で設定されています（デフォルト: `local-dev-key-change-for-production`）。

**重要**: 本番環境にデプロイする前に必ず変更してください。

src/schema.ts を更新した際に実行する

```
npm run local_drizzle_generate
npm run local_drizzle_migrate
```

drizzle studio を使うとき

```
npm run local_drizzle_studio
```

# development for dev on cloudflare d1

初回のみ実行、d1 に dev 用の DB を作成

```
npm run dev_db_create
```

開発用サーバーの起動(cloudflare の dev 用 d1 を利用)

```
npm run dev
```

## 認証キーの設定

**ローカル開発時**は`wrangler.toml`と`wrangler.dev.toml`にデフォルトキー（`local-dev-key-change-for-production`）が設定されています。

**dev環境にデプロイする場合**は、Cloudflare Dashboardで環境変数`CUSTOM_AUTH_KEY`を本番用のキーに上書き設定してください。

### APIリクエスト例

```bash
curl -H "X-Custom-Auth-Key: local-dev-key-change-for-production" \
  http://localhost:8787/api/v1/links
```

### mobile_uiアプリから接続する場合

ローカル開発時はそのまま動作します（`dart_defines/local.env`に同じキーが設定済み）。

dev環境への接続時は、`mobile_ui/dart_defines/dev.env`の`customAuthKey`をCloudflare Dashboardで設定したキーに合わせてください。

### runnテストの実行

ローカル開発時:
```bash
npm run test:runn
```

環境変数が未設定の場合、デフォルトキー（`local-dev-key-change-for-production`）が使用されます。

dev環境への接続時:
```bash
CUSTOM_AUTH_KEY="your-production-key" npm run test:runn
```

src/schema.ts を更新した際に実行する

```
npm run dev_drizzle_generate
npm run dev_drizzle_migrate
```

drizzle studio を使うとき

```
npm run dev_drizzle_studio
```

# deploy to prod


初回のみ実行、d1 に prod 用の DB を作成

```
npm run db_create
```

prod にデプロイ

```
npm run deploy
```

# Deployment to Cloudflare Workers (dev)

## GitHub Secretsの設定（初回のみ）

GitHub Actionsから自動デプロイするために、以下のSecretsを設定してください：

1. GitHubリポジトリ https://github.com/yymm/loutine にアクセス
2. Settings > Secrets and variables > Actions を選択
3. 以下の2つのSecretを追加：

### CLOUDFLARE_API_TOKEN

1. https://dash.cloudflare.com/profile/api-tokens にアクセス
2. "Create Token" をクリック
3. "Edit Cloudflare Workers" テンプレートを使用
4. 権限を設定：
   - Account > Account Settings > Read
   - Account > Workers Scripts > Edit
   - Account > D1 > Edit
5. トークンを生成してコピー

```
Name: CLOUDFLARE_API_TOKEN
Secret: <コピーしたAPI Token>
```

### CLOUDFLARE_ACCOUNT_ID

1. https://dash.cloudflare.com/ にアクセス
2. Workers & Pages を選択
3. 右サイドバーの Account ID をコピー

```
Name: CLOUDFLARE_ACCOUNT_ID
Secret: <コピーしたAccount ID>
```

## 自動デプロイフロー

mainブランチにマージされると、GitHub Actionsが自動的に：

1. 型チェック実行
2. D1データベースへマイグレーション実行
3. Cloudflare Workers (dev)にデプロイ

## 手動デプロイ

GitHub Actionsから手動でデプロイすることも可能：

1. GitHubリポジトリ > Actions タブ
2. "Deploy Backend to Dev" ワークフローを選択
3. "Run workflow" をクリック
4. ブランチを選択（通常は main）
5. "Run workflow" をクリック

## Cloudflare Dashboard での環境変数設定

デプロイ後、認証キーを設定してください：

1. https://dash.cloudflare.com/ にアクセス
2. Workers & Pages > backend を選択
3. Settings > Variables を選択
4. "Add variable" をクリック
5. 以下を追加：

```
Variable name: CUSTOM_AUTH_KEY
Value: <強力なランダム文字列>
Type: Text
Encrypt: ✅
```

推奨：認証キーの生成
```bash
openssl rand -base64 32
```

詳細は `docs/cloudflare-deployment.md` を参照してください。

# API Architecture

ドメイン的なやつ
- 主要データ
  - links
  - purchases
  - notes
- 主要データに紐づく形で利用するデータ
  - categories
    - link_category
    - purchase_category
    - note_category
  - tags
    - link_tag
    - purchase_tag
    - note_tag

# Tools

ライブラリ
- hono (セットアップ)
- drizzle
- zod

開発
- vitest
- biome
