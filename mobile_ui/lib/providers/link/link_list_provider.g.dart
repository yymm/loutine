// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// リンク一覧を取得するProvider（カレンダー用）
///
/// **このProviderは読み取り専用です**
/// リンクの作成・更新・削除は [LinkListPaginated] を使用してください
///
/// 役割:
/// - home_calendarでの更新検知（ref.listenで監視）
/// - 日付範囲での全件取得
///
/// 使い分け:
/// - [LinkList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [LinkListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）

@ProviderFor(LinkList)
final linkListProvider = LinkListProvider._();

/// リンク一覧を取得するProvider（カレンダー用）
///
/// **このProviderは読み取り専用です**
/// リンクの作成・更新・削除は [LinkListPaginated] を使用してください
///
/// 役割:
/// - home_calendarでの更新検知（ref.listenで監視）
/// - 日付範囲での全件取得
///
/// 使い分け:
/// - [LinkList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [LinkListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）
final class LinkListProvider
    extends $AsyncNotifierProvider<LinkList, List<Link>> {
  /// リンク一覧を取得するProvider（カレンダー用）
  ///
  /// **このProviderは読み取り専用です**
  /// リンクの作成・更新・削除は [LinkListPaginated] を使用してください
  ///
  /// 役割:
  /// - home_calendarでの更新検知（ref.listenで監視）
  /// - 日付範囲での全件取得
  ///
  /// 使い分け:
  /// - [LinkList]: home_calendar用、日付範囲で全件取得（読み取り専用）
  /// - [LinkListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）
  LinkListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'linkListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$linkListHash();

  @$internal
  @override
  LinkList create() => LinkList();
}

String _$linkListHash() => r'15c564d0f6f083e8338080f37c6182a9fc5f280b';

/// リンク一覧を取得するProvider（カレンダー用）
///
/// **このProviderは読み取り専用です**
/// リンクの作成・更新・削除は [LinkListPaginated] を使用してください
///
/// 役割:
/// - home_calendarでの更新検知（ref.listenで監視）
/// - 日付範囲での全件取得
///
/// 使い分け:
/// - [LinkList]: home_calendar用、日付範囲で全件取得（読み取り専用）
/// - [LinkListPaginated]: リスト画面用、cursor/limitでページネーション（CRUD操作あり）

abstract class _$LinkList extends $AsyncNotifier<List<Link>> {
  FutureOr<List<Link>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Link>>, List<Link>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Link>>, List<Link>>,
              AsyncValue<List<Link>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
