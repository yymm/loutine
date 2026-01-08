// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_new_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LinkNewNotifier)
final linkNewProvider = LinkNewNotifierProvider._();

final class LinkNewNotifierProvider
    extends $NotifierProvider<LinkNewNotifier, LinkNew> {
  LinkNewNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkNewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkNewNotifierHash();

  @$internal
  @override
  LinkNewNotifier create() => LinkNewNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkNew value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkNew>(value),
    );
  }
}

String _$linkNewNotifierHash() => r'637ff216ffa1db4d543f5ae1380c6df696ad6aeb';

abstract class _$LinkNewNotifier extends $Notifier<LinkNew> {
  LinkNew build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LinkNew, LinkNew>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LinkNew, LinkNew>,
              LinkNew,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
