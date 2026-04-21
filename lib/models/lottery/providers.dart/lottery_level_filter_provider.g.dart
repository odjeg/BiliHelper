// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lottery_level_filter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LotteryLevelFilter)
final lotteryLevelFilterProvider = LotteryLevelFilterProvider._();

final class LotteryLevelFilterProvider
    extends $NotifierProvider<LotteryLevelFilter, Map<String, bool>> {
  LotteryLevelFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lotteryLevelFilterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lotteryLevelFilterHash();

  @$internal
  @override
  LotteryLevelFilter create() => LotteryLevelFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, bool>>(value),
    );
  }
}

String _$lotteryLevelFilterHash() =>
    r'ce7f5aecbef7554b87caaebb7c2dc5b46d7fc317';

abstract class _$LotteryLevelFilter extends $Notifier<Map<String, bool>> {
  Map<String, bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, bool>, Map<String, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, bool>, Map<String, bool>>,
              Map<String, bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
