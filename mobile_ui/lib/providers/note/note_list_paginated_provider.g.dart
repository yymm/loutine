// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_list_paginated_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ノート一覧の無限スクロール用Provider
///
/// **ノートのCRUD操作はこのProviderを使用してください**
///
/// 役割:
/// - リスト画面での表示
/// - ノートの作成・更新・削除
/// - cursor/limitでのページネーション
///
/// 使い分け:
/// - [NoteList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [NoteListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）

@ProviderFor(NoteListPaginated)
final noteListPaginatedProvider = NoteListPaginatedProvider._();

/// ノート一覧の無限スクロール用Provider
///
/// **ノートのCRUD操作はこのProviderを使用してください**
///
/// 役割:
/// - リスト画面での表示
/// - ノートの作成・更新・削除
/// - cursor/limitでのページネーション
///
/// 使い分け:
/// - [NoteList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [NoteListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）
final class NoteListPaginatedProvider
    extends $AsyncNotifierProvider<NoteListPaginated, PaginatedState<Note>> {
  /// ノート一覧の無限スクロール用Provider
  ///
  /// **ノートのCRUD操作はこのProviderを使用してください**
  ///
  /// 役割:
  /// - リスト画面での表示
  /// - ノートの作成・更新・削除
  /// - cursor/limitでのページネーション
  ///
  /// 使い分け:
  /// - [NoteList]: home_calendar用、日付範囲で全件取得（読み取り専用）
  /// - [NoteListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）
  NoteListPaginatedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteListPaginatedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteListPaginatedHash();

  @$internal
  @override
  NoteListPaginated create() => NoteListPaginated();
}

String _$noteListPaginatedHash() => r'856885324500d816317ee7733c4d7f3c67af69a0';

/// ノート一覧の無限スクロール用Provider
///
/// **ノートのCRUD操作はこのProviderを使用してください**
///
/// 役割:
/// - リスト画面での表示
/// - ノートの作成・更新・削除
/// - cursor/limitでのページネーション
///
/// 使い分け:
/// - [NoteList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [NoteListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）

abstract class _$NoteListPaginated
    extends $AsyncNotifier<PaginatedState<Note>> {
  FutureOr<PaginatedState<Note>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PaginatedState<Note>>, PaginatedState<Note>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedState<Note>>,
                PaginatedState<Note>
              >,
              AsyncValue<PaginatedState<Note>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
