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

String _$lotteryHash() => r'639c238f5dcb0660374dd95b45710bd0b4c6ca4d';

abstract class _$Lottery extends $Notifier<LotteryState> {
  LotteryState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<LotteryState, LotteryState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LotteryState, LotteryState>,
              LotteryState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
