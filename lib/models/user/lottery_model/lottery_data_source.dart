import 'package:bilihelper/common/utils/url_lanucher.dart';
import 'package:bilihelper/models/user/user_model.dart';
import 'package:flutter/gestures.dart';
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
              value: e.businessId,
            ),
            DataGridCell<int>(columnName: 'mid', value: e.mid ?? 0),
            DataGridCell<String>(columnName: 'name', value: e.name ?? ''),
            DataGridCell<String>(
              columnName: 'followed',
              value: e.followed == true ? '是' : '否',
            ),
            DataGridCell<String>(
              columnName: 'lottery_time',
              value: e.lotteryTime == null
                  ? ''
                  : DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(
                        e.lotteryTime! * 1000,
                      ).toLocal(),
                    ),
            ),
            DataGridCell<String>(
              columnName: 'isForward',
              value: e.isForward ?? '',
            ),
            DataGridCell<String>(
              columnName: 'lotteryType',
              value: e.lotteryType ?? '',
            ),
          ],
        ),
      )
      .toList();

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      color: effectiveRows.indexOf(row) % 2 == 0
          ? Colors.white
          : const Color(0xfff7f8fa),
      cells: row.getCells().map<Widget>((dataGridCell) {
        switch (dataGridCell.columnName) {
          case 'business_id':
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
                      'https://www.bilibili.com/opus/${dataGridCell.value.toString()}?spm_id_from=333.1387.0.0',
                    );
                  },
              ),
            );
          case 'name':
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
