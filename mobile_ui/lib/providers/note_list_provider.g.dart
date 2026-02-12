// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ノート一覧を取得するProvider

@ProviderFor(NoteList)
final noteListProvider = NoteListProvider._();

/// ノート一覧を取得するProvider
final class NoteListProvider
    extends $AsyncNotifierProvider<NoteList, List<Note>> {
  /// ノート一覧を取得するProvider
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

String _$noteListHash() => r'5ce4322116eedb140b914014f130df5b64402163';

/// ノート一覧を取得するProvider

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
