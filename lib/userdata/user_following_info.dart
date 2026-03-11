import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class UserFollowingInfo {
  int mid;
  int attribute;
  int mtime;
  int special;
  String uname;
  String face;
  String sign;

  UserFollowingInfo({
    required this.mid,
    required this.attribute,
    required this.mtime,
    required this.special,
    required this.uname,
    required this.face,
    required this.sign,
  });
  factory UserFollowingInfo.fromJson(Map<String, dynamic> json) {
    return UserFollowingInfo(
      mid: json['mid'],
      attribute: json['attribute'],
      mtime: json['mtime'],
      special: json['special'],
      uname: json['uname'],
      face: json['face'],
      sign: json['sign'],
    );
  }
}

class UserFollowingInfoDataSource extends DataGridSource {
  @override
  List<DataGridRow> get rows {
    // 每次表格读取 rows 时，都从最新的全局列表生成
    return followingList
        .map(
          (item) => DataGridRow(
            cells: [
              DataGridCell<int>(columnName: 'mid', value: item.mid),
              DataGridCell<String>(columnName: 'uname', value: item.uname),
              DataGridCell<String>(
                columnName: 'mtime',
                value: DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    item.mtime * 1000,
                  ).toLocal(),
                ),
              ), //时间戳转日期10位
              DataGridCell<int>(columnName: 'special', value: item.special),
            ],
          ),
        )
        .toList();
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    // TODO: implement buildRow
    return DataGridRowAdapter(
      color:
          row
                  .getCells()
                  .firstWhere((element) => element.columnName == 'special')
                  .value ==
              1
          ? Colors.green[100]
          : null,
      cells: row.getCells().map<Widget>((dataGridCell) {
        switch (dataGridCell.columnName) {
          case 'uname':
            return RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: dataGridCell.value.toString(),
                style: TextStyle(
                  color: Colors.blue[700],
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _launchUrl(
                      'https://space.bilibili.com/${row.getCells().firstWhere((element) => element.columnName == 'mid').value}',
                    );
                  },
              ),
            );
          default:
            return Text(
              textAlign: TextAlign.center,
              dataGridCell.value.toString(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Noto Sans SC'),
            );
        }
      }).toList(),
    );
  }
}

List<UserFollowingInfo> followingList = [];
UserFollowingInfoDataSource userFollowingInfoSource =
    UserFollowingInfoDataSource();
