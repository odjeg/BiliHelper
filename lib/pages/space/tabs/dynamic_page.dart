import 'dart:developer' as developer;
import 'package:bilibilihelper/controllers/dynamic_controller.dart';
import 'package:bilibilihelper/controllers/load_status.dart';
import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:bilibilihelper/userdata/user_dynamic_info.dart';
import 'package:bilibilihelper/utils/bili_x_api.dart';
import 'package:bilibilihelper/utils/wbi_generator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DynamicPage extends StatefulWidget {
  const DynamicPage({super.key});

  @override
  State<DynamicPage> createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Text('我的动态'),
      //   actions: [
      //     Consumer<DynamicController>(
      //       builder: (context, dynamicController, child) =>
      //           dynamicController.isLoading
      //           ? CircularProgressIndicator(
      //               value: dynamicController.total == 0
      //                   ? 0.0
      //                   : dynamicController.total / 200.0,
      //             )
      //           : IconButton(
      //               icon: Icon(Icons.refresh),
      //               onPressed: () async {
      //                 if (dynamicController.isLoading) {
      //                   return;
      //                 }

      //                 developer.log('刷新动态列表');
      //                 dynamicController.isLoading = true;
      //                 initDynamicInfo(dynamicController);
      //               },
      //             ),
      //     ),
      //     SizedBox(width: 10),
      //   ],
      // ),
      body: Column(
        children: [
          opBar(),
          Expanded(
            child: SfDataGridTheme(
              data: SfDataGridThemeData(selectionColor: Colors.pink[50]),
              child: SfDataGrid(
                source: userDynamicInfoSource,
                headerGridLinesVisibility: GridLinesVisibility.vertical,
                gridLinesVisibility: GridLinesVisibility.vertical,
                columnWidthMode: ColumnWidthMode.fill,
                selectionMode: SelectionMode.single,
                rowHeight: 25,
                headerRowHeight: 30,
                allowSorting: true,
                columns: [
                  //根据UserDynamicInfo的字段，添加列
                  GridColumn(
                    columnName: 'id_str',
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '动态ID',
                        style: TextStyle(fontFamily: 'Noto Sans SC'),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'pub_ts',
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '转发时间',
                        style: TextStyle(fontFamily: 'Noto Sans SC'),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'orig_id_str',
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '转发动态ID',
                        style: TextStyle(fontFamily: 'Noto Sans SC'),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'orig_mid',
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '转发用户UID',
                        style: TextStyle(fontFamily: 'Noto Sans SC'),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'orig_name',
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '转发用户名',
                        style: TextStyle(fontFamily: 'Noto Sans SC'),
                      ),
                    ),
                  ),
                  GridColumn(
                    allowSorting: false,
                    columnName: 'following',
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '是否关注',
                        style: TextStyle(fontFamily: 'Noto Sans SC'),
                      ),
                    ),
                  ),
                  GridColumn(
                    allowSorting: false,
                    columnName: 'dynamic_text',
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '动态类型',
                        style: TextStyle(fontFamily: 'Noto Sans SC'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class opBar extends StatefulWidget {
  const opBar({super.key});

  @override
  State<opBar> createState() => _opBarState();
}

class _opBarState extends State<opBar> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 100,
          height: 50,
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.red[200]!,
                offset: Offset(0, 1),
                blurRadius: 1.0,
              ),
            ],
          ),
          child: Center(
            child: Consumer<DynamicController>(
              builder: (context, dynamicController, child) {
                return Text(
                  textAlign: TextAlign.center,
                  '已获取动态\n${dynamicController.total}',
                  style: TextStyle(fontFamily: 'Noto Sans SC'),
                );
              },
            ),
          ),
        ),
        Consumer<DynamicController>(
          builder: (context, dynamicController, child) => IconButton(
            icon: Icon(Icons.refresh),
            tooltip: '刷新动态列表',
            onPressed: dynamicController.loadStatus == LoadStatus.loading
                ? null
                : () async {
                    dynamicController.loadStatus = LoadStatus.loading;
                    initDynamicInfo(dynamicController);
                  },
            highlightColor: Colors.pink[100],
            hoverColor: Colors.pink[50],
          ),
        ),
      ],
    );
  }

  Future<void> initDynamicInfo(DynamicController dynamicController) async {
    String? host_mid = await SecureStorageService.getToken('DedeUserID');
    dynamicInfoList.clear();
    userDynamicInfoSource.notifyListeners();
    String? offset = '';
    do {
      var response = await api.get(
        '/polymer/web-dynamic/v1/feed/space',
        queryParameters: await WbiGenerator().genWbi(
          params: {
            'offset': offset,
            'host_mid': host_mid,
            'timezone_offset': '-480',
            'platform': 'web',
            'web_location': '333.1387',
          },
        ),
      );
      offset = response.data['data']['offset'];
      for (var item in response.data['data']['items']) {
        if (item['type'] == 'DYNAMIC_TYPE_FORWARD') //为转发动态
        {
          dynamicInfoList.add(UserDynamicInfo.fromJson(item));
        }
      }
      dynamicController.total = dynamicInfoList.length;
      userDynamicInfoSource.notifyListeners();
      await Future.delayed(Duration(milliseconds: 2500));
    } while (dynamicInfoList.length < 200);
    dynamicController.loadStatus = LoadStatus.done;
  }
}
