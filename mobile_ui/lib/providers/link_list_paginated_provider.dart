import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/link.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/providers/link_list_provider.dart';

part 'link_list_paginated_provider.g.dart';

/// ページネーション状態
class PaginatedState<T> {
  final List<T> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;

  const PaginatedState({
    required this.items,
    this.nextCursor,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  PaginatedState<T> copyWith({
    List<T>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PaginatedState<T>(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

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
@Riverpod(keepAlive: true)
class LinkListPaginated extends _$LinkListPaginated {
  static const int _pageSize = 20;

  @override
  Future<PaginatedState<Link>> build() async {
    final repository = ref.watch(linkRepositoryProvider);

    // 初回ロード
    final result = await repository.fetchLinksPaginated(
      cursor: null,
      limit: _pageSize,
    );

    return PaginatedState(
      items: result.items,
      nextCursor: result.nextCursor,
      hasMore: result.hasMore,
    );
  }

  /// 次のページを読み込む
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMore ||
        currentState.isLoadingMore) {
      return;
    }

    // ローディング状態を設定
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      final repository = ref.read(linkRepositoryProvider);
      final result = await repository.fetchLinksPaginated(
        cursor: currentState.nextCursor,
        limit: _pageSize,
      );

      state = AsyncValue.data(
        PaginatedState(
          items: [...currentState.items, ...result.items],
          nextCursor: result.nextCursor,
          hasMore: result.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      // エラー時は元の状態に戻す（ローディングだけ解除）
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
      rethrow;
    }
  }

  /// リストをリフレッシュ（pull-to-refresh用）
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(linkRepositoryProvider);
      final result = await repository.fetchLinksPaginated(
        cursor: null,
        limit: _pageSize,
      );

      return PaginatedState(
        items: result.items,
        nextCursor: result.nextCursor,
        hasMore: result.hasMore,
      );
    });
  }

  /// リンクを作成
  ///
  /// リスト画面での作成処理を担当
  /// home_calendarの更新も自動的にトリガーされる
  Future<Link> createLink(String url, String title, List<int> tagIds) async {
    final repository = ref.read(linkRepositoryProvider);
    final link = await repository.createLink(url, title, tagIds);

    // 1. このProviderを更新（楽観的更新）
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(items: [link, ...currentState.items]),
      );
    }

    // 2. カレンダー用のLinkListを無効化
    // これによりhome_calendarのref.listenが反応して自動更新される
    ref.invalidate(linkListProvider);

    return link;
  }

  /// リンクを削除
  ///
  /// リスト画面とカレンダー画面での削除処理を担当
  /// home_calendarの更新も自動的にトリガーされる
  Future<Link> deleteLink(int linkId) async {
    final repository = ref.read(linkRepositoryProvider);
    final link = await repository.deleteLink(linkId);

    // 1. このProviderを更新（楽観的更新）
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(
          items: currentState.items.where((link) => link.id != linkId).toList(),
        ),
      );
    }

    // 2. カレンダー用のLinkListを無効化
    // これによりhome_calendarのref.listenが反応して自動更新される
    ref.invalidate(linkListProvider);

    return link;
  }
}
