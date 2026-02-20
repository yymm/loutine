# Cloudflare Workers (dev環境) へのデプロイ手順

**作成日**: 2026-02-19  
**対象環境**: dev環境（Cloudflare Workers）

## 概要

backendをCloudflare Workersのdev環境にデプロイする手順を説明します。

- **ローカルからのデプロイ**: 初回セットアップや緊急時に使用
- **自動デプロイ（CD）**: mainブランチへのマージで自動的にデプロイ

## 前提条件

### 必要なもの

1. **Cloudflare アカウント**
   - https://dash.cloudflare.com/ でアカウント作成
   - Workers プランに登録（無料プランでOK）

2. **Wrangler CLI**
   - プロジェクトに既にインストール済み
   - バージョン確認: `npx wrangler --version`

3. **D1データベース**
   - 既に作成済み（`wrangler.dev.toml`に記載）

## 環境の確認

現在のdev環境設定（`wrangler.dev.toml`）：

```toml
name = "backend"
main = "src/index.ts"
compatibility_date = "2025-01-01"

[[d1_databases]]
binding = "DB"
database_name = "loutine-dev"
database_id = "31442ac4-9999-494d-b9f4-625757b2742f"
```

## ローカルからのデプロイ手順

### 1. Cloudflare認証

```bash
cd backend
npx wrangler login
```

ブラウザが開いてCloudflareにログインします。認証が完了すると、ターミナルに成功メッセージが表示されます。

### 2. マイグレーションの実行

データベーススキーマをdev環境のD1に反映します：

```bash
npm run dev:drizzle:migrate
```

**実行内容:**
- `drizzle/migrations/` 内のSQLマイグレーションファイルをCloudflare D1に適用
- 既に適用済みのマイグレーションはスキップされる

### 3. 環境変数の設定

Cloudflare Dashboardで認証キーを設定します：

1. https://dash.cloudflare.com/ にアクセス
2. **Workers & Pages** を選択
3. **backend** Worker を選択（既にデプロイされている場合）
4. **Settings > Variables** を選択
5. **Add variable** をクリック
6. 以下を追加：

```
Variable name: CUSTOM_AUTH_KEY
Value: <強力なランダム文字列>
Type: Text
Encrypt: ✅ (推奨)
```

**推奨：認証キーの生成**

```bash
# ランダムな32文字の文字列を生成
openssl rand -base64 32
```

### 4. デプロイ実行

```bash
npx wrangler deploy --config wrangler.dev.toml
```

**出力例:**
```
Total Upload: xx.xx KiB / gzip: xx.xx KiB
Uploaded backend (x.xx sec)
Published backend (x.xx sec)
  https://backend.your-account.workers.dev
Current Deployment ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

### 5. デプロイ確認

デプロイされたURLで動作確認：

```bash
# 環境変数で設定した認証キーを使用
curl -H "X-Custom-Auth-Key: <your-secret-key>" \
  https://backend.your-account.workers.dev/api/v1/links
```

**期待されるレスポンス:**
```json
[]
```
または
```json
[{"id":1,"title":"...","url":"...","created_at":"...","updated_at":"..."}]
```

## GitHub Actions からの自動デプロイ（CD）

mainブランチにマージされたら自動的にdev環境にデプロイされます。

### 1. GitHub Secretsの設定

#### Cloudflare API Tokenの取得

1. https://dash.cloudflare.com/profile/api-tokens にアクセス
2. **Create Token** をクリック
3. **Edit Cloudflare Workers** テンプレートを使用
4. 以下の権限を設定：
   - Account > Account Settings > Read
   - Account > Workers Scripts > Edit
   - Account > D1 > Edit
5. **Continue to summary** をクリック
6. **Create Token** をクリック
7. トークンをコピー（⚠️ 一度しか表示されません）

#### Cloudflare Account IDの確認

1. https://dash.cloudflare.com/ にアクセス
2. **Workers & Pages** を選択
3. 右サイドバーに **Account ID** が表示される
4. コピーボタンでコピー

#### GitHub Secretsに追加

1. GitHubリポジトリ https://github.com/yymm/loutine にアクセス
2. **Settings > Secrets and variables > Actions** を選択
3. **New repository secret** をクリック
4. 以下の2つのSecretを追加：

**1つ目:**
```
Name: CLOUDFLARE_API_TOKEN
Secret: <コピーしたAPI Token>
```

**2つ目:**
```
Name: CLOUDFLARE_ACCOUNT_ID
Secret: <コピーしたAccount ID>
```

### 2. GitHub Actions ワークフローの作成

`.github/workflows/backend-deploy-dev.yml` を作成：

```yaml
name: Deploy Backend to Dev

on:
  push:
    branches:
      - main
    paths:
      - 'backend/**'
      - '.github/workflows/backend-deploy-dev.yml'
  workflow_dispatch:  # 手動実行を許可

defaults:
  run:
    working-directory: backend

jobs:
  deploy:
    name: Deploy to Cloudflare Workers (dev)
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v6
      
      - name: Setup Node.js
        uses: actions/setup-node@v6
        with:
          node-version: '24'
          cache: 'npm'
          cache-dependency-path: backend/package-lock.json
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run type check
        run: npm run ci:type
      
      - name: Run migrations to dev D1
        run: npm run dev:drizzle:migrate
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
      
      - name: Deploy to Cloudflare Workers (dev)
        run: npx wrangler deploy --config wrangler.dev.toml
        env:
          CLOUDFLARE_API_TOKEN: ${{ secrets.CLOUDFLARE_API_TOKEN }}
          CLOUDFLARE_ACCOUNT_ID: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
```

### 3. デプロイフロー

1. **PRを作成してレビュー**
2. **mainブランチにマージ**
3. **GitHub Actionsが自動実行:**
   - 型チェック実行
   - マイグレーション実行
   - Cloudflare Workers (dev)にデプロイ
4. **デプロイ完了通知**

### 4. デプロイ状況の確認

#### GitHub Actionsで確認

1. GitHubリポジトリ > **Actions** タブ
2. **Deploy Backend to Dev** ワークフローを選択
3. 最新の実行結果を確認

#### Cloudflare Dashboardで確認

1. https://dash.cloudflare.com/ にアクセス
2. **Workers & Pages** を選択
3. **backend** Worker を選択
4. **Deployments** タブでデプロイ履歴を確認

### 5. 手動デプロイ（緊急時）

GitHub Actionsから手動でデプロイ可能：

1. GitHubリポジトリ > **Actions** タブ
2. **Deploy Backend to Dev** ワークフローを選択
3. **Run workflow** をクリック
4. ブランチを選択（通常は`main`）
5. **Run workflow** をクリック

## mobile_uiの設定更新

デプロイ後、mobile_ui側の設定を更新します：

### 1. デプロイされたURLを確認

Cloudflare Dashboardまたはデプロイログから確認：
```
https://backend.your-account.workers.dev
```

### 2. mobile_ui/dart_defines/dev.env を更新

```env
flavor="dev"
baseUrl="https://backend.your-account.workers.dev"
customAuthKey="<Cloudflare Dashboardで設定した認証キー>"
```

### 3. mobile_uiで動作確認

```bash
cd mobile_ui
flutter run --dart-define-from-file=dart_defines/dev.env
```

## トラブルシューティング

### 認証エラー

```
Error: Not authenticated
```

**解決策:**
```bash
npx wrangler login
```

### マイグレーションエラー

```
Error: Database not found
```

**解決策:**
- D1データベースが存在するか確認：
  ```bash
  npx wrangler d1 list
  ```
- `wrangler.dev.toml` の `database_id` が正しいか確認

### デプロイ後に500エラー

```json
{"success":false,"message":"Server misconfiguration: authentication key not configured"}
```

**解決策:**
- Cloudflare Dashboardで `CUSTOM_AUTH_KEY` 環境変数を設定
- 設定後、Workerが自動的に再起動される（数秒待つ）

### GitHub Actions失敗

**Secretsが設定されていない:**
```
Error: CLOUDFLARE_API_TOKEN is not set
```

**解決策:**
- GitHub Secrets に `CLOUDFLARE_API_TOKEN` と `CLOUDFLARE_ACCOUNT_ID` を追加

**API Token権限不足:**
```
Error: Authorization failed
```

**解決策:**
- API Tokenの権限を確認
- 必要に応じて新しいTokenを作成

### D1データベース接続エラー

```
Error: D1_ERROR: no such table: links
```

**解決策:**
- マイグレーションを実行：
  ```bash
  npm run dev:drizzle:migrate
  ```

## セキュリティチェックリスト

デプロイ前に確認：

- [ ] `CUSTOM_AUTH_KEY`をCloudflare Dashboardで設定済み
- [ ] ローカルのデフォルトキーとは異なる強力なキーを使用
- [ ] GitHub SecretsにAPI TokenとAccount IDを設定済み
- [ ] API Tokenは必要最小限の権限のみ付与
- [ ] `wrangler.dev.toml`に本番用の認証キーをハードコードしていない

## デプロイフロー図

```
┌─────────────────────────────────────────────┐
│ 開発者がPRを作成                              │
│ ↓                                           │
│ レビュー＆承認                                │
│ ↓                                           │
│ mainブランチにマージ                          │
└─────────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────┐
│ GitHub Actions 自動実行                      │
│                                             │
│ 1. 型チェック                                │
│ 2. マイグレーション実行（dev D1）              │
│ 3. Cloudflare Workers (dev) にデプロイ       │
└─────────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────────┐
│ デプロイ完了                                  │
│                                             │
│ URL: https://backend.your-account.workers.dev│
└─────────────────────────────────────────────┘
```

## 参考リンク

- [Cloudflare Workers Documentation](https://developers.cloudflare.com/workers/)
- [Wrangler CLI Documentation](https://developers.cloudflare.com/workers/wrangler/)
- [Cloudflare D1 Documentation](https://developers.cloudflare.com/d1/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 次のステップ

1. ✅ ローカルからdev環境にデプロイ
2. ⬜ GitHub ActionsでCD構築
3. ⬜ mobile_uiの設定更新
4. ⬜ 動作確認
5. ⬜ カスタムドメインの設定（オプション）

---

**注意**: 
- デプロイ前に必ずCIが全てパスしていることを確認してください
- 現在は簡易認証（`X-Custom-Auth-Key`）を使用していますが、Phase 3でGoogle認証に移行予定です
