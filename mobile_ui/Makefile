# FVM対応: fvmがインストールされていればfvm flutter、なければflutterを使用
FLUTTER := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm flutter" || echo "flutter")
DART := $(shell command -v fvm >/dev/null 2>&1 && echo "fvm dart" || echo "dart")

.PHONY: help
help: ## ヘルプを表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

.PHONY: fmt
fmt: ## コードフォーマット
	$(DART) format -l 1000 lib test

.PHONY: get
get: ## 依存関係の取得
	$(FLUTTER) pub get

.PHONY: build
build: ## コード生成（一回だけ実行）
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

.PHONY: watch
watch: ## コード生成（監視モード・開発中に推奨）
	$(FLUTTER) pub run build_runner watch --delete-conflicting-outputs

.PHONY: clean-build
clean-build: ## 生成されたコードをクリーンして再生成
	$(FLUTTER) pub run build_runner clean
	$(FLUTTER) pub run build_runner build --delete-conflicting-outputs

.PHONY: analyze
analyze: ## 静的解析
	$(FLUTTER) analyze

.PHONY: test
test: ## テスト実行
	$(FLUTTER) test

.PHONY: local
local: ## ローカル環境で実行
	$(FLUTTER) run -d 64d62136f5ae --dart-define-from-file=dart_defines/local.env

.PHONY: emulator
emulator: ## エミュレーターで実行
	$(FLUTTER) run -d emulator-5554

.PHONY: dev
dev: ## 開発環境向けビルド
	$(FLUTTER) build android --dart-define-from-file=dart_defines/dev.env

.PHONY: prod
prod: ## 本番環境向けビルド
	$(FLUTTER) build android --dart-define-from-file=dart_defines/prod.env

.PHONY: icons
icons: ## アイコン生成
	$(FLUTTER) pub run flutter_launcher_icons:main

.PHONY: clean
clean: ## Flutterクリーン
	$(FLUTTER) clean

.PHONY: setup
setup: get build ## 初回セットアップ（依存関係取得+コード生成）
