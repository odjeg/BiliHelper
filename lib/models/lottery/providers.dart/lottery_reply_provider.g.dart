// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lottery_reply_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LotteryReply)
final lotteryReplyProvider = LotteryReplyProvider._();

final class LotteryReplyProvider
    extends $NotifierProvider<LotteryReply, List<ReplyState>> {
  LotteryReplyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lotteryReplyProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lotteryReplyHash();

  @$internal
  @override
  LotteryReply create() => LotteryReply();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ReplyState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ReplyState>>(value),
    );
  }
}

String _$lotteryReplyHash() => r'026bcb9f3c497bb3af8ba05eccfe7d9601ab0727';

abstract class _$LotteryReply extends $Notifier<List<ReplyState>> {
  List<ReplyState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<List<ReplyState>, List<ReplyState>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ReplyState>, List<ReplyState>>,
              List<ReplyState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
