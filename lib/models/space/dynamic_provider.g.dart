// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dynamic_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Dynamic)
final dynamicProvider = DynamicProvider._();

final class DynamicProvider extends $NotifierProvider<Dynamic, DynamicState> {
  DynamicProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dynamicProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dynamicHash();

  @$internal
  @override
  Dynamic create() => Dynamic();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DynamicState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DynamicState>(value),
    );
  }
}

String _$dynamicHash() => r'5a1feb6e3581d94f5c92aef53d64b2c3c5a7e1bd';

abstract class _$Dynamic extends $Notifier<DynamicState> {
  DynamicState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DynamicState, DynamicState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DynamicState, DynamicState>,
              DynamicState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
