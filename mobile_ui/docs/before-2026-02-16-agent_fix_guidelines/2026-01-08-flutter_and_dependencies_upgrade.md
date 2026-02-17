# Flutter and Dependencies Upgrade Strategy

## 背景

Flutter 3.38.5 および依存関係のアップデートを実施する際、特にRiverpodのメジャーバージョンアップ（2.x → 3.x）の影響が大きいことが判明した。

### 現状の課題

- テストカバレッジが極めて低い（テストファイル1個 vs ソースファイル48個）
- Riverpodに関する知識が不足しており、変更の妥当性判断が困難
- テストが貧弱なため、依存関係のアップデートやリファクタリング時にランタイムエラーを捕捉できない
- **Riverpodの実装が古い方式**：コードジェネレーターを使わず手動でProviderを定義している
  - 現在：`StateNotifierProvider`、`FutureProvider`などを手動定義
  - 推奨：`@riverpod`アノテーション + コードジェネレーター

### 技術的な制約

調査の結果、以下の依存関係の制約が判明：
- Flutter 3.27.0未満では新しいパッケージバージョンが使えない（Dart SDKバージョン要件）
- Flutter 3.38.5は`_macros`システムが変更されており、Riverpod 2.6.xと非互換
- **結論**: Riverpod以外だけをアップデートすることは不可能。Flutter + Riverpod + 他パッケージを同時アップデートする必要がある

## 修正されたアプローチ

以下の2段階で進める。

### Phase 1: テスト拡充（現行のFlutter 3.24.3、Riverpod 2.6.x）

**目的**: 
- Riverpod移行時のリグレッション検出
- コードジェネレーター方式への移行準備

**実施内容**:
- ブランチ: `feature/add-riverpod-tests`
- 現行のFlutter 3.24.3、Riverpod 2.6.xのまま実施
- Riverpodに依存する主要な状態管理ロジックのテストを追加
  - `state/` ディレクトリ内の9個のStateNotifier
  - 特に重要: `categoryListProvider`, `tagListProvider`, `themeModeProvider`など
- テストカバレッジの向上（目標：State管理層80%以上）
- mainにマージ

### Phase 2: Flutter + Riverpod + 全依存関係の同時アップデート

**目的**: 
- Flutter 3.38.5へアップデート
- Riverpod 3.xへアップデート
- コードジェネレーター方式へ移行

**実施内容**:
- ブランチ: `feature/upgrade-flutter-and-riverpod`
- Flutter 3.38.5にアップデート
- Riverpod 3.xおよび全依存関係をアップデート
- **Riverpodのコードジェネレーター方式へ移行**：
  1. `@riverpod`アノテーションの学習
  2. 既存のProviderを1つずつ移行
  3. 各移行後にテスト実行で動作確認
- Breaking changesへの対応
- mainにマージ

### Riverpodコードジェネレーター移行の詳細

#### 現在の実装パターン
```dart
final categoryListProvider = StateNotifierProvider<CategoryListNotifier, List<Category>>((ref) => CategoryListNotifier());
```

#### 移行後の実装パターン
```dart
@riverpod
class CategoryList extends _$CategoryList {
  @override
  List<Category> build() => [];
  // メソッド実装
}
```

#### 移行順序（優先度順）
1. `theme_mode_state.dart` - シンプルな状態管理（学習用）
2. `tag_list_state.dart`, `category_list_state.dart` - 基本的なCRUD
3. `tag_new_state.dart`, `category_new_state.dart` - フォーム状態
4. 残りのstate（`link_new_state.dart`, `purchase_new_state.dart`, `note_new_state.dart`, `home_calendar_state.dart`）

## メリット

1. **リスクの分散**: テストを先に追加することで、移行時の問題を早期検出
2. **段階的な学習**: Phase 2でRiverpodコードジェネレーター方式を学習しながら移行
3. **安全性の向上**: テストによる保護の下でアップデート・リファクタリング可能
4. **技術的負債の解消**: 古いRiverpod実装パターンから推奨方式へ移行

## 想定スケジュール

- Phase 1: 3-5日（テストの量による）
- Phase 2: 3-5日（Riverpod学習と移行を含む）

合計: 約1-2週間

## 注意事項

- Phase 1では、最低限カバーすべき範囲を明確にすること（目標：State層80%）
- Phase 2では、Riverpodコードジェネレーター方式を1つずつ学習しながら移行
- 各Providerの移行後、必ずテストを実行して動作確認
- 各Phaseでmainへのマージ前に動作確認を徹底すること

## 参考リンク

- [Riverpod Code Generation](https://riverpod.dev/docs/concepts/about_code_generation)
- [Riverpod Migration Guide](https://riverpod.dev/docs/migration/from_state_notifier)
