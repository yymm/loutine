// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 購入履歴一覧を取得するProvider

@ProviderFor(PurchaseList)
final purchaseListProvider = PurchaseListProvider._();

/// 購入履歴一覧を取得するProvider
final class PurchaseListProvider
    extends $AsyncNotifierProvider<PurchaseList, List<Purchase>> {
  /// 購入履歴一覧を取得するProvider
  PurchaseListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseListHash();

  @$internal
  @override
  PurchaseList create() => PurchaseList();
}

String _$purchaseListHash() => r'e398b7d5a410246878640e655fc1c1970318bfc6';

/// 購入履歴一覧を取得するProvider

abstract class _$PurchaseList extends $AsyncNotifier<List<Purchase>> {
  FutureOr<List<Purchase>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Purchase>>, List<Purchase>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Purchase>>, List<Purchase>>,
              AsyncValue<List<Purchase>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
