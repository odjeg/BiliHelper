import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lottery_level_filter_provider.g.dart';

@riverpod
class LotteryLevelFilter extends _$LotteryLevelFilter {
  @override
  Map<String, bool> build() {
    return {
      'Lv0': true,
      'Lv1': true,
      'Lv2': true,
      'Lv3': true,
      'Lv4': true,
      'Lv5': true,
      'Lv6': true,
    };
  }

  void toggle(String level) {
    state = {...state, level: !state[level]!};
  }

  // 重置为全部选中
  void reset() {
    state = {
      'Lv0': true,
      'Lv1': true,
      'Lv2': true,
      'Lv3': true,
      'Lv4': true,
      'Lv5': true,
      'Lv6': true,
    };
  }
}
