# development for local

開発用サーバーの起動(local の d1 emulator を利用)

```
npm run local
```

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

dev環境にデプロイする場合は、Cloudflare Dashboardで環境変数`CUSTOM_AUTH_KEY`を設定してください。

**ローカル開発時**は認証キーが不要です（未設定の場合は認証チェックがスキップされます）。

**dev環境にデプロイした場合**は、APIリクエスト時に以下のヘッダーを付与してください：

```bash
curl -H "X-Custom-Auth-Key: your-secret-key" \
  https://your-dev-api.workers.dev/api/v1/links
```

### mobile_uiアプリから接続する場合

`mobile_ui/dart_defines/dev.env`の`customAuthKey`を設定してください：

```env
customAuthKey="your-secret-key"
```

### runnテストの実行

ローカル開発時（認証なし）:
```bash
npm run test:runn
```

dev環境への接続時（認証あり）:
```bash
CUSTOM_AUTH_KEY="your-secret-key" npm run test:runn
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
