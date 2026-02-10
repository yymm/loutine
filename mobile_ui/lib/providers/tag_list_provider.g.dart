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
final class TagListProvider extends $AsyncNotifierProvider<TagList, List<Tag>> {
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
}

String _$tagListHash() => r'89cebf0051696a52e03779bc06fd28bd1428f7bf';

/// タグ一覧の状態を管理するProvider
///
/// 変更点:
/// - APIクライアントを直接使わず、Repositoryを経由してデータ取得
/// - JSONパース処理はRepositoryに委譲
/// - Providerはデータの状態管理に専念

abstract class _$TagList extends $AsyncNotifier<List<Tag>> {
  FutureOr<List<Tag>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Tag>>, List<Tag>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Tag>>, List<Tag>>,
              AsyncValue<List<Tag>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
