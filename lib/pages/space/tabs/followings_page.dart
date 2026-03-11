import 'dart:developer' as developer;
import 'package:bilibilihelper/controllers/followings_controller.dart';
import 'package:bilibilihelper/controllers/load_status.dart';
import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:bilibilihelper/userdata/user_following_info.dart';
import 'package:bilibilihelper/utils/bili_x_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class FollowingsPage extends StatefulWidget {
  const FollowingsPage({super.key});
  @override
  State<FollowingsPage> createState() => _FollowingsPageState();
}

class _FollowingsPageState extends State<FollowingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          opBar(),
          Expanded(
            child: SfDataGridTheme(
              data: SfDataGridThemeData(selectionColor: Colors.pink[50]),
              child: SfDataGrid(
                headerGridLinesVisibility: GridLinesVisibility.horizontal,
                gridLinesVisibility: GridLinesVisibility.horizontal,
                source: userFollowingInfoSource,
                columnWidthMode: ColumnWidthMode.fill,
                selectionMode: SelectionMode.single,
                rowHeight: 25,
                headerRowHeight: 30,
                allowSorting: true,
                columns: [
                  GridColumn(
                    columnName: 'mid',
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'UID',
                        style: TextStyle(fontFamily: 'Noto Sans SC'),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'uname',
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '用户名',
                        style: TextStyle(fontFamily: 'Noto Sans SC'),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'mtime',
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '关注时间',
                        style: TextStyle(fontFamily: 'Noto Sans SC'),
                      ),
                    ),
                  ),
                  GridColumn(
                    columnName: 'special',
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(
                        '特别关注',
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
                color: Colors.purple[200]!,
                offset: Offset(0, 1),
                blurRadius: 1.0,
              ),
            ],
          ),
          child: Center(
            child: Consumer<FollowingsController>(
              builder: (context, followingsController, child) => Text(
                '全部关注\n${followingsController.total == followingList.length ? followingList.length : '${followingList.length}/${followingsController.total}'}',
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Noto Sans SC'),
              ),
            ),
          ),
        ),
        Consumer<FollowingsController>(
          builder: (context, followingsController, child) => IconButton(
            icon: Icon(Icons.refresh),
            tooltip: '刷新关注列表',
            onPressed: followingsController.loadStatus == LoadStatus.loading
                ? null
                : () async {
                    developer.log('刷新关注列表');
                    followingsController.loadStatus = LoadStatus.loading;
                    initFollowingList(followingsController);
                  },
            highlightColor: Colors.pink[100],
            hoverColor: Colors.pink[50],
          ),
        ),
      ],
    );
  }

  Future<void> initFollowingList(
    FollowingsController followingsController,
  ) async {
    followingList.clear();
    userFollowingInfoSource.notifyListeners();
    int pn = 0;
    String? vmid = await SecureStorageService.getToken('DedeUserID');
    do {
      Response<dynamic> response = await api.get(
        '/relation/followings',
        queryParameters: {
          'order': 'desc',
          'order_type': '',
          'vmid': vmid,
          'pn': ++pn,
          'ps': 50,
          'gaia_source': 'main_web',
          'web_location': '333.1387',
        },
      );
      developer.log('获取关注列表ing...');
      followingsController.total = response.data['data']['total'];
      for (var item in response.data['data']['list']) {
        followingList.add(UserFollowingInfo.fromJson(item));
      }
      userFollowingInfoSource.notifyListeners();
      await Future.delayed(Duration(milliseconds: 500));
    } while (pn * 50 < followingsController.total);
    followingsController.loadStatus = LoadStatus.done;
  }
}

//https://api.bilibili.com/x/relation/followings?order=desc&order_type=&vmid=175637270&pn=1&ps=24&gaia_source=main_web&web_location=333.1387
