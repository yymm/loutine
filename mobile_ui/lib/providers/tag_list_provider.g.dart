// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// タグ一覧の状態を管理するProvider
///
/// 変更点:
/// - APIクライアントを直接使わず、Repositoryを経由してデータ取得
/// - JSONパース処理はRepositoryに委譲
/// - Providerはデータの状態管理に専念

@ProviderFor(TagList)
final tagListProvider = TagListProvider._();

/// タグ一覧の状態を管理するProvider
///
/// 変更点:
/// - APIクライアントを直接使わず、Repositoryを経由してデータ取得
/// - JSONパース処理はRepositoryに委譲
/// - Providerはデータの状態管理に専念
final class TagListProvider extends $NotifierProvider<TagList, List<Tag>> {
  /// タグ一覧の状態を管理するProvider
  ///
  /// 変更点:
  /// - APIクライアントを直接使わず、Repositoryを経由してデータ取得
  /// - JSONパース処理はRepositoryに委譲
  /// - Providerはデータの状態管理に専念
  TagListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagListProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagListHash();

  @$internal
  @override
  TagList create() => TagList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Tag> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Tag>>(value),
    );
  }
}

String _$tagListHash() => r'5bab37ea692e1905270c28bd88ff9972ec64aae5';

/// タグ一覧の状態を管理するProvider
///
/// 変更点:
/// - APIクライアントを直接使わず、Repositoryを経由してデータ取得
/// - JSONパース処理はRepositoryに委譲
/// - Providerはデータの状態管理に専念

abstract class _$TagList extends $Notifier<List<Tag>> {
  List<Tag> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Tag>, List<Tag>>;
    final element = ref.element as $ClassProviderElement<AnyNotifier<List<Tag>, List<Tag>>, List<Tag>, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// タグ一覧をFutureとして提供するProvider
///
/// 初回表示時などに使用

@ProviderFor(tagListFuture)
final tagListFutureProvider = TagListFutureProvider._();

/// タグ一覧をFutureとして提供するProvider
///
/// 初回表示時などに使用

final class TagListFutureProvider extends $FunctionalProvider<AsyncValue<List<Tag>>, List<Tag>, FutureOr<List<Tag>>> with $FutureModifier<List<Tag>>, $FutureProvider<List<Tag>> {
  /// タグ一覧をFutureとして提供するProvider
  ///
  /// 初回表示時などに使用
  TagListFutureProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'tagListFutureProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$tagListFutureHash();

  @$internal
  @override
  $FutureProviderElement<List<Tag>> $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tag>> create(Ref ref) {
    return tagListFuture(ref);
  }
}

String _$tagListFutureHash() => r'5ac7190cf6e593fe29f31f2c566d2910f34dc9df';
