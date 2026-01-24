# Dart Format継続的適用のベストプラクティス

**作成日**: 2026-01-24  
**目的**: コードフォーマットを継続的に維持する方法の提案

## 📋 推奨する3つのアプローチ

### 🥇 推奨度1: CI/CDでのチェック（必須）

**メリット:**
- ✅ 全開発者に強制適用
- ✅ PRマージ前に確実にチェック
- ✅ 設定不要（開発者側）
- ✅ チーム全体で統一

**実装:**

#### Option A: フォーマットチェックのみ（推奨）
```yaml
# .github/workflows/mobile-format-check.yml
name: Mobile UI Format Check

on:
  pull_request:
    paths:
      - 'mobile_ui/**'
      - '.github/workflows/mobile-format-check.yml'

defaults:
  run:
    working-directory: mobile_ui

jobs:
  format-check:
    name: Check Dart Formatting
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.38.7'
          cache: true
      
      - name: Check formatting
        run: dart format --set-exit-if-changed .
```

**特徴:**
- フォーマットされていないファイルがあればCIが失敗
- 開発者に修正を促す（自動修正はしない）
- コミット履歴が綺麗に保たれる

#### Option B: 自動修正してコミット
```yaml
- name: Run dart format
  run: dart format .

- name: Check for changes
  id: verify-changed-files
  run: |
    if git diff --quiet; then
      echo "changed=false" >> $GITHUB_OUTPUT
    else
      echo "changed=true" >> $GITHUB_OUTPUT
    fi

- name: Commit changes
  if: steps.verify-changed-files.outputs.changed == 'true'
  run: |
    git config user.name "github-actions[bot]"
    git config user.email "github-actions[bot]@users.noreply.github.com"
    git add .
    git commit -m "chore: apply dart format"
    git push
```

**注意点:**
- ❌ コミット履歴が汚れる
- ❌ 開発者のローカルとの同期が複雑
- ⚠️ 推奨しない

---

### 🥈 推奨度2: Pre-commit Hook（開発体験向上）

**メリット:**
- ✅ コミット前に自動フォーマット
- ✅ CIでのエラーを事前に防止
- ✅ 開発者の手間が減る

**実装:**

#### Husky + lint-staged（推奨）
```bash
# インストール
npm install --save-dev husky lint-staged

# huskyセットアップ
npx husky init
```

**package.json:**
```json
{
  "scripts": {
    "prepare": "husky install"
  },
  "lint-staged": {
    "mobile_ui/**/*.dart": [
      "dart format"
    ]
  }
}
```

**.husky/pre-commit:**
```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

cd mobile_ui
dart format $(git diff --cached --name-only --diff-filter=ACM | grep '\.dart$' | tr '\n' ' ')
```

#### Makefileを使った簡易版
```makefile
# mobile_ui/Makefile
.PHONY: format
format:
	dart format .

.PHONY: format-check
format-check:
	dart format --set-exit-if-changed .
```

**使用方法:**
```bash
# フォーマット実行
make format

# フォーマットチェック
make format-check
```

---

### 🥉 推奨度3: エディタ設定（個人の開発環境）

**メリット:**
- ✅ 保存時に自動フォーマット
- ✅ リアルタイムフィードバック
- ✅ 最も手間が少ない

**VS Code設定:**

**.vscode/settings.json:**
```json
{
  "editor.formatOnSave": true,
  "editor.formatOnPaste": true,
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": true,
    "editor.rulers": [80],
    "editor.selectionHighlight": false,
    "editor.suggest.snippetsPreventQuickSuggestions": false,
    "editor.suggestSelection": "first",
    "editor.tabCompletion": "onlySnippets",
    "editor.wordBasedSuggestions": "matchingDocuments"
  },
  "dart.lineLength": 80
}
```

**推奨拡張機能:**
- Dart
- Flutter

**IntelliJ IDEA / Android Studio設定:**
1. Settings > Languages & Frameworks > Flutter > Format code on save にチェック
2. Settings > Editor > Code Style > Dart > Line length を 80 に設定

---

## 🎯 推奨する組み合わせ

### 最小構成（必須）
```
✅ CI/CDでのフォーマットチェック
```

### 標準構成（推奨）
```
✅ CI/CDでのフォーマットチェック
✅ エディタ設定（保存時フォーマット）
```

### 理想構成（ベスト）
```
✅ CI/CDでのフォーマットチェック
✅ Pre-commit Hook
✅ エディタ設定（保存時フォーマット）
```

---

## 📊 各アプローチの比較

| アプローチ | 強制力 | 開発体験 | セットアップ | メンテナンス |
|----------|--------|---------|------------|-------------|
| CI/CD チェック | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| Pre-commit Hook | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| エディタ設定 | ⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

---

## 🚀 実装の優先順位

### Phase 1: すぐに実装（今日）
1. ✅ **CI/CDでのフォーマットチェック追加**
   - `.github/workflows/mobile-format-check.yml`を作成
   - PRで自動実行
   - 所要時間: 10分

### Phase 2: チームに周知（今週）
2. 📝 **READMEにフォーマットルールを記載**
   - `dart format`の使い方
   - エディタ設定の推奨
   - 所要時間: 15分

3. 🛠️ **エディタ設定ファイルの追加**
   - `.vscode/settings.json`をリポジトリに追加
   - 開発者が自動的に正しい設定を使用
   - 所要時間: 5分

### Phase 3: さらなる改善（来月）
4. 🔧 **Pre-commit Hookの導入検討**
   - チームの同意を得る
   - 試験的に導入
   - 所要時間: 30分

---

## 💡 ベストプラクティス

### DO ✅
- CI/CDでフォーマットチェックを必須にする
- エディタ設定ファイルをリポジトリに含める
- 保存時の自動フォーマットを推奨する
- `dart format`をドキュメント化する
- フォーマットエラーを早期に検出する

### DON'T ❌
- CI/CDで自動的にコミットを作成しない
- フォーマット専用のPRを頻繁に作らない
- 開発者に手動フォーマットを強制しない
- 複雑なフォーマット設定を追加しない
- Dartの標準フォーマットルールを変更しない

---

## 📝 次のステップ

### 今すぐ実装すべき
1. **CI/CDワークフローの追加**
   ```bash
   # ブランチ作成
   git checkout -b chore/add-format-check-ci
   
   # ワークフローファイル作成
   # .github/workflows/mobile-format-check.yml
   
   # コミット & PR作成
   git add .github/workflows/mobile-format-check.yml
   git commit -m "ci: add dart format check workflow"
   git push origin chore/add-format-check-ci
   ```

2. **VS Code設定の追加**
   ```bash
   # .vscode/settings.json を作成
   # 上記の設定をコピー
   
   git add .vscode/settings.json
   git commit -m "chore: add vscode dart format settings"
   ```

### 将来的に検討
- Pre-commit Hookの導入（チームの同意が得られたら）
- CI/CDでのanalyzeステップ追加
- Makefileの拡充

---

## 🔗 参考リンク

- [Dart Code Formatter](https://dart.dev/tools/dart-format)
- [Flutter Best Practices](https://docs.flutter.dev/development/tools/formatting)
- [GitHub Actions for Flutter](https://github.com/marketplace/actions/flutter-action)
- [Husky Documentation](https://typicode.github.io/husky/)

---

## 結論

**最も推奨する構成:**
```
1. CI/CDでのフォーマットチェック（必須）
2. .vscode/settings.jsonの追加（推奨）
3. READMEでの周知（推奨）
```

この3つを実装することで、フォーマットの一貫性を保ちながら、開発者の負担を最小限に抑えることができます。
