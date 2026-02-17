// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ノート一覧を取得するProvider（カレンダー用）
///
/// **このProviderは読み取り専用です**
/// ノートの作成・更新・削除は [NoteListPaginated] を使用してください
///
/// 役割:
/// - home_calendarでの更新検知（ref.listenで監視）
/// - 日付範囲での全件取得
///
/// 使い分け:
/// - [NoteList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [NoteListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）

@ProviderFor(NoteList)
final noteListProvider = NoteListProvider._();

/// ノート一覧を取得するProvider（カレンダー用）
///
/// **このProviderは読み取り専用です**
/// ノートの作成・更新・削除は [NoteListPaginated] を使用してください
///
/// 役割:
/// - home_calendarでの更新検知（ref.listenで監視）
/// - 日付範囲での全件取得
///
/// 使い分け:
/// - [NoteList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [NoteListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）
final class NoteListProvider
    extends $AsyncNotifierProvider<NoteList, List<Note>> {
  /// ノート一覧を取得するProvider（カレンダー用）
  ///
  /// **このProviderは読み取り専用です**
  /// ノートの作成・更新・削除は [NoteListPaginated] を使用してください
  ///
  /// 役割:
  /// - home_calendarでの更新検知（ref.listenで監視）
  /// - 日付範囲での全件取得
  ///
  /// 使い分け:
  /// - [NoteList]: home_calendar用、日付範囲で全件取得（読み取り専用）
  /// - [NoteListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）
  NoteListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteListHash();

  @$internal
  @override
  NoteList create() => NoteList();
}

String _$noteListHash() => r'cbf0c1998539a8e73362aff9581d00cf28977ca3';

/// ノート一覧を取得するProvider（カレンダー用）
///
/// **このProviderは読み取り専用です**
/// ノートの作成・更新・削除は [NoteListPaginated] を使用してください
///
/// 役割:
/// - home_calendarでの更新検知（ref.listenで監視）
/// - 日付範囲での全件取得
///
/// 使い分け:
/// - [NoteList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [NoteListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）

abstract class _$NoteList extends $AsyncNotifier<List<Note>> {
  FutureOr<List<Note>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Note>>, List<Note>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Note>>, List<Note>>,
              AsyncValue<List<Note>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
