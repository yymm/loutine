// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_list_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CategoryListNotifier)
final categoryListProvider = CategoryListNotifierProvider._();

final class CategoryListNotifierProvider extends $NotifierProvider<CategoryListNotifier, List<Category>> {
  CategoryListNotifierProvider._() : super(from: null, argument: null, retry: null, name: r'categoryListProvider', isAutoDispose: true, dependencies: null, $allTransitiveDependencies: null);

  @override
  String debugGetCreateSourceHash() => _$categoryListNotifierHash();

  @$internal
  @override
  CategoryListNotifier create() => CategoryListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Category> value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<List<Category>>(value));
  }
}

String _$categoryListNotifierHash() => r'd7a5a8048aa7ebe4a0115a30086b2cf267639c64';

abstract class _$CategoryListNotifier extends $Notifier<List<Category>> {
  List<Category> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Category>, List<Category>>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<List<Category>, List<Category>>, List<Category>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(categoryListFuture)
final categoryListFutureProvider = CategoryListFutureProvider._();

final class CategoryListFutureProvider extends $FunctionalProvider<AsyncValue<List<Category>>, List<Category>, FutureOr<List<Category>>> with $FutureModifier<List<Category>>, $FutureProvider<List<Category>> {
  CategoryListFutureProvider._() : super(from: null, argument: null, retry: null, name: r'categoryListFutureProvider', isAutoDispose: true, dependencies: null, $allTransitiveDependencies: null);

  @override
  String debugGetCreateSourceHash() => _$categoryListFutureHash();

  @$internal
  @override
  $FutureProviderElement<List<Category>> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Category>> create(Ref ref) {
    return categoryListFuture(ref);
  }
}

String _$categoryListFutureHash() => r'84a090303814d52fcf5cf858f9f4c3b9e48cb541';
