import 'package:bilihelper/common/utils/url_lanucher.dart';
import 'package:bilihelper/models/user/user_model.dart';
import 'package:flutter/gestures.dart';
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
      color: effectiveRows.indexOf(row) % 2 == 0
          ? Colors.white
          : const Color(0xfff7f8fa),
      cells: row.getCells().map<Widget>((dataGridCell) {
        switch (dataGridCell.columnName) {
          case 'id_str':
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
          case 'orig_id_str':
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
          case 'orig_name':
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
                      'https://space.bilibili.com/${row.getCells().firstWhere((element) => element.columnName == 'orig_mid').value}',
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
