import 'package:bilibilihelper/controllers/load_status.dart';
import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:bilibilihelper/userdata/user_dynamic_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;
import 'package:bilibilihelper/userdata/user_lottery_info.dart';
import 'package:provider/provider.dart';
import 'dart:core';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:bilibilihelper/controllers/lottery_controller.dart';
import 'package:bilibilihelper/utils/bili_x_api.dart';

class LotteryPage extends StatefulWidget {
  const LotteryPage({super.key});

  @override
  State<LotteryPage> createState() => _LotteryPageState();
}

class _LotteryPageState extends State<LotteryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 50,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange[300]!,
                      offset: Offset(0, 1),
                      blurRadius: 1.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Consumer<LotteryController>(
                    builder: (context, lotteryController, child) => Text(
                      '已获取抽奖\n${lotteryController.total}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
              ),
              Consumer<LotteryController>(
                builder: (context, lotteryController, child) => IconButton(
                  icon: Icon(Icons.refresh),
                  tooltip: '开始抽奖',
                  onPressed: lotteryController.loadStatus == LoadStatus.loading
                      ? null
                      : () async {
                          lotteryController.loadStatus = LoadStatus.loading;
                          _startLottery(lotteryController);
                        },
                  highlightColor: Colors.pink[100],
                  hoverColor: Colors.pink[50],
                ),
              ),
            ],
          ),
          Expanded(
            child: SfDataGrid(
              source: userLotteryInfoDataSource,
              headerGridLinesVisibility: GridLinesVisibility.horizontal,
              gridLinesVisibility: GridLinesVisibility.horizontal,
              columnWidthMode: ColumnWidthMode.fill,
              selectionMode: SelectionMode.single,
              rowHeight: 25,
              headerRowHeight: 30,
              allowSorting: true,
              columns: [
                GridColumn(
                  columnName: 'business_id',
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '抽奖动态ID',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'mid',
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'UID',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),

                GridColumn(
                  columnName: 'name',
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '用户名',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'followed',
                  allowSorting: false,
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '是否已关注',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'lottery_time',
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '开奖时间',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'isForward',
                  allowSorting: false,
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '是否已转发/预约',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),

                GridColumn(
                  columnName: 'lotteryType',
                  allowSorting: false,
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '抽奖类型',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getClipboardText(LotteryController lotteryController) async {
    userLotteryInfoList.clear();
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
    lotteryController.total = opusIdSet.length;
    userLotteryInfoList = opusIdSet
        .map((e) => UserLotteryInfo(business_id: e))
        .toList();
    userLotteryInfoDataSource.notifyListeners();
  }

  Future<void> _getLotteryInfo(LotteryController lotteryController) async {
    String csrf =
        await SecureStorageService.getToken('bili_jct') ?? 'lottery csrf null';
    for (var item in userLotteryInfoList) {
      var pageDetailResponse = await api.get(
        '/polymer/web-dynamic/v1/detail',
        queryParameters: {'id': item.business_id},
      );
      if (pageDetailResponse.data['code'] == 0) {
        if (pageDetailResponse
                    .data['data']['item']['modules']['module_dynamic']['additional'] ==
                null ||
            pageDetailResponse
                    .data['data']['item']['modules']['module_dynamic']['additional']['type'] !=
                'ADDITIONAL_TYPE_RESERVE') {
          //官方抽奖和普通抽奖additional为空

          item.comment_id_str = pageDetailResponse
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
              dynamicInfoList.any(
                (element) => element.orig_id_str == item.business_id,
              )
              ? '已转发'
              : '未转发';

          var lotteryDetailResponse = await api.get(
            'https://api.vc.bilibili.com/lottery_svr/v1/lottery_svr/lottery_notice',
            queryParameters: {
              'business_id': item.business_id,
              'business_type': 1,
              'csrf': csrf,
              'web_location': '333.1330',
              'x-bili-device-req-json':
                  '{"platform":"web","device":"pc","spmid":"333.1330"}',
            },
          );
          if (lotteryDetailResponse.data['code'] == 0) {
            //code为0，说明是官方抽奖
            item.lotteryType = '互动抽奖';
            item.followed =
                lotteryDetailResponse.data['data']['followed'] ?? false;
            item.lottery_time =
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

          var lotteryDetailResponse = await api.get(
            'https://api.vc.bilibili.com/lottery_svr/v1/lottery_svr/lottery_notice',
            queryParameters: {
              'business_id': rid,
              'business_type': 10,
              'csrf': csrf,
              'web_location': '333.1330',
              'x-bili-device-req-json':
                  '{"platform":"web","device":"pc","spmid":"333.1330"}',
            },
          );
          item.followed =
              lotteryDetailResponse.data['data']['followed'] ?? false;
          item.lottery_time =
              lotteryDetailResponse.data['data']['lottery_time'];
        }
        userLotteryInfoDataSource.notifyListeners();
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Future<void> _startLottery(LotteryController lotteryController) async {
    await _getClipboardText(lotteryController);
    await _getLotteryInfo(lotteryController);
    for (var item in userLotteryInfoList) {
      bool flag = false;
      if (item.lotteryType == '互动抽奖') {
        developer.log(DateTime.now().toString());
        if (DateTime.fromMillisecondsSinceEpoch(
              item.lottery_time! * 1000,
            ).compareTo(DateTime.now()) <
            0) {
          continue;
        }
        //需要关注且转发
        if (item.followed == false) {
          flag = true;
          var response = await api.userModify(fid: item.mid!, act: 1);
          if (response.statusCode == 200 && response.data['code'] == 0) {
            item.followed = true;
          } else {
            developer.log('关注失败: ${response.data}');
          }
        }
        if (item.isForward == '未转发') {
          flag = true;
          var response = await api.repostDynamic(
            data: {
              'type': 1,
              'scene': 4,
              'dyn_id_str': item.business_id,
              'raw_text': '互动抽奖',
            },
          );
          if (response.statusCode == 200 && response.data['code'] == 0) {
            item.isForward = '已转发';
          } else {
            developer.log('转发失败: ${response.data}');
          }
        }
        userLotteryInfoDataSource.notifyListeners();
      } else if ((item.lotteryType == '直播预约' || item.lotteryType == '视频预约') &&
          item.isForward == '未预约') {
        flag = true;
        developer.log('预约抽奖: ${item.business_id} ${item.rid}');
        var response = await api.reserveLottery(
          dynamic_id_str: item.business_id,
          reserve_id: item.rid!,
        );
        if (response.statusCode == 200 && response.data['code'] == 0) {
          item.isForward = '已预约';
          developer.log('预约成功: ${response.data}');
        } else {
          developer.log('预约失败: ${response.data}');
        }
        userLotteryInfoDataSource.notifyListeners();
      } else if (item.lotteryType == '转发抽奖') {
        //需要转发点赞评论
        flag = true;
        var thumbResponse = await api.userThumb(
          dynamic_id_str: item.business_id,
          up: 1,
        );
        if (thumbResponse.statusCode == 200 &&
            thumbResponse.data['code'] == 0) {
          developer.log('点赞: ${thumbResponse.data}');
          await Future.delayed(const Duration(seconds: 2));
        } else {
          developer.log('点赞失败: ${thumbResponse.data}');
        }
        var replyResponse = await api.userReplyAdd(
          oid: item.comment_id_str!,
          message: '我我我',
          type: 11,
        );
        if (replyResponse.statusCode == 200 &&
            replyResponse.data['code'] == 0) {
          await Future.delayed(const Duration(seconds: 2));
          developer.log('评论: ${replyResponse.data}');
        } else {
          developer.log('评论失败: ${replyResponse.data}');
        }
        if (item.isForward == '未转发') {
          var respostResponse = await api.repostDynamic(
            data: {
              'type': 1,
              'scene': 4,
              'dyn_id_str': item.business_id,
              'raw_text': '转发抽奖',
            },
          );
          if (respostResponse.statusCode == 200 &&
              respostResponse.data['code'] == 0) {
            developer.log('转发: ${respostResponse.data}');
          } else {
            developer.log('转发失败: ${respostResponse.data}');
          }
          await Future.delayed(const Duration(seconds: 2));
        }

        item.isForward = '转赞评';
        userLotteryInfoDataSource.notifyListeners();
      }
      if (flag) {
        await Future.delayed(const Duration(seconds: 10));
      }
    }
    lotteryController.loadStatus = LoadStatus.done;
  }
}
