// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_calendar_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$calendarStateManagerHash() =>
    r'a12b61782a121b9800aaca109ad91a455c8fc635';

/// See also [CalendarStateManager].
@ProviderFor(CalendarStateManager)
final calendarStateManagerProvider =
    AutoDisposeNotifierProvider<CalendarStateManager, CalendarState>.internal(
  CalendarStateManager.new,
  name: r'calendarStateManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarStateManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalendarStateManager = AutoDisposeNotifier<CalendarState>;
String _$calendarFocusDayHash() => r'da5177b7853ae1e8942a604aecfafb154ef31c36';

/// See also [CalendarFocusDay].
@ProviderFor(CalendarFocusDay)
final calendarFocusDayProvider =
    AutoDisposeNotifierProvider<CalendarFocusDay, DateTime>.internal(
  CalendarFocusDay.new,
  name: r'calendarFocusDayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarFocusDayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalendarFocusDay = AutoDisposeNotifier<DateTime>;
String _$calendarFormatManagerHash() =>
    r'656b39ddcbee06b908363957a1842b78a96108be';

/// See also [CalendarFormatManager].
@ProviderFor(CalendarFormatManager)
final calendarFormatManagerProvider =
    AutoDisposeNotifierProvider<CalendarFormatManager, CalendarFormat>.internal(
  CalendarFormatManager.new,
  name: r'calendarFormatManagerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarFormatManagerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalendarFormatManager = AutoDisposeNotifier<CalendarFormat>;
String _$calendarEventListHash() => r'b0be0ce522d3696e117978f942c62845a76242b2';

/// See also [CalendarEventList].
@ProviderFor(CalendarEventList)
final calendarEventListProvider = AutoDisposeNotifierProvider<CalendarEventList,
    List<CalendarEventItem>>.internal(
  CalendarEventList.new,
  name: r'calendarEventListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$calendarEventListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CalendarEventList = AutoDisposeNotifier<List<CalendarEventItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
