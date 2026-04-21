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
              DataGridCell<int>(columnName: 'special', value: item.special),
            ],
          ),
        )
        .toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color:
          row
                  .getCells()
                  .firstWhere((element) => element.columnName == 'special')
                  .value ==
              1
          ? Colors.green[400]
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
