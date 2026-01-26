// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ThemeModeManager)
final themeModeManagerProvider = ThemeModeManagerProvider._();

final class ThemeModeManagerProvider
    extends $NotifierProvider<ThemeModeManager, ThemeMode> {
  ThemeModeManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'themeModeManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$themeModeManagerHash();

  @$internal
  @override
  ThemeModeManager create() => ThemeModeManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$themeModeManagerHash() => r'3644653f18b9d67833c69f0cae6bbf59fe8dc39b';

abstract class _$ThemeModeManager extends $Notifier<ThemeMode> {
  ThemeMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ThemeMode, ThemeMode>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ThemeMode, ThemeMode>, ThemeMode, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
