// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// カテゴリ一覧の状態を管理するProvider
///
/// 変更点:
/// - APIクライアントを直接使わず、Repositoryを経由してデータ取得
/// - JSONパース処理はRepositoryに委譲
/// - Providerはデータの状態管理に専念

@ProviderFor(CategoryList)
final categoryListProvider = CategoryListProvider._();

/// カテゴリ一覧の状態を管理するProvider
///
/// 変更点:
/// - APIクライアントを直接使わず、Repositoryを経由してデータ取得
/// - JSONパース処理はRepositoryに委譲
/// - Providerはデータの状態管理に専念
final class CategoryListProvider
    extends $NotifierProvider<CategoryList, List<Category>> {
  /// カテゴリ一覧の状態を管理するProvider
  ///
  /// 変更点:
  /// - APIクライアントを直接使わず、Repositoryを経由してデータ取得
  /// - JSONパース処理はRepositoryに委譲
  /// - Providerはデータの状態管理に専念
  CategoryListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'categoryListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoryListHash();

  @$internal
  @override
  CategoryList create() => CategoryList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Category> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Category>>(value),
    );
  }
}

String _$categoryListHash() => r'5880d994e84d476b2c018e242f7aaa4da96222a7';

/// カテゴリ一覧の状態を管理するProvider
///
/// 変更点:
/// - APIクライアントを直接使わず、Repositoryを経由してデータ取得
/// - JSONパース処理はRepositoryに委譲
/// - Providerはデータの状態管理に専念

abstract class _$CategoryList extends $Notifier<List<Category>> {
  List<Category> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Category>, List<Category>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<Category>, List<Category>>,
        List<Category>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// カテゴリ一覧をFutureとして提供するProvider
///
/// 初回表示時などに使用

@ProviderFor(categoryListFuture)
final categoryListFutureProvider = CategoryListFutureProvider._();

/// カテゴリ一覧をFutureとして提供するProvider
///
/// 初回表示時などに使用

final class CategoryListFutureProvider extends $FunctionalProvider<
        AsyncValue<List<Category>>, List<Category>, FutureOr<List<Category>>>
    with $FutureModifier<List<Category>>, $FutureProvider<List<Category>> {
  /// カテゴリ一覧をFutureとして提供するProvider
  ///
  /// 初回表示時などに使用
  CategoryListFutureProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'categoryListFutureProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoryListFutureHash();

  @$internal
  @override
  $FutureProviderElement<List<Category>> $createElement(
    $ProviderPointer pointer,
  ) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Category>> create(Ref ref) {
    return categoryListFuture(ref);
  }
}

String _$categoryListFutureHash() =>
    r'd0c253df57f7c123fbb6c9972579e9c84985547f';
