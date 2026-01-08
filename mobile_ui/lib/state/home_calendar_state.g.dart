// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_calendar_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CalendarStateNotifier)
final calendarStateProvider = CalendarStateNotifierProvider._();

final class CalendarStateNotifierProvider
    extends $NotifierProvider<CalendarStateNotifier, CalendarState> {
  CalendarStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarStateNotifierHash();

  @$internal
  @override
  CalendarStateNotifier create() => CalendarStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarState>(value),
    );
  }
}

String _$calendarStateNotifierHash() =>
    r'da99042fb4c800fde4a2f48eae12ee3daee3e45f';

abstract class _$CalendarStateNotifier extends $Notifier<CalendarState> {
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

@ProviderFor(CalendarFocusDayNotifier)
final calendarFocusDayProvider = CalendarFocusDayNotifierProvider._();

final class CalendarFocusDayNotifierProvider
    extends $NotifierProvider<CalendarFocusDayNotifier, DateTime> {
  CalendarFocusDayNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$calendarFocusDayNotifierHash();

  @$internal
  @override
  CalendarFocusDayNotifier create() => CalendarFocusDayNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$calendarFocusDayNotifierHash() =>
    r'abe73babb90a9be31e88ecabb8a55485b4b9e934';

abstract class _$CalendarFocusDayNotifier extends $Notifier<DateTime> {
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

@ProviderFor(CalendarFormatNotifier)
final calendarFormatProvider = CalendarFormatNotifierProvider._();

final class CalendarFormatNotifierProvider
    extends $NotifierProvider<CalendarFormatNotifier, CalendarFormat> {
  CalendarFormatNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'calendarFormatProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$calendarFormatNotifierHash();

  @$internal
  @override
  CalendarFormatNotifier create() => CalendarFormatNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalendarFormat value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalendarFormat>(value),
    );
  }
}

String _$calendarFormatNotifierHash() =>
    r'ffa08171f83dd811ee2ae2fc9e91bca60bfdae49';

abstract class _$CalendarFormatNotifier extends $Notifier<CalendarFormat> {
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

@ProviderFor(CalendarEventListNotifier)
final calendarEventListProvider = CalendarEventListNotifierProvider._();

final class CalendarEventListNotifierProvider
    extends
        $NotifierProvider<CalendarEventListNotifier, List<CalendarEventItem>> {
  CalendarEventListNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$calendarEventListNotifierHash();

  @$internal
  @override
  CalendarEventListNotifier create() => CalendarEventListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<CalendarEventItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<CalendarEventItem>>(value),
    );
  }
}

String _$calendarEventListNotifierHash() =>
    r'340389fcd7a02f6a3d75d0b2eeea7aa1634d054a';

abstract class _$CalendarEventListNotifier
    extends $Notifier<List<CalendarEventItem>> {
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
