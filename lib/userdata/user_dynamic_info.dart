import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class UserDynamicInfo {
  final String id_str; // 个人转发动态id
  final String pub_ts; // 动态发布时间戳

  final String orig_id_str;
  final int orig_mid;
  final String orig_name;
  final bool following;
  final String dynamic_text;

  UserDynamicInfo({
    required this.id_str,
    required this.pub_ts,
    required this.orig_id_str,
    required this.orig_mid,
    required this.orig_name,
    required this.following,
    required this.dynamic_text,
  });
  factory UserDynamicInfo.fromJson(Map<String, dynamic> json) {
    return UserDynamicInfo(
      id_str: json['id_str'],
      pub_ts: json['modules']['module_author']['pub_ts'],
      orig_id_str: json['orig']['id_str'],
      orig_mid: json['orig']['modules']['module_author']['mid'],
      orig_name: json['orig']['modules']['module_author']['name'],
      following: json['orig']['modules']['module_author']['following'],
      dynamic_text: json['modules']['module_dynamic']['desc']['text'],
    );
  }
}

class UserDynamicInfoDataSource extends DataGridSource {
  @override
  List<DataGridRow> get rows {
    // 每次表格读取 rows 时，都从最新的全局列表生成
    return dynamicInfoList
        .map(
          (e) => DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'id_str', value: e.id_str),
              DataGridCell<String>(
                columnName: 'pub_ts',
                value: DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(e.pub_ts) * 1000,
                  ).toLocal(),
                ),
              ),
              DataGridCell<String>(
                columnName: 'orig_id_str',
                value: e.orig_id_str,
              ),
              DataGridCell<int>(columnName: 'orig_mid', value: e.orig_mid),
              DataGridCell<String>(columnName: 'orig_name', value: e.orig_name),
              DataGridCell<String>(
                columnName: 'following',
                value: e.following == true ? '是' : '否',
              ),
              DataGridCell<String>(
                columnName: 'dynamic_text',
                value: e.dynamic_text,
              ),
            ],
          ),
        )
        .toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    // TODO: implement buildRow
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          child: Text(
            dataGridCell.value.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Noto Sans SC'),
          ),
        );
      }).toList(),
    );
  }
}

List<UserDynamicInfo> dynamicInfoList = [];
UserDynamicInfoDataSource userDynamicInfoSource = UserDynamicInfoDataSource();
