// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// カレンダーに表示する月のイベント一覧を管理するProvider
///
/// buildパターンを使うことで:
/// - 同じ月のデータは自動的にキャッシュされる
/// - Link/Purchase/Noteの追加・更新時に自動的に再取得される

@ProviderFor(CalendarEventData)
final calendarEventDataProvider = CalendarEventDataFamily._();

/// カレンダーに表示する月のイベント一覧を管理するProvider
///
/// buildパターンを使うことで:
/// - 同じ月のデータは自動的にキャッシュされる
/// - Link/Purchase/Noteの追加・更新時に自動的に再取得される
final class CalendarEventDataProvider
    extends
        $AsyncNotifierProvider<
          CalendarEventData,
          Map<DateTime, List<CalendarEventItem>>
        > {
  /// カレンダーに表示する月のイベント一覧を管理するProvider
  ///
  /// buildパターンを使うことで:
  /// - 同じ月のデータは自動的にキャッシュされる
  /// - Link/Purchase/Noteの追加・更新時に自動的に再取得される
  CalendarEventDataProvider._({
    required CalendarEventDataFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'calendarEventDataProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$calendarEventDataHash();

  @override
  String toString() {
    return r'calendarEventDataProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CalendarEventData create() => CalendarEventData();

  @override
  bool operator ==(Object other) {
    return other is CalendarEventDataProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$calendarEventDataHash() => r'f2e99775312dd257322eee3fdcc636790a225076';

/// カレンダーに表示する月のイベント一覧を管理するProvider
///
/// buildパターンを使うことで:
/// - 同じ月のデータは自動的にキャッシュされる
/// - Link/Purchase/Noteの追加・更新時に自動的に再取得される

final class CalendarEventDataFamily extends $Family
    with
        $ClassFamilyOverride<
          CalendarEventData,
          AsyncValue<Map<DateTime, List<CalendarEventItem>>>,
          Map<DateTime, List<CalendarEventItem>>,
          FutureOr<Map<DateTime, List<CalendarEventItem>>>,
          DateTime
        > {
  CalendarEventDataFamily._()
    : super(
        retry: null,
        name: r'calendarEventDataProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// カレンダーに表示する月のイベント一覧を管理するProvider
  ///
  /// buildパターンを使うことで:
  /// - 同じ月のデータは自動的にキャッシュされる
  /// - Link/Purchase/Noteの追加・更新時に自動的に再取得される

  CalendarEventDataProvider call(DateTime focusedMonth) =>
      CalendarEventDataProvider._(argument: focusedMonth, from: this);

  @override
  String toString() => r'calendarEventDataProvider';
}

/// カレンダーに表示する月のイベント一覧を管理するProvider
///
/// buildパターンを使うことで:
/// - 同じ月のデータは自動的にキャッシュされる
/// - Link/Purchase/Noteの追加・更新時に自動的に再取得される

abstract class _$CalendarEventData
    extends $AsyncNotifier<Map<DateTime, List<CalendarEventItem>>> {
  late final _$args = ref.$arg as DateTime;
  DateTime get focusedMonth => _$args;

  FutureOr<Map<DateTime, List<CalendarEventItem>>> build(DateTime focusedMonth);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<DateTime, List<CalendarEventItem>>>,
              Map<DateTime, List<CalendarEventItem>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<DateTime, List<CalendarEventItem>>>,
                Map<DateTime, List<CalendarEventItem>>
              >,
              AsyncValue<Map<DateTime, List<CalendarEventItem>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
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
