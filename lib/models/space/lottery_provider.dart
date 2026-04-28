import 'dart:developer';
import 'dart:math' as math;
import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/common/services/bili_x_dio_service.dart';
import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:bilihelper/models/user/lottery_model/lottery_data_source.dart';
import 'package:bilihelper/models/user/lottery_model/lottery_item.dart';
import 'package:bilihelper/models/user/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
    try {
      String csrf =
          await SecureStorageService.getToken('bili_jct') ??
          'lottery csrf null';

      for (var item in UserModel().lotteryItems) {
        Response<dynamic> pageDetailResponse;
        try {
          pageDetailResponse = await BiliXDioService.get(
            '/polymer/web-dynamic/v1/detail',
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
        if (pageDetailResponse.data == null) break;

        if (pageDetailResponse.data['code'] == 0) {
          if (pageDetailResponse
                      .data['data']['item']['modules']['module_dynamic']['additional'] ==
                  null ||
              pageDetailResponse
                      .data['data']['item']['modules']['module_dynamic']['additional']['type'] !=
                  'ADDITIONAL_TYPE_RESERVE') {
            //官方抽奖和普通抽奖additional为空

            item.commentIdStr = pageDetailResponse
                .data['data']['item']['basic']['comment_id_str'];
            item.mid = pageDetailResponse
                .data['data']['item']['modules']['module_author']['mid'];
            item.name = pageDetailResponse
                .data['data']['item']['modules']['module_author']['name'];
            item.followed =
                pageDetailResponse
                    .data['data']['item']['modules']['module_author']['following'] ??
                false; //如果是预约抽奖不知道为什么返回null

            item.isForward =
                UserModel().dynamicItems.any(
                  (element) => element.origIdStr == item.businessId,
                )
                ? '已转发'
                : '未转发';
            Response<dynamic> lotteryDetailResponse;
            try {
              lotteryDetailResponse = await BiliXDioService.get(
                'https://api.vc.bilibili.com/lottery_svr/v1/lottery_svr/lottery_notice',
                queryParameters: {
                  'business_id': item.businessId,
                  'business_type': 1,
                  'csrf': csrf,
                  'web_location': '333.1330',
                  'x-bili-device-req-json':
                      '{"platform":"web","device":"pc","spmid":"333.1330"}',
                },
                cancelToken: cancelToken,
              );
            } on DioException catch (e) {
              if (e.type == DioExceptionType.cancel) {
                log('抽奖详情请求已取消: $e', error: e);
                return;
              }
              rethrow; // 其他 Dio 错误继续抛出，交由外层 catch 处理
            }

            if (cancelToken.isCancelled) break;
            if (lotteryDetailResponse.data == null) break;

            if (lotteryDetailResponse.data['code'] == 0) {
              //code为0，说明是官方抽奖
              item.lotteryType = '互动抽奖';
              item.followed =
                  lotteryDetailResponse.data['data']['followed'] ?? false;
              item.lotteryTime =
                  lotteryDetailResponse.data['data']['lottery_time'];
            } else {
              item.lotteryType = '转发抽奖';
            }
          } else {
            //不为空说明是预约抽奖
            int rid = pageDetailResponse
                .data['data']['item']['modules']['module_dynamic']['additional']['reserve']['rid']; //预约抽奖需要使用rid查询
            item.rid = rid;

            int status = pageDetailResponse
                .data['data']['item']['modules']['module_dynamic']['additional']['reserve']['button']['status'];
            int type = pageDetailResponse
                .data['data']['item']['modules']['module_dynamic']['additional']['reserve']['button']['type'];
            if (status == 1) {
              item.isForward = '未预约';
            } else if (status == 2) {
              item.isForward = '已预约';
            }
            if (type == 1) {
              item.lotteryType = '视频预约';
            } else if (type == 2) {
              item.lotteryType = '直播预约';
            }
            //mid和name在detail中获取
            item.mid = pageDetailResponse
                .data['data']['item']['modules']['module_author']['mid'];
            item.name = pageDetailResponse
                .data['data']['item']['modules']['module_author']['name'];

            Response<dynamic> lotteryDetailResponse;
            try {
              lotteryDetailResponse = await BiliXDioService.get(
                'https://api.vc.bilibili.com/lottery_svr/v1/lottery_svr/lottery_notice',
                queryParameters: {
                  'business_id': rid,
                  'business_type': 10,
                  'csrf': csrf,
                  'web_location': '333.1330',
                  'x-bili-device-req-json':
                      '{"platform":"web","device":"pc","spmid":"333.1330"}',
                },
                cancelToken: cancelToken,
              );
            } on DioException catch (e) {
              if (e.type == DioExceptionType.cancel) {
                log('抽奖详情请求已取消: $e', error: e);
                return;
              }
              rethrow; // 其他 Dio 错误继续抛出，交由外层 catch 处理
            }
            if (cancelToken.isCancelled) break;
            if (lotteryDetailResponse.data == null) break;
            item.followed =
                lotteryDetailResponse.data['data']['followed'] ?? false;
            item.lotteryTime =
                lotteryDetailResponse.data['data']['lottery_time'];
          }
          lotteryDataSource.notifyListeners();
        }
        await Future.delayed(const Duration(seconds: 2));
      }
    } catch (e) {
      log('获取抽奖信息失败: $e', error: e);
      if (!cancelToken.isCancelled) {
        updateLoadStatus(LoadState.error);
      }
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

    try {
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
            continue;
          }
          //需要关注且转发
          if (item.followed == false) {
            flag = true;
            try {
              var response = await BiliXDioService.userModify(
                fid: item.mid!,
                act: 1,
                cancelToken: cancelToken,
              );
              if (response.statusCode == 200 && response.data['code'] == 0) {
                item.followed = true;
              } else {
                log('关注失败: ${response.data}');
              }
            } on DioException catch (e) {
              if (e.type == DioExceptionType.cancel) {
                log('关注请求已取消: $e', error: e);
                return;
              }
              rethrow;
            }
          }
          if (item.isForward == '未转发') {
            flag = true;
            try {
              var response = await BiliXDioService.repostDynamic(
                data: {
                  'type': 1,
                  'scene': 4,
                  'dyn_id_str': item.businessId,
                  'raw_text': '互动抽奖',
                },
                cancelToken: cancelToken,
              );
              if (response.statusCode == 200 && response.data['code'] == 0) {
                item.isForward = '已转发';
              } else {
                log('转发失败: ${response.data}');
              }
            } on DioException catch (e) {
              if (e.type == DioExceptionType.cancel) {
                log('转发请求已取消: $e', error: e);
                return;
              }
              rethrow;
            }
          }
          lotteryDataSource.notifyListeners();
        } else if ((item.lotteryType == '直播预约' || item.lotteryType == '视频预约') &&
            item.isForward == '未预约') {
          flag = true;
          try {
            var response = await BiliXDioService.reserveLottery(
              dynamicIdStr: item.businessId,
              reserveId: item.rid!,
              cancelToken: cancelToken,
            );
            if (response.statusCode == 200 && response.data['code'] == 0) {
              item.isForward = '已预约';
              log('预约成功: ${response.data}');
            } else {
              log('预约失败: ${response.data}');
            }
          } on DioException catch (e) {
            if (e.type == DioExceptionType.cancel) {
              log('预约请求已取消: $e', error: e);
              return;
            }
            rethrow;
          }
          lotteryDataSource.notifyListeners();
        } else if (item.lotteryType == '转发抽奖') {
          //需要转发点赞评论
          flag = true;
          try {
            var thumbResponse = await BiliXDioService.userThumb(
              dynamicIdStr: item.businessId,
              up: 1,
            );
            if (thumbResponse.statusCode == 200 &&
                thumbResponse.data['code'] == 0) {
              log('点赞: ${thumbResponse.data}');
              await Future.delayed(const Duration(seconds: 2));
            } else {
              log('点赞失败: ${thumbResponse.data}');
            }
          } on DioException catch (e) {
            if (e.type == DioExceptionType.cancel) {
              log('点赞请求已取消: $e', error: e);
              return;
            }
            rethrow;
          }
          try {
            var replyResponse = await BiliXDioService.userReplyAdd(
              oid: item.commentIdStr!,
              message: commentList[math.Random().nextInt(commentList.length)],
              type: 11,
              cancelToken: cancelToken,
            );
            if (replyResponse.statusCode == 200 &&
                replyResponse.data['code'] == 0) {
              await Future.delayed(const Duration(seconds: 2));
              log('评论: ${replyResponse.data}');
            } else {
              log('评论失败: ${replyResponse.data}');
            }
          } on DioException catch (e) {
            if (e.type == DioExceptionType.cancel) {
              log('评论请求已取消: $e', error: e);
              return;
            }
            rethrow;
          }
          if (item.isForward == '未转发') {
            try {
              var respostResponse = await BiliXDioService.repostDynamic(
                data: {
                  'type': 1,
                  'scene': 4,
                  'dyn_id_str': item.businessId,
                  'raw_text': '转发抽奖',
                },
                cancelToken: cancelToken,
              );
              if (respostResponse.statusCode == 200 &&
                  respostResponse.data['code'] == 0) {
                log('转发: ${respostResponse.data}');
              } else {
                log('转发失败: ${respostResponse.data}');
              }
            } on DioException catch (e) {
              if (e.type == DioExceptionType.cancel) {
                log('转发请求已取消: $e', error: e);
                return;
              }
              rethrow;
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
    } catch (e) {
      log('初始化抽奖列表失败: $e');
      if (!cancelToken.isCancelled) {
        updateLoadStatus(LoadState.error);
      }
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
