// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_summary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 選択中の月を管理

@ProviderFor(PurchaseSummaryMonth)
final purchaseSummaryMonthProvider = PurchaseSummaryMonthProvider._();

/// 選択中の月を管理
final class PurchaseSummaryMonthProvider
    extends $NotifierProvider<PurchaseSummaryMonth, DateTime> {
  /// 選択中の月を管理
  PurchaseSummaryMonthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseSummaryMonthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseSummaryMonthHash();

  @$internal
  @override
  PurchaseSummaryMonth create() => PurchaseSummaryMonth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$purchaseSummaryMonthHash() =>
    r'48262e156ad3487c617c98b4d711f5175c65ba38';

/// 選択中の月を管理

abstract class _$PurchaseSummaryMonth extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 選択月のPurchaseデータをカテゴリー別に集計

@ProviderFor(purchaseCategorySummary)
final purchaseCategorySummaryProvider = PurchaseCategorySummaryProvider._();

/// 選択月のPurchaseデータをカテゴリー別に集計

final class PurchaseCategorySummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CategorySummary>>,
          List<CategorySummary>,
          FutureOr<List<CategorySummary>>
        >
    with
        $FutureModifier<List<CategorySummary>>,
        $FutureProvider<List<CategorySummary>> {
  /// 選択月のPurchaseデータをカテゴリー別に集計
  PurchaseCategorySummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseCategorySummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseCategorySummaryHash();

  @$internal
  @override
  $FutureProviderElement<List<CategorySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CategorySummary>> create(Ref ref) {
    return purchaseCategorySummary(ref);
  }
}

String _$purchaseCategorySummaryHash() =>
    r'5c509522b3a75df832aa53718fc0d1452aa2116f';

/// 選択月のPurchaseデータを日別・カテゴリー別に集計（積み上げ棒グラフ用）

@ProviderFor(purchaseDailyCategorySummary)
final purchaseDailyCategorySummaryProvider =
    PurchaseDailyCategorySummaryProvider._();

/// 選択月のPurchaseデータを日別・カテゴリー別に集計（積み上げ棒グラフ用）

final class PurchaseDailyCategorySummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailyCategorySummary>>,
          List<DailyCategorySummary>,
          FutureOr<List<DailyCategorySummary>>
        >
    with
        $FutureModifier<List<DailyCategorySummary>>,
        $FutureProvider<List<DailyCategorySummary>> {
  /// 選択月のPurchaseデータを日別・カテゴリー別に集計（積み上げ棒グラフ用）
  PurchaseDailyCategorySummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseDailyCategorySummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseDailyCategorySummaryHash();

  @$internal
  @override
  $FutureProviderElement<List<DailyCategorySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DailyCategorySummary>> create(Ref ref) {
    return purchaseDailyCategorySummary(ref);
  }
}

String _$purchaseDailyCategorySummaryHash() =>
    r'1e03f7c80a9add192ec6ecb7955280cf0d1c1f37';

/// 選択月のPurchaseデータを日別に集計

@ProviderFor(purchaseDailySummary)
final purchaseDailySummaryProvider = PurchaseDailySummaryProvider._();

/// 選択月のPurchaseデータを日別に集計

final class PurchaseDailySummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DailySummary>>,
          List<DailySummary>,
          FutureOr<List<DailySummary>>
        >
    with
        $FutureModifier<List<DailySummary>>,
        $FutureProvider<List<DailySummary>> {
  /// 選択月のPurchaseデータを日別に集計
  PurchaseDailySummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseDailySummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseDailySummaryHash();

  @$internal
  @override
  $FutureProviderElement<List<DailySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DailySummary>> create(Ref ref) {
    return purchaseDailySummary(ref);
  }
}

String _$purchaseDailySummaryHash() =>
    r'17ab950d054127d40989a1b74d1813db365345cc';

/// グラフ表示モード（日次/週次）

@ProviderFor(PurchaseChartMode)
final purchaseChartModeProvider = PurchaseChartModeProvider._();

/// グラフ表示モード（日次/週次）
final class PurchaseChartModeProvider
    extends $NotifierProvider<PurchaseChartMode, ChartMode> {
  /// グラフ表示モード（日次/週次）
  PurchaseChartModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseChartModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseChartModeHash();

  @$internal
  @override
  PurchaseChartMode create() => PurchaseChartMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChartMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChartMode>(value),
    );
  }
}

String _$purchaseChartModeHash() => r'dd6a91f994cf4a3b48a0307933ac9e4b51583583';

/// グラフ表示モード（日次/週次）

abstract class _$PurchaseChartMode extends $Notifier<ChartMode> {
  ChartMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ChartMode, ChartMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ChartMode, ChartMode>,
              ChartMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 選択月のPurchaseデータを週別に集計

@ProviderFor(purchaseWeeklySummary)
final purchaseWeeklySummaryProvider = PurchaseWeeklySummaryProvider._();

/// 選択月のPurchaseデータを週別に集計

final class PurchaseWeeklySummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeeklySummary>>,
          List<WeeklySummary>,
          FutureOr<List<WeeklySummary>>
        >
    with
        $FutureModifier<List<WeeklySummary>>,
        $FutureProvider<List<WeeklySummary>> {
  /// 選択月のPurchaseデータを週別に集計
  PurchaseWeeklySummaryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseWeeklySummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseWeeklySummaryHash();

  @$internal
  @override
  $FutureProviderElement<List<WeeklySummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WeeklySummary>> create(Ref ref) {
    return purchaseWeeklySummary(ref);
  }
}

String _$purchaseWeeklySummaryHash() =>
    r'd1fdff3ca2a0b880224dcca78154e83126c18612';

/// 選択月の合計金額を計算

@ProviderFor(purchaseMonthlyTotal)
final purchaseMonthlyTotalProvider = PurchaseMonthlyTotalProvider._();

/// 選択月の合計金額を計算

final class PurchaseMonthlyTotalProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// 選択月の合計金額を計算
  PurchaseMonthlyTotalProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseMonthlyTotalProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseMonthlyTotalHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return purchaseMonthlyTotal(ref);
  }
}

String _$purchaseMonthlyTotalHash() =>
    r'dc133418ea3f080e72036c4693a9a15182fddea1';
