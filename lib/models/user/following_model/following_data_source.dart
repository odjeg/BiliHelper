import 'package:bilihelper/common/utils/url_lanucher.dart';
import 'package:bilihelper/models/user/user_model.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

class FollowingDataSource extends DataGridSource {
  @override
  List<DataGridRow> get rows {
    // 每次表格读取 rows 时，都从最新的全局列表生成
    return UserModel().followingItems
        .map(
          (item) => DataGridRow(
            cells: [
              DataGridCell<int>(columnName: 'mid', value: item.mid),
              DataGridCell<String>(columnName: 'uname', value: item.uname),
              DataGridCell<DateTime>(
                columnName: 'mtime',
                value: item.mtime,
              ), //时间戳转日期10位
              DataGridCell<String>(
                columnName: 'special',
                value: item.special == 0 ? "否" : "是",
              ),
            ],
          ),
        )
        .toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: effectiveRows.indexOf(row) % 2 == 0
          ? Colors.white
          : const Color(0xfff7f8fa),
      cells: row.getCells().map<Widget>((dataGridCell) {
        switch (dataGridCell.columnName) {
          case 'uname':
            return RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: dataGridCell.value.toString(),
                style: TextStyle(
                  color: Colors.blue[700],
                  fontFamily: 'Noto Sans SC',
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    UrlLauncher.launch(
                      'https://space.bilibili.com/${row.getCells().firstWhere((element) => element.columnName == 'mid').value}',
                    );
                  },
              ),
            );
          case 'mtime':
            return Text(
              textAlign: TextAlign.center,
              DateFormat('yyyy-MM-dd HH:mm:ss').format(dataGridCell.value),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Noto Sans SC'),
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
