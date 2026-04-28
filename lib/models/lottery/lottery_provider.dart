import 'dart:developer';
import 'dart:math' hide log;

import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/common/services/bili_x_dio_service.dart';
import 'package:bilihelper/common/utils/wbi_generator.dart';
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

      var response = await BiliXDioService.get(
        '/polymer/web-dynamic/v1/detail',
        queryParameters: {'id': dynamicId},
        cancelToken: cancelToken,
      );
      if (response.statusCode == 200) {
        dynamicState = DynamicState(
          oid: response.data['data']['item']['basic']['rid_str'],
          commentType: response.data['data']['item']['basic']['comment_type'],
          userName:
              response.data['data']['item']['modules']['module_author']['name'],
          userMid:
              response.data['data']['item']['modules']['module_author']['mid'],
          useImage:
              response.data['data']['item']['modules']['module_author']['face'],
          editTime: response
              .data['data']['item']['modules']['module_author']['pub_time'],
          type: 11,
          likeCount: response
              .data['data']['item']['modules']['module_stat']['like']['count'],
          commentCount: response
              .data['data']['item']['modules']['module_stat']['comment']['count'],
          shareCount: response
              .data['data']['item']['modules']['module_stat']['forward']['count'],
        );
      }
    } else if (state.link.contains('video/')) {
      //filterDynamicController.type.value = 1;
      String videoId = RegExp(
        r'BV[a-zA-Z0-9]+',
      ).firstMatch(state.link)!.group(0)!;
      var response = await BiliXDioService.get(
        '/web-interface/view',
        queryParameters: {'bvid': videoId},
        cancelToken: cancelToken,
      );

      if (response.statusCode == 200) {
        dynamicState = DynamicState(
          oid: response.data['data']['stat']['aid'].toString(),
          commentType: 1,
          userName: response.data['data']['owner']['name'],
          userMid: response.data['data']['owner']['mid'],
          useImage: response.data['data']['owner']['face'],
          editTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(
            DateTime.fromMillisecondsSinceEpoch(
              response.data['data']['ctime'] * 1000,
            ),
          ),
          type: 1,
          likeCount: response.data['data']['stat']['like'],
          commentCount: response.data['data']['stat']['reply'],
          shareCount: response.data['data']['stat']['share'],
          viewCount: response.data['data']['stat']['view'],
          danmakuCount: response.data['data']['stat']['danmaku'],
          favoriteCount: response.data['data']['stat']['favorite'],
          coinCount: response.data['data']['stat']['coin'],
        );
      }
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
        var response = await BiliXDioService.get(
          '/v2/reply/wbi/main',
          queryParameters: await WbiGenerator().genWbi(
            params: {
              'oid': dynamicState.oid,
              'type': dynamicState.type,
              'mode': 2,
              'pagination_str': paginationStr,
              'plat': 1,
              'web_location': 1315875,
            },
          ),
          cancelToken: cancelToken,
        );
        isEnd = response.data['data']['cursor']['is_end'];
        paginationStr =
            '{"offset":"${response.data['data']['cursor']['pagination_reply']['next_offset']}"}';
        for (var item in response.data['data']['replies']) {
          replyItems.add(ReplyState.fromJson(item));
          ref
              .read(lotteryReplyProvider.notifier)
              .addItem(ReplyState.fromJson(item));

          rpidSet.add(item['rpid'].toString());
        }
        await Future.delayed(Duration(milliseconds: 1500));

        //log('已加载评论列表: ${replyItems.length} 条, rpid去重后 ${rpidSet.length} 条');
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
