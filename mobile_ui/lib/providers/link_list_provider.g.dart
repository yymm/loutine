// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// リンク一覧を取得するProvider

@ProviderFor(LinkList)
final linkListProvider = LinkListProvider._();

/// リンク一覧を取得するProvider
final class LinkListProvider
    extends $AsyncNotifierProvider<LinkList, List<Link>> {
  /// リンク一覧を取得するProvider
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

String _$linkListHash() => r'a5ed220222f33419d21b7823423af722fe73e313';

/// リンク一覧を取得するProvider

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
