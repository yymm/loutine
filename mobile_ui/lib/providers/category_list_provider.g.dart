// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$categoryListFutureHash() =>
    r'44f8b8b4aef87d8ea3608f359582f54020f5b228';

/// See also [categoryListFuture].
@ProviderFor(categoryListFuture)
final categoryListFutureProvider =
    AutoDisposeFutureProvider<List<Category>>.internal(
      categoryListFuture,
      name: r'categoryListFutureProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryListFutureHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CategoryListFutureRef = AutoDisposeFutureProviderRef<List<Category>>;
String _$categoryListHash() => r'aa68dcf755959f2606cda3d2dc9baaf256150916';

/// See also [CategoryList].
@ProviderFor(CategoryList)
final categoryListProvider =
    AutoDisposeNotifierProvider<CategoryList, List<Category>>.internal(
      CategoryList.new,
      name: r'categoryListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$categoryListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CategoryList = AutoDisposeNotifier<List<Category>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
