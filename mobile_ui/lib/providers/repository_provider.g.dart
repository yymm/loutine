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

final class TagApiClientProvider
    extends $FunctionalProvider<TagApiClient, TagApiClient, TagApiClient>
    with $Provider<TagApiClient> {
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
  $ProviderElement<TagApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

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

final class TagRepositoryProvider
    extends $FunctionalProvider<TagRepository, TagRepository, TagRepository>
    with $Provider<TagRepository> {
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
  $ProviderElement<TagRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

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

final class CategoryApiClientProvider
    extends
        $FunctionalProvider<
          CategoryApiClient,
          CategoryApiClient,
          CategoryApiClient
        >
    with $Provider<CategoryApiClient> {
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
  ) => $ProviderElement(pointer);

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

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
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
  ) => $ProviderElement(pointer);

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

String _$categoryRepositoryHash() =>
    r'24c02982de576f7565d8804ab24f8d01297552ec';

/// LinkApiClientのインスタンスを提供
///
/// テスト時はこのProviderをオーバーライドしてモックを注入できる

@ProviderFor(linkApiClient)
final linkApiClientProvider = LinkApiClientProvider._();

/// LinkApiClientのインスタンスを提供
///
/// テスト時はこのProviderをオーバーライドしてモックを注入できる

final class LinkApiClientProvider
    extends $FunctionalProvider<LinkApiClient, LinkApiClient, LinkApiClient>
    with $Provider<LinkApiClient> {
  /// LinkApiClientのインスタンスを提供
  ///
  /// テスト時はこのProviderをオーバーライドしてモックを注入できる
  LinkApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkApiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkApiClientHash();

  @$internal
  @override
  $ProviderElement<LinkApiClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LinkApiClient create(Ref ref) {
    return linkApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkApiClient>(value),
    );
  }
}

String _$linkApiClientHash() => r'88b19e755c0f89f3e513d36e98fb90ff09a9abf5';

/// LinkRepositoryのインスタンスを提供
///
/// linkApiClientProviderに依存しており、
/// APIクライアントを自動的に注入する

@ProviderFor(linkRepository)
final linkRepositoryProvider = LinkRepositoryProvider._();

/// LinkRepositoryのインスタンスを提供
///
/// linkApiClientProviderに依存しており、
/// APIクライアントを自動的に注入する

final class LinkRepositoryProvider
    extends $FunctionalProvider<LinkRepository, LinkRepository, LinkRepository>
    with $Provider<LinkRepository> {
  /// LinkRepositoryのインスタンスを提供
  ///
  /// linkApiClientProviderに依存しており、
  /// APIクライアントを自動的に注入する
  LinkRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkRepositoryHash();

  @$internal
  @override
  $ProviderElement<LinkRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LinkRepository create(Ref ref) {
    return linkRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LinkRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LinkRepository>(value),
    );
  }
}

String _$linkRepositoryHash() => r'081f5ec569046bd81aa8ddda45f1ac992878b149';

/// PurchaseApiClientのインスタンスを提供
///
/// テスト時はこのProviderをオーバーライドしてモックを注入できる

@ProviderFor(purchaseApiClient)
final purchaseApiClientProvider = PurchaseApiClientProvider._();

/// PurchaseApiClientのインスタンスを提供
///
/// テスト時はこのProviderをオーバーライドしてモックを注入できる

final class PurchaseApiClientProvider
    extends
        $FunctionalProvider<
          PurchaseApiClient,
          PurchaseApiClient,
          PurchaseApiClient
        >
    with $Provider<PurchaseApiClient> {
  /// PurchaseApiClientのインスタンスを提供
  ///
  /// テスト時はこのProviderをオーバーライドしてモックを注入できる
  PurchaseApiClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseApiClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseApiClientHash();

  @$internal
  @override
  $ProviderElement<PurchaseApiClient> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchaseApiClient create(Ref ref) {
    return purchaseApiClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseApiClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseApiClient>(value),
    );
  }
}

String _$purchaseApiClientHash() => r'3000ca51148772791d2fe2a500f6b7af322160b4';

/// PurchaseRepositoryのインスタンスを提供
///
/// purchaseApiClientProviderに依存しており、
/// APIクライアントを自動的に注入する

@ProviderFor(purchaseRepository)
final purchaseRepositoryProvider = PurchaseRepositoryProvider._();

/// PurchaseRepositoryのインスタンスを提供
///
/// purchaseApiClientProviderに依存しており、
/// APIクライアントを自動的に注入する

final class PurchaseRepositoryProvider
    extends
        $FunctionalProvider<
          PurchaseRepository,
          PurchaseRepository,
          PurchaseRepository
        >
    with $Provider<PurchaseRepository> {
  /// PurchaseRepositoryのインスタンスを提供
  ///
  /// purchaseApiClientProviderに依存しており、
  /// APIクライアントを自動的に注入する
  PurchaseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'purchaseRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$purchaseRepositoryHash();

  @$internal
  @override
  $ProviderElement<PurchaseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PurchaseRepository create(Ref ref) {
    return purchaseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PurchaseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PurchaseRepository>(value),
    );
  }
}

String _$purchaseRepositoryHash() =>
    r'0e652b2cede3232e1905701fdb1a4a816c9e7348';

/// NoteRepositoryのインスタンスを提供

@ProviderFor(noteRepository)
final noteRepositoryProvider = NoteRepositoryProvider._();

/// NoteRepositoryのインスタンスを提供

final class NoteRepositoryProvider
    extends $FunctionalProvider<NoteRepository, NoteRepository, NoteRepository>
    with $Provider<NoteRepository> {
  /// NoteRepositoryのインスタンスを提供
  NoteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteRepositoryHash();

  @$internal
  @override
  $ProviderElement<NoteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NoteRepository create(Ref ref) {
    return noteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NoteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NoteRepository>(value),
    );
  }
}

String _$noteRepositoryHash() => r'cf883481505a8ca5829dae87a4fc24365b450347';
