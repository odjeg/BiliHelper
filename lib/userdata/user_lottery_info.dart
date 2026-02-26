// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class UserLotteryInfo {
  String business_id; //抽奖动态id
  String? comment_id_str; //用来评论评论id|oid
  int? mid;
  String? name;
  bool? followed; //是否关注
  int? lottery_time; //开奖时间
  int? ts; //动态时间戳
  String? isForward; //是否转发如果是预约抽奖则为是否预约
  String? lotteryType; //官方抽奖 直播预约 视频预约 普通抽奖
  int? rid; //预约抽奖需要用到
  UserLotteryInfo({
    required this.business_id,
    this.mid,
    this.name,
    this.followed,
    this.lottery_time,
    this.ts,
    this.isForward,
    this.lotteryType,
    this.rid,
  });
}

class UserLotteryInfoDataSource extends DataGridSource {
  @override
  List<DataGridRow> get rows => userLotteryInfoList
      .map<DataGridRow>(
        (e) => DataGridRow(
          cells: [
            DataGridCell<String>(
              columnName: 'business_id',
              value: e.business_id,
            ),
            DataGridCell<int?>(columnName: 'mid', value: e.mid),
            DataGridCell<String?>(columnName: 'name', value: e.name),
            DataGridCell<String>(
              columnName: 'followed',
              value: e.followed == true ? '是' : '否',
            ),
            DataGridCell<String>(
              columnName: 'lottery_time',
              value: e.lottery_time == null
                  ? ''
                  : DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(
                        e.lottery_time! * 1000,
                      ).toLocal(),
                    ),
            ),
            DataGridCell<String>(columnName: 'isForward', value: e.isForward),
            DataGridCell<String>(
              columnName: 'lotteryType',
              value: e.lotteryType,
            ),
          ],
        ),
      )
      .toList();

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Text(
          textAlign: TextAlign.center,
          dataGridCell.value.toString(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontFamily: 'Noto Sans SC'),
        );
      }).toList(),
    );
  }
}

List<UserLotteryInfo> userLotteryInfoList = [];
UserLotteryInfoDataSource userLotteryInfoDataSource =
    UserLotteryInfoDataSource();
