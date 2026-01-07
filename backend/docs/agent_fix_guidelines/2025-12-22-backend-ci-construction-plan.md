# Backend CI/CD 構築計画

**作成日**: 2025-12-22  
**ステータス**: 計画中

## 📋 概要

backendディレクトリに変更がある場合のみ実行されるGitHub Actions CI/CDワークフローを構築する。

## 🎯 実装する既存要件

1. **Biome Linter** - `biome check`によるコード品質チェック
2. **Vitest** - `npm run test`によるユニットテスト実行
3. **Runn** - `npm run test:runn`によるE2Eテスト実行

## 💡 追加提案項目

### 必須レベル

1. **Type Check** - TypeScriptの型チェック (`tsc --noEmit`)
2. **Dependency Audit** - セキュリティ脆弱性チェック (`npm audit`)
3. **Build Check** - Wrangler buildの成功確認 (`wrangler deploy --dry-run`)

### 推奨レベル

4. **Spell Check** - cspell.jsonが存在するためスペルチェック (`npx cspell "src/**/*.ts"`)
5. **Dependency Cache** - npm依存関係のキャッシュで高速化
6. **Test Coverage** - Vitestのカバレッジレポート (`vitest --coverage`)

## 🏗️ ワークフロー構造

### トリガー設定

```yaml
name: Backend CI
on:
  push:
    paths: ['backend/**']
  pull_request:
    paths: ['backend/**']
```

### ジョブ構成

1. **Setup** - Node.js 24セットアップ、依存関係インストール
2. **Lint** - Biome check
3. **Type Check** - tsc --noEmit
4. **Test** - Vitest + Runn (並列または順次)
5. **Build** - Wrangler dry-run
6. **Security** - npm audit

## 📦 技術要件

### 環境

- **Node.js**: 24 (mise.tomlで指定)
- **Package Manager**: npm
- **Cloudflare Workers**: wrangler v4.56.0
- **Runn**: go製E2Eテストツール

### 現在のpackage.json scripts

```json
{
  "test": "vitest --run",
  "test:runn": "runn run ./test/runn/**/*.yml",
  "check": "biome check --write ./src",
  "lint": "biome lint --write ./src",
  "fmt": "biome format --write ./src"
}
```

## ⚠️ 考慮事項

### Runn実行の課題

- Runnはmiseでインストールされたgo toolに依存
- CI環境ではrunn installが必要
- GitHub Actionsでの実行方法:
  - Option 1: `go install github.com/k1LoW/runn/cmd/runn@latest`
  - Option 2: mise actionを使用してmise.tomlから自動インストール
  - Option 3: セルフホストランナーで事前インストール

### D1 Database

- Vitestはローカルのminiflare D1を使用（問題なし）
- Runnテストが実際のD1接続を必要とする場合、CLOUDFLARE_API_TOKENなどのシークレット設定が必要

### パス指定

- モノレポ構造のため、workding-directoryを`backend/`に設定
- または各コマンドで`cd backend &&`を使用

## 🚀 実装手順

1. `.github/workflows/backend-ci.yml`作成
2. paths filterでbackend/配下の変更のみトリガー
3. Node.js 24セットアップ
4. 依存関係のインストール＆キャッシュ
5. 各チェックステップの実装:
   - Biome check (CI用に`--write`オプションなし)
   - TypeScript type check
   - Vitest実行
   - Runn実行（環境セットアップ含む）
   - Wrangler dry-run
   - npm audit
6. 必要に応じてテストカバレッジレポート追加
7. ワークフロー実行テスト＆調整

## 📝 CI用コマンド修正案

CI環境では`--write`オプションを使わずにチェックのみ行うため、以下のコマンド追加を検討:

```json
{
  "ci:check": "biome check ./src",
  "ci:lint": "biome lint ./src",
  "ci:fmt": "biome format --check ./src",
  "ci:type": "tsc --noEmit",
  "ci:test": "vitest --run",
  "ci:test:e2e": "runn run ./test/runn/**/*.yml"
}
```

または、既存のコマンドをCI環境で適切なオプション付きで実行。

## 🎯 成功基準

- [ ] backendディレクトリの変更時のみCIが実行される
- [ ] すべてのチェックが並列または効率的に実行される
- [ ] CI実行時間が5分以内（目標）
- [ ] 失敗時のエラーメッセージが明確
- [ ] PRで自動的にチェック結果が表示される

## 🔄 次のステップ

1. ワークフローファイルの作成と実装
2. 初回実行とデバッグ
3. パフォーマンス最適化（キャッシュ等）
4. ドキュメント更新（README.mdにバッジ追加等）
