// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_detail_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 特定のノートを取得するProvider

@ProviderFor(NoteDetail)
final noteDetailProvider = NoteDetailFamily._();

/// 特定のノートを取得するProvider
final class NoteDetailProvider
    extends $AsyncNotifierProvider<NoteDetail, Note?> {
  /// 特定のノートを取得するProvider
  NoteDetailProvider._({
    required NoteDetailFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'noteDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$noteDetailHash();

  @override
  String toString() {
    return r'noteDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  NoteDetail create() => NoteDetail();

  @override
  bool operator ==(Object other) {
    return other is NoteDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$noteDetailHash() => r'3fa8ed547b02bdf39d5512adf5fa53c6157a6fca';

/// 特定のノートを取得するProvider

final class NoteDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          NoteDetail,
          AsyncValue<Note?>,
          Note?,
          FutureOr<Note?>,
          int
        > {
  NoteDetailFamily._()
    : super(
        retry: null,
        name: r'noteDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 特定のノートを取得するProvider

  NoteDetailProvider call(int noteId) =>
      NoteDetailProvider._(argument: noteId, from: this);

  @override
  String toString() => r'noteDetailProvider';
}

/// 特定のノートを取得するProvider

abstract class _$NoteDetail extends $AsyncNotifier<Note?> {
  late final _$args = ref.$arg as int;
  int get noteId => _$args;

  FutureOr<Note?> build(int noteId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Note?>, Note?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Note?>, Note?>,
              AsyncValue<Note?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
