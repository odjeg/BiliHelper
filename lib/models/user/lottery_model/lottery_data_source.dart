import 'package:bilihelper/models/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class LotteryDataSource extends DataGridSource {
  @override
  List<DataGridRow> get rows => UserModel().lotteryItems
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
