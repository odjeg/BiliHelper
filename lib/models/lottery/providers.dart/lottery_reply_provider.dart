import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:bilihelper/models/lottery/reply_item.dart';

part 'lottery_reply_provider.g.dart';

// 评论列表独立 Provider（完全独立，不影响任何其他组件）
@Riverpod(keepAlive: true)
class LotteryReply extends _$LotteryReply {
  @override
  List<ReplyState> build() {
    return []; // 初始空列表
  }

  // 单条添加
  void addItem(ReplyState item) {
    state = [...state, item];
  }

  // 清空列表
  void clear() {
    state = [];
  }
}
