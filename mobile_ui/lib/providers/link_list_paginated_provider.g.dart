// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_list_paginated_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// リンク一覧の無限スクロール用Provider
///
/// **リンクのCRUD操作はこのProviderを使用してください**
///
/// 役割:
/// - リスト画面での表示
/// - リンクの作成・更新・削除
/// - cursor/limitでのページネーション
///
/// 使い分け:
/// - [LinkList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [LinkListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）

@ProviderFor(LinkListPaginated)
final linkListPaginatedProvider = LinkListPaginatedProvider._();

/// リンク一覧の無限スクロール用Provider
///
/// **リンクのCRUD操作はこのProviderを使用してください**
///
/// 役割:
/// - リスト画面での表示
/// - リンクの作成・更新・削除
/// - cursor/limitでのページネーション
///
/// 使い分け:
/// - [LinkList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [LinkListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）
final class LinkListPaginatedProvider
    extends $AsyncNotifierProvider<LinkListPaginated, PaginatedState<Link>> {
  /// リンク一覧の無限スクロール用Provider
  ///
  /// **リンクのCRUD操作はこのProviderを使用してください**
  ///
  /// 役割:
  /// - リスト画面での表示
  /// - リンクの作成・更新・削除
  /// - cursor/limitでのページネーション
  ///
  /// 使い分け:
  /// - [LinkList]: home_calendar用、日付範囲で全件取得（読み取り専用）
  /// - [LinkListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）
  LinkListPaginatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkListPaginatedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkListPaginatedHash();

  @$internal
  @override
  LinkListPaginated create() => LinkListPaginated();
}

String _$linkListPaginatedHash() => r'6117fcf6e6a212e4b2a329d878e94d20df1695f0';

/// リンク一覧の無限スクロール用Provider
///
/// **リンクのCRUD操作はこのProviderを使用してください**
///
/// 役割:
/// - リスト画面での表示
/// - リンクの作成・更新・削除
/// - cursor/limitでのページネーション
///
/// 使い分け:
/// - [LinkList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [LinkListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）

abstract class _$LinkListPaginated
    extends $AsyncNotifier<PaginatedState<Link>> {
  FutureOr<PaginatedState<Link>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PaginatedState<Link>>, PaginatedState<Link>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedState<Link>>,
                PaginatedState<Link>
              >,
              AsyncValue<PaginatedState<Link>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
