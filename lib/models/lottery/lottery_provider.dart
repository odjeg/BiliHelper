import 'dart:developer';
import 'dart:math' hide log;

import 'package:bilihelper/api/dynamic_api.dart';
import 'package:bilihelper/api/reply_api.dart';
import 'package:bilihelper/api/video_api.dart';
import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/lottery/dynamic_state.dart';
import 'package:bilihelper/models/lottery/lottery_state.dart';
import 'package:bilihelper/models/lottery/providers.dart/lottery_reply_provider.dart';
import 'package:bilihelper/models/lottery/reply_item.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lottery_provider.g.dart';

@Riverpod(keepAlive: true)
class Lottery extends _$Lottery {
  @override
  LotteryState build() {
    _cancelToken = CancelToken();
    ref.onDispose(() {
      _cancelToken?.cancel();
      animationController = null;
      log('LotteryProvider已被销毁，取消请求');
    });
    // 初始状态
    return LotteryState(
      loadState: LoadState.none,
      link: '',
      lvFilter: const {
        'Lv0': true,
        'Lv1': true,
        'Lv2': true,
        'Lv3': true,
        'Lv4': true,
        'Lv5': true,
        'Lv6': true,
      },
      keyWorldFilter: '',
      isMultiLotteryFilter: false,
      count: 1,
      dynamicState: null,
      luckUserList: [],
    );
  }

  CancelToken? _cancelToken;
  AnimationController? animationController;
  Animation<double>? gradientAnimation;

  void initAnimation(TickerProvider vsync, Duration duration) {
    if (animationController == null) {
      animationController =
          AnimationController(vsync: vsync, duration: duration)
            ..repeat()
            ..stop(); // 默认不播放动画，等抽奖开始时再播放

      // 生成0~1的动画值，驱动渐变平移
      gradientAnimation = Tween<double>(begin: 300, end: 1200.0).animate(
        CurvedAnimation(
          parent: animationController!,
          curve: Curves.linear, // 匀速滚动，无加速减速
        ),
      );
    }
  }

  void updateLoadState(LoadState loadState) {
    state = state.copyWith(loadState: loadState);
    log('updateLoadState: ${state.loadState}');
  }

  void updateLink(String link) {
    state = state.copyWith(link: link);
    log('updateLink: ${state.link}');
  }

  void updateLvFilter(String level) {
    state = state.copyWith(
      lvFilter: {...state.lvFilter, level: !state.lvFilter[level]!},
    );
    log('updateLvFilter: ${state.lvFilter}');
  }

  void resetLvFilter() {
    state = state.copyWith(
      lvFilter: {
        'Lv0': true,
        'Lv1': true,
        'Lv2': true,
        'Lv3': true,
        'Lv4': true,
        'Lv5': true,
        'Lv6': true,
      },
    );
    log('resetLvFilter: ${state.lvFilter}');
  }

  void updateKeyWorldFilter(String keyWorldFilter) {
    state = state.copyWith(keyWorldFilter: keyWorldFilter);
    log('updateKeyWorldFilter: ${state.keyWorldFilter}');
  }

  void updateIsMultiLotteryFilter(bool isMultiLotteryFilter) {
    state = state.copyWith(isMultiLotteryFilter: isMultiLotteryFilter);
  } // 添加

  void updateCount(int count) {
    state = state.copyWith(count: count);
    log('updateCount: ${state.count}');
  }

  void addPrizeItem((String name, int count) prizeItem) {
    state = state.copyWith(prizeItems: [...state.prizeItems, prizeItem]);
  }

  void removePrizeItem(int index) {
    state = state.copyWith(prizeItems: [...state.prizeItems]..removeAt(index));
  }

  // 单独更新奖项名称
  void updatePrizeName(int index, String name) {
    if (index < 0 || index >= state.prizeItems.length) return;
    final newList = [...state.prizeItems];
    final (_, count) = newList[index];
    newList[index] = (name, count);
    state = state.copyWith(prizeItems: newList);
    log('updatePrizeName:$index ${state.prizeItems[index]}');
  }

  // 单独更新奖项数量
  void updatePrizeCount(int index, int count) {
    if (index < 0 || index >= state.prizeItems.length) return;
    final newList = [...state.prizeItems];
    final (name, _) = newList[index];
    newList[index] = (name, count);
    state = state.copyWith(prizeItems: newList);
    log('updatePrizeCount:$index ${state.prizeItems[index]}');
  }

  void clearluckUserList() {
    state = state.copyWith(luckUserList: []);
  }

  Future<void> startDarwLottery() async {
    final cancelToken = _cancelToken!;
    state = state.copyWith(
      loadState: LoadState.loading,
      dynamicState: null,
      luckUserList: [],
    );
    ref.read(lotteryReplyProvider.notifier).clear(); // 同步清空评论列表
    var dynamicState = await _initDynamicDetail(cancelToken);
    if (dynamicState == null) return;
    var replyItems = await _initReplyList(dynamicState, cancelToken);
    if (replyItems.isEmpty) return;
    await _initLuckUserList(replyItems, cancelToken);
    state = state.copyWith(loadState: LoadState.none);
  }

  Future<DynamicState?> _initDynamicDetail(CancelToken cancelToken) async {
    if (cancelToken.isCancelled) return null;

    state = state.copyWith(dynamicState: null, luckUserList: null);
    late DynamicState dynamicState;
    if (state.link.contains('opus/')) {
      String dynamicId = RegExp(
        r'opus\/(\d+)',
      ).firstMatch(state.link)!.group(1)!;

      var responseData = await DynamicApi.getDynamicDetail(
        queryParameters: {'id': dynamicId},
        cancelToken: cancelToken,
      );
      if (responseData.statusCode == 200) {
        dynamicState = DynamicState(
          oid: responseData.data['item']['basic']['rid_str'],
          commentType: responseData.data['item']['basic']['comment_type'],
          userName:
              responseData.data['item']['modules']['module_author']['name'],
          userMid: responseData.data['item']['modules']['module_author']['mid'],
          useImage:
              responseData.data['item']['modules']['module_author']['face'],
          editTime:
              responseData.data['item']['modules']['module_author']['pub_time'],
          type: 11,
          likeCount: responseData
              .data['item']['modules']['module_stat']['like']['count'],
          commentCount: responseData
              .data['item']['modules']['module_stat']['comment']['count'],
          shareCount: responseData
              .data['item']['modules']['module_stat']['forward']['count'],
        );
      }
    } else if (state.link.contains('video/')) {
      String bvid = RegExp(r'BV[a-zA-Z0-9]+').firstMatch(state.link)!.group(0)!;
      var responseData = await VideoApi.getVideoDetail(
        bvid: bvid,
        cancelToken: cancelToken,
      );

      dynamicState = DynamicState(
        oid: responseData.data['stat']['aid'].toString(),
        commentType: 1,
        userName: responseData.data['owner']['name'],
        userMid: responseData.data['owner']['mid'],
        useImage: responseData.data['owner']['face'],
        editTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(
          DateTime.fromMillisecondsSinceEpoch(
            responseData.data['ctime'] * 1000,
          ),
        ),
        type: 1,
        likeCount: responseData.data['stat']['like'],
        commentCount: responseData.data['stat']['reply'],
        shareCount: responseData.data['stat']['share'],
        viewCount: responseData.data['stat']['view'],
        danmakuCount: responseData.data['stat']['danmaku'],
        favoriteCount: responseData.data['stat']['favorite'],
        coinCount: responseData.data['stat']['coin'],
      );
    }
    state = state.copyWith(dynamicState: dynamicState);
    return dynamicState;
  }

  // 初始化抽奖链接评论列表
  Future<List<ReplyState>> _initReplyList(
    DynamicState dynamicState,
    CancelToken cancelToken,
  ) async {
    if (cancelToken.isCancelled) return [];

    List<ReplyState> replyItems = [];
    bool isEnd = false;
    String paginationStr = '{"offset":""}';

    Set<String> rpidSet = {};

    try {
      do {
        if (state.loadState == LoadState.none) return [];
        log('正在加载评论列表...');
        var responseData = await ReplyApi.getReplyList(
          oid: dynamicState.oid,
          type: dynamicState.type,
          mode: 2,
          paginationStr: paginationStr,
          cancelToken: cancelToken,
        );
        isEnd = responseData.data['cursor']['is_end'];
        paginationStr =
            '{"offset":"${responseData.data['cursor']['pagination_reply']['next_offset']}"}';
        for (var item in responseData.data['replies']) {
          replyItems.add(ReplyState.fromJson(item));
          ref
              .read(lotteryReplyProvider.notifier)
              .addItem(ReplyState.fromJson(item));

          rpidSet.add(item['rpid'].toString());
        }
        await Future.delayed(Duration(milliseconds: 1500));
      } while (!isEnd);
    } catch (e) {
      log('初始化抽奖链接评论列表失败');
      return [];
    }
    log('初始化抽奖链接评论列表完成');
    return replyItems;
  }

  // 初始化抽奖链接评论列表
  Future<void> _initLuckUserList(
    List<ReplyState> replyItems,
    CancelToken cancelToken,
  ) async {
    if (cancelToken.isCancelled) return;
    if (replyItems.isEmpty) {
      return;
    }
    log('初始化抽奖链接中奖用户列表');
    List<ReplyState> filterUserReplyItems = [];
    state.lvFilter.forEach((key, value) {
      log('$key $value');
    });
    log(state.keyWorldFilter);
    log(state.count.toString());
    log(state.isMultiLotteryFilter.toString());
    if (state.isMultiLotteryFilter) {
      for (var prizeItem in state.prizeItems) {
        log('奖项: ${prizeItem.$1} 数量: ${prizeItem.$2}');
      }
    }
    int count = 0;
    //获取抽取人数
    if (state.isMultiLotteryFilter) {
      for (var prizeItem in state.prizeItems) {
        count += prizeItem.$2;
      }
    } else {
      count = state.count;
    }

    //先筛选用户Lv等级和关键词
    for (var item in replyItems) {
      bool lvMatch = state.lvFilter['Lv${item.currentLevel}']!;
      bool keyWorldMatch = item.message.contains(state.keyWorldFilter);
      if (lvMatch && keyWorldMatch) {
        filterUserReplyItems.add(item);
      }
    }

    //用户去重
    var uniqueMap = <int, ReplyState>{};
    for (var item in filterUserReplyItems) {
      uniqueMap[item.mid] = item;
    }

    state = state.copyWith(
      loadState: LoadState.none,
      luckUserList: sample(uniqueMap.values.toList(), count),
    );
  }

  List<T> sample<T>(List<T> list, int count) {
    if (list.length <= count) return List.from(list);
    final random = Random();
    List<T> copy = List.from(list);
    List<T> result = [];

    for (int i = 0; i < count; i++) {
      int index = random.nextInt(copy.length);
      result.add(copy.removeAt(index));
    }
    return result;
  }
}
