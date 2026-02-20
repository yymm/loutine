# GitHub Actions 自動デプロイのセットアップガイド

**作成日**: 2026-02-20  
**対象**: backend の Cloudflare Workers (dev環境) への自動デプロイ

## 概要

mainブランチにマージされると、GitHub Actionsが自動的にCloudflare Workers (dev環境) にデプロイします。

## セットアップ手順

### 1. Cloudflare API Tokenの取得

#### 手順

1. https://dash.cloudflare.com/profile/api-tokens にアクセス
2. **Create Token** ボタンをクリック
3. **Edit Cloudflare Workers** テンプレートを選択
4. 権限を確認・追加：
   - ✅ Account > Account Settings > Read
   - ✅ Account > Workers Scripts > Edit
   - ✅ Account > D1 > Edit
5. **Continue to summary** をクリック
6. **Create Token** をクリック
7. 表示されたトークンをコピー（⚠️ 一度しか表示されません）

#### トークンのテスト（オプション）

```bash
# トークンが正しく動作するかテスト
export CLOUDFLARE_API_TOKEN="your-token-here"
cd backend
npx wrangler whoami
```

期待される出力：
```
👋 You are logged in with an API Token, associated with the email 'your-email@example.com'.
```

### 2. Cloudflare Account IDの確認

#### 手順

1. https://dash.cloudflare.com/ にアクセス
2. 左サイドバーの **Workers & Pages** を選択
3. 右サイドバーに **Account ID** が表示される
4. コピーボタンをクリックしてコピー

Account IDは以下のような形式：
```
1234567890abcdef1234567890abcdef
```

### 3. GitHub Secretsの設定

#### 手順

1. GitHubリポジトリ https://github.com/yymm/loutine にアクセス
2. **Settings** タブを選択
3. 左サイドバーの **Secrets and variables > Actions** を選択
4. **New repository secret** ボタンをクリック
5. 以下の2つのSecretを追加：

#### Secret 1: CLOUDFLARE_API_TOKEN

```
Name: CLOUDFLARE_API_TOKEN
Secret: <ステップ1でコピーしたAPI Token>
```

- **Add secret** をクリック

#### Secret 2: CLOUDFLARE_ACCOUNT_ID

```
Name: CLOUDFLARE_ACCOUNT_ID
Secret: <ステップ2でコピーしたAccount ID>
```

- **Add secret** をクリック

#### 設定確認

Settings > Secrets and variables > Actions で以下の2つが表示されていることを確認：

- ✅ CLOUDFLARE_API_TOKEN
- ✅ CLOUDFLARE_ACCOUNT_ID

### 4. ワークフローファイルの確認

`.github/workflows/backend-deploy-dev.yml` が存在することを確認：

```bash
ls -la .github/workflows/backend-deploy-dev.yml
```

このファイルは既にリポジトリに含まれています。

### 5. 初回デプロイのテスト

#### 方法A: 手動実行（推奨）

1. GitHubリポジトリ > **Actions** タブ
2. 左サイドバーの **Deploy Backend to Dev** を選択
3. **Run workflow** ボタンをクリック
4. Branch: **main** を選択
5. **Run workflow** をクリック

#### 方法B: mainブランチにマージ

1. PRを作成
2. CIが全てパスすることを確認
3. mainブランチにマージ
4. GitHub Actionsが自動実行

### 6. デプロイの確認

#### GitHub Actionsで確認

1. Actions タブで実行状況を確認
2. 各ステップのログを確認：
   - ✅ Checkout repository
   - ✅ Setup Node.js
   - ✅ Install dependencies
   - ✅ Run type check
   - ✅ Run migrations to dev D1
   - ✅ Deploy to Cloudflare Workers (dev)

#### Cloudflare Dashboardで確認

1. https://dash.cloudflare.com/ にアクセス
2. **Workers & Pages** を選択
3. **backend** Worker を選択
4. **Deployments** タブでデプロイ履歴を確認
5. デプロイされたURLを確認（例: `https://backend.your-account.workers.dev`）

### 7. 環境変数の設定

デプロイ後、Cloudflare Dashboardで認証キーを設定：

1. https://dash.cloudflare.com/ にアクセス
2. **Workers & Pages > backend** を選択
3. **Settings > Variables** を選択
4. **Add variable** をクリック
5. 以下を設定：

```
Variable name: CUSTOM_AUTH_KEY
Value: <強力なランダム文字列>
Type: Text
Encrypt: ✅ (推奨)
```

**認証キーの生成:**
```bash
openssl rand -base64 32
```

6. **Save** をクリック

### 8. 動作確認

デプロイされたAPIに接続テスト：

```bash
# 認証キーを使ってリクエスト
curl -H "X-Custom-Auth-Key: <your-secret-key>" \
  https://backend.your-account.workers.dev/api/v1/links
```

**期待される応答:**
```json
[]
```

または既にデータがある場合：
```json
[{"id":1,"title":"...","url":"...","created_at":"...","updated_at":"..."}]
```

## トラブルシューティング

### GitHub Actionsが失敗する

#### エラー: "CLOUDFLARE_API_TOKEN is not set"

**原因:** GitHub Secretsが設定されていない

**解決策:**
1. Settings > Secrets and variables > Actions を確認
2. `CLOUDFLARE_API_TOKEN` と `CLOUDFLARE_ACCOUNT_ID` が設定されているか確認
3. 設定されていない場合は上記の手順で追加

#### エラー: "Authentication error"

**原因:** API Tokenの権限不足または有効期限切れ

**解決策:**
1. Cloudflare Dashboardで新しいAPI Tokenを作成
2. GitHub Secretsを更新

#### エラー: "Database not found"

**原因:** D1データベースが存在しない、または `wrangler.dev.toml` の設定が間違っている

**解決策:**
1. `wrangler.dev.toml` の `database_id` を確認
2. Cloudflare Dashboardで該当するD1データベースが存在するか確認

### デプロイ後に500エラー

#### エラー: "Server misconfiguration: authentication key not configured"

**原因:** Cloudflare Dashboardで `CUSTOM_AUTH_KEY` 環境変数が設定されていない

**解決策:**
1. Cloudflare Dashboard > Workers & Pages > backend > Settings > Variables
2. `CUSTOM_AUTH_KEY` を追加
3. 数秒待ってから再度テスト

### マイグレーションエラー

#### エラー: "No migrations to apply"

**原因:** マイグレーションが既に適用済み、または `drizzle/migrations/` にファイルがない

**解決策:**
- これは正常な動作です
- 新しいマイグレーションがある場合のみ適用されます

## デプロイフロー図

```
┌─────────────────────────────────────────┐
│ 開発者がPRを作成                          │
│ ↓                                       │
│ CIが実行（lint, test, type check）      │
│ ↓                                       │
│ レビュー＆承認                            │
│ ↓                                       │
│ mainブランチにマージ                      │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│ GitHub Actions 自動実行                  │
│                                         │
│ 1. リポジトリをチェックアウト              │
│ 2. Node.js 24をセットアップ              │
│ 3. 依存関係をインストール                 │
│ 4. 型チェック実行                        │
│ 5. D1にマイグレーション適用               │
│ 6. Cloudflare Workers (dev) にデプロイ   │
└─────────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────────┐
│ デプロイ完了                              │
│                                         │
│ URL: https://backend.*.workers.dev       │
└─────────────────────────────────────────┘
```

## セキュリティのベストプラクティス

### API Tokenの管理

- ✅ 必要最小限の権限のみ付与
- ✅ トークンを定期的にローテーション（3-6ヶ月ごと）
- ✅ 使用していないトークンは削除
- ❌ Global API Keyは使用しない

### GitHub Secrets

- ✅ Secretsは暗号化されて保存される
- ✅ ワークフローログには表示されない（`***`でマスクされる）
- ❌ Secretsをコードにハードコードしない

### 環境変数

- ✅ `CUSTOM_AUTH_KEY` は必ずCloudflare Dashboardで設定
- ✅ 強力なランダム文字列を使用（32文字以上推奨）
- ❌ デフォルトキーをそのまま使用しない

## 次のステップ

1. ✅ GitHub Secretsを設定
2. ✅ 初回デプロイをテスト
3. ✅ Cloudflare Dashboardで環境変数を設定
4. ✅ mobile_uiの設定を更新（`dart_defines/dev.env`）
5. ⬜ カスタムドメインの設定（オプション）
6. ⬜ Phase 3: Google認証の実装

## 参考リンク

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Cloudflare Workers Documentation](https://developers.cloudflare.com/workers/)
- [Wrangler CLI Documentation](https://developers.cloudflare.com/workers/wrangler/)
- [GitHub Encrypted Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)

---

**作成者**: GitHub Copilot CLI  
**最終更新**: 2026-02-20
