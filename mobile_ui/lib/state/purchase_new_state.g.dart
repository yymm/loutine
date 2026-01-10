// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_new_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PurchaseNewNotifier)
final purchaseNewProvider = PurchaseNewNotifierProvider._();

final class PurchaseNewNotifierProvider extends $NotifierProvider<PurchaseNewNotifier, PurchaseNew> {
  PurchaseNewNotifierProvider._() : super(from: null, argument: null, retry: null, name: r'purchaseNewProvider', isAutoDispose: true, dependencies: null, $allTransitiveDependencies: null);

  @override
  String debugGetCreateSourceHash() => _$purchaseNewNotifierHash();

  @$internal
  @override
  PurchaseNewNotifier create() => PurchaseNewNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseNew value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<PurchaseNew>(value));
  }
}

String _$purchaseNewNotifierHash() => r'f0aafe09061c9e0d8d0e29e11b2e1224b751dc89';

abstract class _$PurchaseNewNotifier extends $Notifier<PurchaseNew> {
  PurchaseNew build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PurchaseNew, PurchaseNew>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<PurchaseNew, PurchaseNew>, PurchaseNew, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
