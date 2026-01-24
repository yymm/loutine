// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_new_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TagNewName)
final tagNewNameProvider = TagNewNameProvider._();

final class TagNewNameProvider extends $NotifierProvider<TagNewName, String> {
  TagNewNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagNewNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagNewNameHash();

  @$internal
  @override
  TagNewName create() => TagNewName();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$tagNewNameHash() => r'66aca1900bc687f78f09f3480371f2b6c8f5e582';

abstract class _$TagNewName extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(TagNewDescription)
final tagNewDescriptionProvider = TagNewDescriptionProvider._();

final class TagNewDescriptionProvider
    extends $NotifierProvider<TagNewDescription, String> {
  TagNewDescriptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagNewDescriptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagNewDescriptionHash();

  @$internal
  @override
  TagNewDescription create() => TagNewDescription();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$tagNewDescriptionHash() => r'e7db906b742f6309bc3cb08fb8fd6d4e0c3ad25b';

abstract class _$TagNewDescription extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
