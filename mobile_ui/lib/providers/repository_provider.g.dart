// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// TagApiClientのインスタンスを提供
///
/// テスト時はこのProviderをオーバーライドしてモックを注入できる

@ProviderFor(tagApiClient)
final tagApiClientProvider = TagApiClientProvider._();

/// TagApiClientのインスタンスを提供
///
/// テスト時はこのProviderをオーバーライドしてモックを注入できる

final class TagApiClientProvider extends $FunctionalProvider<TagApiClient, TagApiClient, TagApiClient> with $Provider<TagApiClient> {
  /// TagApiClientのインスタンスを提供
  ///
  /// テスト時はこのProviderをオーバーライドしてモックを注入できる
  TagApiClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagApiClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagApiClientHash();

  @$internal
  @override
  $ProviderElement<TagApiClient> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  TagApiClient create(Ref ref) {
    return tagApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagApiClient>(value),
    );
  }
}

String _$tagApiClientHash() => r'414b175089d75eda9899bd701d254d3885168eb1';

/// TagRepositoryのインスタンスを提供
///
/// tagApiClientProviderに依存しており、
/// APIクライアントを自動的に注入する

@ProviderFor(tagRepository)
final tagRepositoryProvider = TagRepositoryProvider._();

/// TagRepositoryのインスタンスを提供
///
/// tagApiClientProviderに依存しており、
/// APIクライアントを自動的に注入する

final class TagRepositoryProvider extends $FunctionalProvider<TagRepository, TagRepository, TagRepository> with $Provider<TagRepository> {
  /// TagRepositoryのインスタンスを提供
  ///
  /// tagApiClientProviderに依存しており、
  /// APIクライアントを自動的に注入する
  TagRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagRepositoryHash();

  @$internal
  @override
  $ProviderElement<TagRepository> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  TagRepository create(Ref ref) {
    return tagRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TagRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TagRepository>(value),
    );
  }
}

String _$tagRepositoryHash() => r'24cc9c879dfd5bc4d6dcd9a93ea7806e821e7a02';

/// CategoryApiClientのインスタンスを提供
///
/// テスト時はこのProviderをオーバーライドしてモックを注入できる

@ProviderFor(categoryApiClient)
final categoryApiClientProvider = CategoryApiClientProvider._();

/// CategoryApiClientのインスタンスを提供
///
/// テスト時はこのProviderをオーバーライドしてモックを注入できる

final class CategoryApiClientProvider extends $FunctionalProvider<CategoryApiClient, CategoryApiClient, CategoryApiClient> with $Provider<CategoryApiClient> {
  /// CategoryApiClientのインスタンスを提供
  ///
  /// テスト時はこのProviderをオーバーライドしてモックを注入できる
  CategoryApiClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'categoryApiClientProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoryApiClientHash();

  @$internal
  @override
  $ProviderElement<CategoryApiClient> $createElement(
    $ProviderPointer pointer,
  ) =>
      $ProviderElement(pointer);

  @override
  CategoryApiClient create(Ref ref) {
    return categoryApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryApiClient>(value),
    );
  }
}

String _$categoryApiClientHash() => r'd1a0720ee14e42a25d3ca8b36daa82729f09cbcd';

/// CategoryRepositoryのインスタンスを提供
///
/// categoryApiClientProviderに依存しており、
/// APIクライアントを自動的に注入する

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

/// CategoryRepositoryのインスタンスを提供
///
/// categoryApiClientProviderに依存しており、
/// APIクライアントを自動的に注入する

final class CategoryRepositoryProvider extends $FunctionalProvider<CategoryRepository, CategoryRepository, CategoryRepository> with $Provider<CategoryRepository> {
  /// CategoryRepositoryのインスタンスを提供
  ///
  /// categoryApiClientProviderに依存しており、
  /// APIクライアントを自動的に注入する
  CategoryRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'categoryRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) =>
      $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() => r'24c02982de576f7565d8804ab24f8d01297552ec';
