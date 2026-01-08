// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_list_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TagListNotifier)
final tagListProvider = TagListNotifierProvider._();

final class TagListNotifierProvider
    extends $NotifierProvider<TagListNotifier, List<Tag>> {
  TagListNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$tagListNotifierHash();

  @$internal
  @override
  TagListNotifier create() => TagListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Tag> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Tag>>(value),
    );
  }
}

String _$tagListNotifierHash() => r'b438f67afc5dc4eb415b40b4206e8e9792dd37df';

abstract class _$TagListNotifier extends $Notifier<List<Tag>> {
  List<Tag> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<Tag>, List<Tag>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<Tag>, List<Tag>>,
              List<Tag>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(tagListFuture)
final tagListFutureProvider = TagListFutureProvider._();

final class TagListFutureProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tag>>,
          List<Tag>,
          FutureOr<List<Tag>>
        >
    with $FutureModifier<List<Tag>>, $FutureProvider<List<Tag>> {
  TagListFutureProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tagListFutureProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tagListFutureHash();

  @$internal
  @override
  $FutureProviderElement<List<Tag>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tag>> create(Ref ref) {
    return tagListFuture(ref);
  }
}

String _$tagListFutureHash() => r'0b5ca9c7e6a4cf0bf4b8522a9cf968df0e740494';
