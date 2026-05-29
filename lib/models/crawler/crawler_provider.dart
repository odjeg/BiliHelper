import 'package:bilihelper/models/crawler/crawler_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'crawler_provider.g.dart';

@Riverpod(keepAlive: true)
class Crawler extends _$Crawler {
  @override
  CrawlerState build() => CrawlerState();

  void updateUrl(String url) {
    state = state.copyWith(url: url);
    _validateUrl(url);
  }

  // 校验 URL 并设置错误信息
  void _validateUrl(String url) {
    if (url.isEmpty) {
      state = state.copyWith(errorText: 'error');
    }
    if (RegExp(r'https://www.bilibili.com/opus/\d+').hasMatch(url) ||
        RegExp(r'https://www.bilibili.com/video/BV\w+').hasMatch(url)) {
      state = state.copyWith(errorText: '');
    } else {
      state = state.copyWith(errorText: 'error');
    }
  }
}
