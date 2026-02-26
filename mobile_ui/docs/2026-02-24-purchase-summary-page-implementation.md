# Purchase Summary Page Implementation Plan

**作成日**: 2026-02-24  
**対象**: Purchase Summary ページの実装

## 概要

PurchaseページのAppBarにある`bar_chart`ボタンを押した際に遷移する、月ごとのpurchaseサマリ情報を表示するページを実装する。

## 実装する機能

### 1. カテゴリーごとの金額の割合を表示する円グラフ
- 選択された月のpurchaseデータをカテゴリー別に集計
- 各カテゴリーの金額割合を円グラフで可視化
- カテゴリー名と金額、割合を表示

### 2. 日付ごと/週ごとの金額合計を表示する棒グラフ
- デフォルトは日次表示
- ユーザーが日次/週次を切り替え可能なトグルボタンを設置
- X軸: 日付または週
- Y軸: 金額合計

### 3. その月のPurchaseデータのCardリスト
- 日付順にソートされたpurchaseのリスト表示
- 各Cardには: タイトル、金額、日付、カテゴリー（取得可能であれば）を表示

## データソース

`home_calendar_provider.dart`の`CalendarEventData` providerが提供する月ごとのデータを再利用する。

### 現在のデータフロー
```
CalendarEventData(focusedMonth)
  ↓
  fetchPurchases(startDate, endDate) via purchaseRepository
  ↓
  List<Purchase>
  ↓
  CalendarEventItem.fromPurchase()
```

### 新しいデータフロー
```
CalendarEventData(focusedMonth)
  ↓
  Map<DateTime, List<CalendarEventItem>>から
  Purchase typeのものをフィルタリング
  ↓
  PurchaseSummaryページで集計・表示
```

## 技術スタック

- **グラフライブラリ**: `fl_chart`
- **状態管理**: Riverpod (既存のproviderパターンに従う)
- **ルーティング**: `/purchase/summary`

## 実装が必要なファイル

### 1. Provider層
```
lib/providers/purchase/purchase_summary_provider.dart
lib/providers/purchase/purchase_summary_provider.g.dart
```

**責務**:
- 月の選択状態管理
- グラフ表示モード（日次/週次）の状態管理
- CalendarEventDataからpurchaseデータを抽出・集計

**主要なProvider**:
- `purchaseSummaryMonthProvider`: 選択中の月を管理
- `purchaseChartModeProvider`: 日次/週次の切り替え状態
- `purchaseSummaryDataProvider`: 選択月のpurchaseデータを集計して提供

### 2. UI層
```
lib/ui/purchase/summary/purchase_summary_page.dart
lib/ui/purchase/summary/widgets/category_pie_chart_widget.dart
lib/ui/purchase/summary/widgets/amount_bar_chart_widget.dart
lib/ui/purchase/summary/widgets/purchase_card_list_widget.dart
```

**purchase_summary_page.dart**:
- ページ全体のレイアウト
- 月選択UI（前月/次月ボタン）
- 3つのウィジェットを配置

**category_pie_chart_widget.dart**:
- `fl_chart`のPieChartを使用
- カテゴリー別集計データを円グラフで表示
- 凡例表示

**amount_bar_chart_widget.dart**:
- `fl_chart`のBarChartを使用
- 日次/週次トグルボタン
- X軸: 日付/週、Y軸: 金額

**purchase_card_list_widget.dart**:
- Cardウィジェットでpurchaseリストを表示
- 日付降順でソート

### 3. ルーティング設定
```
lib/routes/app_router.dart (既存ファイルを修正)
```

`/purchase/summary`へのルート追加

### 4. 既存ファイルの修正
```
lib/ui/purchase/form/purchase_form_main.dart
```

AppBarの`bar_chart`ボタンに`onPressed`ハンドラを追加し、`/purchase/summary`へ遷移

## データモデルの課題

### ⚠️ 重要: Purchaseモデルにcategory情報が不足

現在の`Purchase`モデルには`category`フィールドが存在しない。カテゴリー別円グラフを実装するには以下の対応が必要:

**対応方針（別途相談）**:
1. `Purchase`モデルに`categoryId`または`category`フィールドを追加
2. バックエンドAPIがcategory情報を返すように修正
3. `CalendarEventItem`の`category`フィールドに正しく値を設定

**暫定対応**:
- category情報が取得できない場合は「未分類」として扱う
- 円グラフは実装するが、全て「未分類」として表示される状態とする
- category対応後に自動的に正しく表示されるよう実装

## 実装手順

### Phase 1: Provider層の実装
1. `purchase_summary_provider.dart`を作成
   - 月選択provider
   - グラフモードprovider
   - データ集計provider（CalendarEventDataを参照）

### Phase 2: UI基盤の実装
2. `purchase_summary_page.dart`を作成
   - 基本レイアウト
   - 月選択UI
   - ローディング/エラー表示

### Phase 3: グラフウィジェットの実装
3. `fl_chart`パッケージを追加（pubspec.yaml）
4. `category_pie_chart_widget.dart`を作成
   - 円グラフ実装
   - category情報が無い場合の暫定対応
5. `amount_bar_chart_widget.dart`を作成
   - 棒グラフ実装
   - 日次/週次切り替え

### Phase 4: リスト表示の実装
6. `purchase_card_list_widget.dart`を作成
   - Cardリスト表示
   - 日付降順ソート

### Phase 5: ルーティング統合
7. `app_router.dart`にルート追加
8. `purchase_form_main.dart`のボタンにナビゲーション追加

### Phase 6: テスト・調整
9. 動作確認
10. レイアウト調整
11. エラーハンドリング確認

## デザインガイドライン

### レイアウト構成
```
AppBar (月選択UI)
  ├─ 前月ボタン
  ├─ 現在の月表示
  └─ 次月ボタン

Body (SingleChildScrollView)
  ├─ 月の合計金額表示
  ├─ カテゴリー円グラフセクション
  │   └─ PieChart + 凡例
  ├─ 金額推移棒グラフセクション
  │   ├─ 日次/週次トグル
  │   └─ BarChart
  └─ Purchaseリストセクション
      └─ Card × N
```

### カラー
- 既存のテーマカラーに従う
- 円グラフ: カテゴリーごとに異なる色（Material Colorsを使用）
- 棒グラフ: 統一色（例: Colors.blue）

## テスト戦略

### 単体テスト
- `purchase_summary_provider_test.dart`
  - 月選択の状態変更
  - グラフモードの切り替え
  - データ集計ロジック

### ウィジェットテスト
- 各ウィジェットの表示確認
- グラフの描画確認（goldenテストは任意）

### 結合テスト
- ページ全体の動作確認
- ナビゲーション確認

## 残課題・将来対応

1. **Purchaseモデルのcategory対応** (別途相談)
   - モデル拡張
   - API修正
   - データマッピング修正

2. **パフォーマンス最適化**
   - 大量データの場合の集計処理
   - グラフ描画の最適化

3. **機能拡張案**
   - 月またぎの比較表示
   - カテゴリーフィルタリング
   - CSVエクスポート

## 参考資料

- [fl_chart公式ドキュメント](https://pub.dev/packages/fl_chart)
- 既存実装: `lib/providers/home/home_calendar_provider.dart`
- 既存実装: `lib/ui/home/home_calendar.dart`
