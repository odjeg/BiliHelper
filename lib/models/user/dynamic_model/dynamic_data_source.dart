import 'package:bilihelper/models/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DynamicDataSource extends DataGridSource {
  @override
  List<DataGridRow> get rows {
    // 每次表格读取 rows 时，都从最新的全局列表生成
    return UserModel().dynamicItems
        .map(
          (e) => DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'id_str', value: e.idStr),
              DataGridCell<String>(
                columnName: 'pub_ts',
                value: DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(
                    int.parse(e.pubTs) * 1000,
                  ).toLocal(),
                ),
              ),
              DataGridCell<String>(
                columnName: 'orig_id_str',
                value: e.origIdStr,
              ),
              DataGridCell<int>(columnName: 'orig_mid', value: e.origMid),
              DataGridCell<String>(columnName: 'orig_name', value: e.origName),
              DataGridCell<String>(
                columnName: 'following',
                value: e.following == true ? '是' : '否',
              ),
              DataGridCell<String>(
                columnName: 'dynamic_text',
                value: e.dynamicText,
              ),
            ],
          ),
        )
        .toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
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
