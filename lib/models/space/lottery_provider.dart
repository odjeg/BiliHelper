// ignore_for_file: non_constant_identifier_names

import 'dart:developer';
import 'dart:math' as math;
import 'package:bilihelper/api/dynamic_api.dart';
import 'package:bilihelper/api/lottery_api.dart';
import 'package:bilihelper/api/user_modify_api.dart';
import 'package:bilihelper/api/user_reply_add_api.dart';
import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:bilihelper/models/user/lottery_model/lottery_data_source.dart';
import 'package:bilihelper/models/user/lottery_model/lottery_item.dart';
import 'package:bilihelper/models/user/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:collection/collection.dart';

part 'lottery_provider.g.dart';

@Riverpod(keepAlive: true)
class Lottery extends _$Lottery {
  @override
  LotteryState build() {
    _cancelToken = CancelToken();
    ref.onDispose(() {
      _cancelToken?.cancel();
    });
    return LotteryState();
  }

  final LotteryDataSource lotteryDataSource = LotteryDataSource();
  CancelToken? _cancelToken;
  static const List<String> commentList = [
    "希望好运眷顾我✨",
    "浅浅蹲一波中奖(๑•̀ㅂ•́)و✧",
    "吸吸欧气，希望能中！",
    "许愿成为幸运儿～",
    "球球了，让我中一次吧(´･ω･`)",
    "来凑个热闹，碰碰运气",
    "欧气快到我怀里来(≧∇≦)ﾉ",
    "期待被幸运砸中",
    "默默参与，坐等开奖",
    "希望这次不再陪跑😭",
    "沾沾喜气，万事顺意",
    "许愿中奖，冲冲冲！",
    "希望好运降临呀🌟",
    "来吸一口大佬欧气",
    "诚心许愿，求抽中～",
    "能不能中就看这次了(｡•́ω•̀｡)",
    "期待幸运之神眷顾",
    "浅浅参与一下下",
    "希望幸运值拉满✨",
    "蹲一个中奖名额",
    "摆脱非酋，从我做起(｀・ω・´)",
    "希望好运与我撞个满怀",
    "许愿许愿，心想事成～",
    "来试试手气如何",
    "希望能被翻牌(๑˃̵ᴗ˂̵)و",
    "坐等开奖，期待一下",
    "欧气附体，冲冲冲！",
    "希望这次能有我",
    "默默蹲一个惊喜(◍•ᴗ•◍)",
    "求中奖，球球了～",
    "好运快来找我吧🌟",
    "参与一下，随缘就好",
    "希望能中，孩子想中奖",
    "吸欧气，不做分母(´▽｀)",
    "期待一下惊喜降临",
    "许愿中奖，万事顺遂",
    "来凑个欧气氛围～",
    "希望幸运女神看我一眼",
    "浅浅期待一下中奖(｡•̀ᴗ-)✧",
    "碰碰运气，万一呢",
    "希望这次能上岸",
    "欧气满满，冲鸭！",
    "诚心蹲一个中奖机会",
    "希望好运常伴左右✨",
    "别让我陪跑啦球球",
    "来沾沾好运，求抽中",
    "期待成为那个幸运儿",
    "许愿成功，得偿所愿(≧∀≦)",
    "希望惊喜可以砸中我",
    "参与一下，静候佳音～",
  ];

  void updateLoadStatus(LoadState loadState, {int? count}) {
    state = state.copyWith(loadState: loadState, count: count);
  }

  Future<void> _getClipboardText() async {
    UserModel().lotteryItems.clear();
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    //developer.log(data?.text ?? '');
    final RegExp opusIdRegex = RegExp(
      r'(\d{18,19})', // 核心正则
      multiLine: true, // 支持多行匹配（必须，因为HTML是多行文本）
    );
    var opusIdSet = <String>{};
    for (final Match match in opusIdRegex.allMatches(data?.text ?? '')) {
      final String opusId = match.group(1) ?? '';
      opusIdSet.add(opusId);
    }
    UserModel().lotteryItems = opusIdSet
        .map((e) => LotteryItem(businessId: e))
        .toList();
    lotteryDataSource.notifyListeners();
  }

  Future<void> _getLotteryInfo(CancelToken cancelToken) async {
    if (cancelToken.isCancelled) return;

    updateLoadStatus(LoadState.loading);
    String? csrf = await SecureStorageService.getToken('bili_jct');

    for (var item in UserModel().lotteryItems) {
      Response<dynamic> dynamicDetailResponseData;
      try {
        dynamicDetailResponseData = await DynamicApi.getDynamicDetail2(
          queryParameters: {'id': item.businessId},
          cancelToken: cancelToken,
        );
      } on DioException catch (e) {
        if (e.type == DioExceptionType.cancel) {
          log('抽奖信息请求已取消: $e', error: e);
          return;
        }
        rethrow; // 其他 Dio 错误继续抛出，交由外层 catch 处理
      }

      if (cancelToken.isCancelled) break;
      if (dynamicDetailResponseData.data['item'] == null) break;

      item.businessId = dynamicDetailResponseData.data['item']['id_str'];
      item.commentIdStr =
          dynamicDetailResponseData.data['item']['basic']['comment_id_str'];
      var moduleTypeAuthor =
          (dynamicDetailResponseData.data['item']['modules'] as List<dynamic>)
              .firstWhereOrNull(
                (element) => element['module_type'] == 'MODULE_TYPE_AUTHOR',
              );
      item.name = moduleTypeAuthor['module_author']['name'];
      item.mid = moduleTypeAuthor['module_author']['mid'];
      item.followed = UserModel().followingItems.any(
        (item) => item.mid == moduleTypeAuthor['module_author']['mid'] as int,
      );

      //用来寻找动态当中是否有互动抽奖关键文本
      var moduleTypeContent =
          (dynamicDetailResponseData.data['item']['modules'] as List<dynamic>)
              .firstWhereOrNull(
                (element) => element['module_type'] == 'MODULE_TYPE_CONTENT',
              );
      //判断是否有互动抽奖关键文本
      bool RICH_TEXT_NODE_TYPE_LOTTERY =
          (moduleTypeContent['module_content']['paragraphs'] as List<dynamic>)
              .any(
                (element) =>
                    ((element?['text']?['nodes'] as List<dynamic>?) ?? []).any(
                      (node) =>
                          node['type'] == 'TEXT_NODE_TYPE_RICH' &&
                          node['rich']['type'] == 'RICH_TEXT_NODE_TYPE_LOTTERY',
                    ),
              );

      //判断是否有预约抽奖关键文本
      var LINK_CARD_TYPE_RESERVE =
          (moduleTypeContent['module_content']['paragraphs'] as List<dynamic>)
              .firstWhereOrNull(
                (element) =>
                    element['link_card']?['card']?['type'] ==
                    'LINK_CARD_TYPE_RESERVE',
              );
      debugPrint('RICH_TEXT_NODE_TYPE_LOTTERY: $RICH_TEXT_NODE_TYPE_LOTTERY');
      //处理互动抽奖
      if (RICH_TEXT_NODE_TYPE_LOTTERY) {
        item.lotteryType = '互动抽奖';
        item.isForward =
            UserModel().dynamicItems.any(
              (element) => element.origIdStr == item.businessId,
            )
            ? '已转发'
            : '未转发';

        Response<dynamic> lotteryDetailResponseData;
        try {
          lotteryDetailResponseData = await LotteryApi.getLotteryDetail(
            queryParameters: {
              'business_id': item.businessId,
              'business_type': 1,
              'csrf': csrf,
              'web_location': '333.1330',
              'x-bili-device-req-json': {
                'platform': "web",
                'device': "pc",
                'spmid': "333.1330",
              },
            },
            cancelToken: cancelToken,
          );
          item.lotteryTime = lotteryDetailResponseData.data['lottery_time'];
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) {
            log('抽奖详情请求已取消: $e', error: e);
            return;
          }
        }
      } else if (LINK_CARD_TYPE_RESERVE != null) {
        item.rid =
            LINK_CARD_TYPE_RESERVE['link_card']['card']['reserve']['rid'];
        Response<dynamic> lotteryDetailResponseData;
        try {
          lotteryDetailResponseData = await LotteryApi.getLotteryDetail(
            queryParameters: {
              'business_id':
                  LINK_CARD_TYPE_RESERVE['link_card']['card']['reserve']['rid'],
              'business_type': 10,
              'csrf': csrf,
              'web_location': '333.1330',
              'x-bili-device-req-json': {
                'platform': "web",
                'device': "pc",
                'spmid': "333.1330",
              },
            },
            cancelToken: cancelToken,
          );
          item.lotteryTime = lotteryDetailResponseData.data['lottery_time'];

          int type =
              LINK_CARD_TYPE_RESERVE['link_card']['card']['reserve']['button']['type'];
          int status =
              LINK_CARD_TYPE_RESERVE['link_card']['card']['reserve']['button']['status'];
          if (type == 1) {
            item.lotteryType = '视频预约';
          } else if (type == 2) {
            item.lotteryType = '直播预约';
          }
          if (status == 1) {
            item.isForward = '未预约';
          } else if (status == 2) {
            item.isForward = '已预约';
          }
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) {
            log('抽奖详情请求已取消: $e', error: e);
            return;
          }
        }
      } else {
        item.lotteryType = '转发抽奖';
        item.isForward =
            UserModel().dynamicItems.any(
              (element) => element.origIdStr == item.businessId,
            )
            ? '已转发'
            : '未转发';
      }
      lotteryDataSource.notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> startLottery() async {
    final CancelToken cancelToken = _cancelToken!;
    if (cancelToken.isCancelled) return;

    log('开始抽奖...');
    UserModel().lotteryItems.clear();
    updateLoadStatus(LoadState.loading, count: 0);

    await _getClipboardText();
    await _getLotteryInfo(cancelToken);

    for (var item in UserModel().lotteryItems) {
      if (cancelToken.isCancelled) break;

      updateLoadStatus(LoadState.loading, count: state.count + 1);
      bool flag = false;
      if (item.lotteryType == '互动抽奖') {
        if (DateTime.fromMillisecondsSinceEpoch(
              item.lotteryTime! * 1000,
            ).compareTo(DateTime.now()) <
            0) {
          item.isForward = '已截止';
          lotteryDataSource.notifyListeners();
          continue;
        }
        if (item.followed == false) {
          flag = true;
          try {
            await UserModifyApi.userModify(
              fid: item.mid!,
              act: 1,
              cancelToken: cancelToken,
            );
            item.followed = true;
          } on DioException catch (e) {
            if (e.type == DioExceptionType.cancel) {
              log('关注请求已取消: $e', error: e);
              return;
            }
          }
        }
        if (item.isForward == '未转发') {
          flag = true;
          try {
            await DynamicApi.repostDynamic(
              dynIdStr: item.businessId,
              rawText: '互动抽奖',
              cancelToken: cancelToken,
            );
            item.isForward = '已转发';
          } on DioException catch (e) {
            if (e.type == DioExceptionType.cancel) {
              log('转发请求已取消: $e', error: e);
            }
          }
        }
        lotteryDataSource.notifyListeners();
      } else if ((item.lotteryType == '直播预约' || item.lotteryType == '视频预约') &&
          item.isForward == '未预约') {
        if (DateTime.fromMillisecondsSinceEpoch(
              item.lotteryTime! * 1000,
            ).compareTo(DateTime.now()) <
            0) {
          item.isForward = '已截止';
          lotteryDataSource.notifyListeners();
          continue;
        }
        flag = true;
        try {
          await LotteryApi.reserveLottery(
            dynamicIdStr: item.businessId,
            reserveId: item.rid!,
            cancelToken: cancelToken,
          );
          item.isForward = '已预约';
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) {
            log('预约请求已取消: $e', error: e);
          }
        }
        lotteryDataSource.notifyListeners();
      } else if (item.lotteryType == '转发抽奖') {
        if (item.isForward == '已转发') {
          continue;
        }
        flag = true;
        // 点赞
        try {
          var message = await DynamicApi.thumbDynamic(
            dynamicIdStr: item.businessId,
            up: 1,
          );
          debugPrint('点赞: ${message.data}');
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) {
            log('点赞请求已取消: $e', error: e);
          }
        }
        // 评论
        try {
          var responseData = await UserReplyAddApi.userReplyAdd(
            oid: item.commentIdStr!,
            message: commentList[math.Random().nextInt(commentList.length)],
            type: 11,
            cancelToken: cancelToken,
          );
          debugPrint('评论: ${responseData.data['success_toast']}');
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) {
            log('评论请求已取消: $e', error: e);
            return;
          }
        }
        if (item.isForward == '未转发') {
          try {
            var responseData = await DynamicApi.repostDynamic(
              dynIdStr: item.businessId,
              rawText: '转发抽奖',
              cancelToken: cancelToken,
            );
            debugPrint('转发: ${responseData.data}');
          } on DioException catch (e) {
            if (e.type == DioExceptionType.cancel) {
              log('转发请求已取消: $e', error: e);
              return;
            }
          }
          await Future.delayed(const Duration(seconds: 2));
        }

        item.isForward = '转赞评';
        lotteryDataSource.notifyListeners();
      }
      if (flag) {
        await Future.delayed(const Duration(seconds: 10));
      }
    }
    if (!cancelToken.isCancelled) {
      updateLoadStatus(LoadState.done);
    }
  }
}

class LotteryState {
  final LoadState loadState;
  int count;
  // 构造函数
  LotteryState({this.loadState = LoadState.none, this.count = 0});

  LotteryState copyWith({LoadState? loadState, int? count}) {
    return LotteryState(
      loadState: loadState ?? this.loadState,
      count: count ?? this.count,
    );
  }
}
