import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/lottery/reply_item.dart';
import 'package:bilihelper/models/lottery/dynamic_state.dart';

class LotteryState {
  // 加载状态
  final LoadState loadState;
  final String link;
  final Map<String, bool> lvFilter;
  final String keyWorldFilter;
  final bool isMultiLotteryFilter;
  final int count;
  final List<(String name, int count)> prizeItems;
  final DynamicState? dynamicState;
  final List<ReplyState>? luckUserList;

  LotteryState({
    this.loadState = LoadState.none,
    this.link = '',
    this.lvFilter = const {
      'Lv0': true,
      'Lv1': true,
      'Lv2': true,
      'Lv3': true,
      'Lv4': true,
      'Lv5': true,
      'Lv6': true,
    },
    this.keyWorldFilter = '',
    this.isMultiLotteryFilter = false,
    this.count = 1,
    this.prizeItems = const [('一等奖', 1), ('二等奖', 1), ('三等奖', 1)],
    this.dynamicState,
    this.luckUserList,
  });

  LotteryState copyWith({
    LoadState? loadState,
    LoadState? dynamicLoadState,
    LoadState? replyLoadState,
    String? link,
    Map<String, bool>? lvFilter,
    String? keyWorldFilter,
    bool? isMultiLotteryFilter,
    int? count,
    List<(String name, int count)>? prizeItems,
    DynamicState? dynamicState,
    List<ReplyState>? luckUserList,
  }) {
    return LotteryState(
      loadState: loadState ?? this.loadState,
      link: link ?? this.link,
      lvFilter: lvFilter ?? this.lvFilter,
      keyWorldFilter: keyWorldFilter ?? this.keyWorldFilter,
      isMultiLotteryFilter: isMultiLotteryFilter ?? this.isMultiLotteryFilter,
      count: count ?? this.count,
      prizeItems: prizeItems ?? this.prizeItems,
      dynamicState: dynamicState ?? this.dynamicState,
      luckUserList: luckUserList ?? this.luckUserList,
    );
  }
}
