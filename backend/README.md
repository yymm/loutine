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
