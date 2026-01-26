// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_new_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LinkNew)
final linkNewProvider = LinkNewProvider._();

final class LinkNewProvider extends $NotifierProvider<LinkNew, LinkNewData> {
  LinkNewProvider._()
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
  String debugGetCreateSourceHash() => _$linkNewHash();

  @$internal
  @override
  LinkNew create() => LinkNew();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkNewData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkNewData>(value),
    );
  }
}

String _$linkNewHash() => r'4745894061af8a9504497ff85d386af6b1388bff';

abstract class _$LinkNew extends $Notifier<LinkNewData> {
  LinkNewData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LinkNewData, LinkNewData>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<LinkNewData, LinkNewData>, LinkNewData, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
