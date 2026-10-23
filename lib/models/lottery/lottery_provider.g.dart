// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lottery_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Lottery)
final lotteryProvider = LotteryProvider._();

final class LotteryProvider extends $NotifierProvider<Lottery, LotteryState> {
  LotteryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lotteryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lotteryHash();

  @$internal
  @override
  Lottery create() => Lottery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LotteryState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LotteryState>(value),
    );
  }
}

String _$lotteryHash() => r'9df85f888ac0db7d234c057c8a0edfad19134344';

abstract class _$Lottery extends $Notifier<LotteryState> {
  LotteryState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LotteryState, LotteryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LotteryState, LotteryState>,
              LotteryState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
