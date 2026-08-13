import 'package:bilihelper/models/crawler/crawler_state.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'crawler_provider.g.dart';

@Riverpod(keepAlive: true)
class Crawler extends _$Crawler {
  @override
  CrawlerState build() => CrawlerState();

  void updateUrl(String url) {
    debugPrint('updateUrl: $url');
    state = state.copyWith(url: url);
    _validateUrl(url);
  }

  // 校验 URL 并设置错误信息
  void _validateUrl(String url) {
    debugPrint('validateUrl: $url');
    if (url.isEmpty ||
        RegExp(r'https://www.bilibili.com/opus/\d+').hasMatch(url) ||
        RegExp(r'https://www.bilibili.com/video/BV\w+').hasMatch(url)) {
      state = state.copyWith(clearErrorText: true);
    } else {
      state = state.copyWith(errorText: 'error');
    }
  }
}
