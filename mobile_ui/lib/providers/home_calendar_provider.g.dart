// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarStateManager)
final calendarStateManagerProvider = CalendarStateManagerProvider._();

final class CalendarStateManagerProvider
    extends $NotifierProvider<CalendarStateManager, CalendarState> {
  CalendarStateManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarStateManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarStateManagerHash();

  @$internal
  @override
  CalendarStateManager create() => CalendarStateManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarState>(value),
    );
  }
}

String _$calendarStateManagerHash() =>
    r'8129263d01feb27ff5c0d8202f743fff489f3c2b';

abstract class _$CalendarStateManager extends $Notifier<CalendarState> {
  CalendarState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CalendarState, CalendarState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalendarState, CalendarState>,
              CalendarState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CalendarFocusDay)
final calendarFocusDayProvider = CalendarFocusDayProvider._();

final class CalendarFocusDayProvider
    extends $NotifierProvider<CalendarFocusDay, DateTime> {
  CalendarFocusDayProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarFocusDayProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarFocusDayHash();

  @$internal
  @override
  CalendarFocusDay create() => CalendarFocusDay();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$calendarFocusDayHash() => r'da5177b7853ae1e8942a604aecfafb154ef31c36';

abstract class _$CalendarFocusDay extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CalendarFormatManager)
final calendarFormatManagerProvider = CalendarFormatManagerProvider._();

final class CalendarFormatManagerProvider
    extends $NotifierProvider<CalendarFormatManager, CalendarFormat> {
  CalendarFormatManagerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarFormatManagerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarFormatManagerHash();

  @$internal
  @override
  CalendarFormatManager create() => CalendarFormatManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarFormat value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarFormat>(value),
    );
  }
}

String _$calendarFormatManagerHash() =>
    r'656b39ddcbee06b908363957a1842b78a96108be';

abstract class _$CalendarFormatManager extends $Notifier<CalendarFormat> {
  CalendarFormat build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CalendarFormat, CalendarFormat>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalendarFormat, CalendarFormat>,
              CalendarFormat,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CalendarEventList)
final calendarEventListProvider = CalendarEventListProvider._();

final class CalendarEventListProvider
    extends $NotifierProvider<CalendarEventList, List<CalendarEventItem>> {
  CalendarEventListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarEventListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarEventListHash();

  @$internal
  @override
  CalendarEventList create() => CalendarEventList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CalendarEventItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CalendarEventItem>>(value),
    );
  }
}

String _$calendarEventListHash() => r'b0be0ce522d3696e117978f942c62845a76242b2';

abstract class _$CalendarEventList extends $Notifier<List<CalendarEventItem>> {
  List<CalendarEventItem> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<List<CalendarEventItem>, List<CalendarEventItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<CalendarEventItem>, List<CalendarEventItem>>,
              List<CalendarEventItem>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
