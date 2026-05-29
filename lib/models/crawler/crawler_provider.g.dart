// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'crawler_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Crawler)
final crawlerProvider = CrawlerProvider._();

final class CrawlerProvider extends $NotifierProvider<Crawler, CrawlerState> {
  CrawlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crawlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crawlerHash();

  @$internal
  @override
  Crawler create() => Crawler();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrawlerState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrawlerState>(value),
    );
  }
}

String _$crawlerHash() => r'6654a1893d02d7f57587112c30fc7a1bf7963bd4';

abstract class _$Crawler extends $Notifier<CrawlerState> {
  CrawlerState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CrawlerState, CrawlerState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CrawlerState, CrawlerState>,
              CrawlerState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
