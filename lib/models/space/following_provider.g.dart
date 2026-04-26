// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'following_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Following)
final followingProvider = FollowingProvider._();

final class FollowingProvider
    extends $NotifierProvider<Following, FollowingState> {
  FollowingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'followingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$followingHash();

  @$internal
  @override
  Following create() => Following();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FollowingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FollowingState>(value),
    );
  }
}

String _$followingHash() => r'4682a3f3e9e6daaa61a1cfd34ebe232a59426ba4';

abstract class _$Following extends $Notifier<FollowingState> {
  FollowingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FollowingState, FollowingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FollowingState, FollowingState>,
              FollowingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
