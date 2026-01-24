// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_new_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryNewName)
final categoryNewNameProvider = CategoryNewNameProvider._();

final class CategoryNewNameProvider
    extends $NotifierProvider<CategoryNewName, String> {
  CategoryNewNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryNewNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryNewNameHash();

  @$internal
  @override
  CategoryNewName create() => CategoryNewName();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$categoryNewNameHash() => r'023f8aa64f093d77d209ba2274824e666731d381';

abstract class _$CategoryNewName extends $Notifier<String> {
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

@ProviderFor(CategoryNewDescription)
final categoryNewDescriptionProvider = CategoryNewDescriptionProvider._();

final class CategoryNewDescriptionProvider
    extends $NotifierProvider<CategoryNewDescription, String> {
  CategoryNewDescriptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryNewDescriptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryNewDescriptionHash();

  @$internal
  @override
  CategoryNewDescription create() => CategoryNewDescription();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$categoryNewDescriptionHash() =>
    r'3cb044d8549628957783673e47c238a4d30d2f66';

abstract class _$CategoryNewDescription extends $Notifier<String> {
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
