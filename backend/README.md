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
