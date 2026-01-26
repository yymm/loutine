// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_new_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseNew)
final purchaseNewProvider = PurchaseNewProvider._();

final class PurchaseNewProvider
    extends $NotifierProvider<PurchaseNew, PurchaseNewData> {
  PurchaseNewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseNewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseNewHash();

  @$internal
  @override
  PurchaseNew create() => PurchaseNew();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseNewData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseNewData>(value),
    );
  }
}

String _$purchaseNewHash() => r'2b6eb3710a838c3c4b8c692fbc114e4e0a05c3f8';

abstract class _$PurchaseNew extends $Notifier<PurchaseNewData> {
  PurchaseNewData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PurchaseNewData, PurchaseNewData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PurchaseNewData, PurchaseNewData>,
              PurchaseNewData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
