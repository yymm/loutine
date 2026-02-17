import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile_ui/models/note.dart';
import 'package:mobile_ui/providers/repository_provider.dart';
import 'package:mobile_ui/providers/note/note_list_provider.dart';

part 'note_list_paginated_provider.g.dart';

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
@Riverpod(keepAlive: true)
class NoteListPaginated extends _$NoteListPaginated {
  static const int _pageSize = 20;

  @override
  Future<PaginatedState<Note>> build() async {
    final repository = ref.watch(noteRepositoryProvider);

    // 初回ロード
    final result = await repository.fetchNotesPaginated(
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
      final repository = ref.read(noteRepositoryProvider);
      final result = await repository.fetchNotesPaginated(
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
      final repository = ref.read(noteRepositoryProvider);
      final result = await repository.fetchNotesPaginated(
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

  /// ノートを作成
  ///
  /// リスト画面での作成処理を担当
  /// home_calendarの更新も自動的にトリガーされる
  Future<Note> createNote({
    required String title,
    required String text,
    List<int> tagIds = const [],
  }) async {
    final repository = ref.read(noteRepositoryProvider);
    final note = await repository.createNote(
      title: title,
      text: text,
      tagIds: tagIds,
    );

    // 1. このProviderを更新（楽観的更新）
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(items: [note, ...currentState.items]),
      );
    }

    // 2. カレンダー用のNoteListを無効化
    // これによりhome_calendarのref.listenが反応して自動更新される
    ref.invalidate(noteListProvider);

    return note;
  }

  /// ノートを削除
  Future<Note> deleteNote(int noteId) async {
    final repository = ref.read(noteRepositoryProvider);
    final note = await repository.deleteNote(noteId);

    // リストから削除（楽観的更新）
    final currentState = state.value;
    if (currentState != null) {
      state = AsyncValue.data(
        currentState.copyWith(
          items: currentState.items.where((note) => note.id != noteId).toList(),
        ),
      );
    }

    // カレンダー用のNoteListを無効化
    ref.invalidate(noteListProvider);

    return note;
  }

  /// ノートを更新
  Future<Note> updateNote({
    required Note note,
    List<int> tagIds = const [],
  }) async {
    final repository = ref.read(noteRepositoryProvider);
    final updatedNote = await repository.updateNote(note: note, tagIds: tagIds);

    // リストを更新（楽観的更新）
    final currentState = state.value;
    if (currentState != null) {
      final updatedItems = currentState.items.map((n) {
        return n.id == updatedNote.id ? updatedNote : n;
      }).toList();
      state = AsyncValue.data(currentState.copyWith(items: updatedItems));
    }

    // カレンダー用のNoteListを無効化
    ref.invalidate(noteListProvider);

    return updatedNote;
  }
}
