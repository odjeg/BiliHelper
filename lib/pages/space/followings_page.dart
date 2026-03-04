import 'dart:developer' as developer;
import 'package:bilibilihelper/controllers/followings_controller.dart';
import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:bilibilihelper/userdata/user_following_info.dart';
import 'package:bilibilihelper/utils/bili_x_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class FollowingsPage extends StatefulWidget {
  const FollowingsPage({super.key});
  @override
  State<FollowingsPage> createState() => _FollowingsPageState();
}

class _FollowingsPageState extends State<FollowingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('我的关注', style: TextStyle(fontFamily: 'Noto Sans SC')),
        actions: [
          Consumer<FollowingsController>(
            builder: (context, followingsController, child) =>
                followingsController.isLoading
                ? CircularProgressIndicator(
                    value: followingsController.total == 0
                        ? 0.0
                        : followingList.length / followingsController.total,
                  )
                : IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () async {
                      if (followingsController.isLoading) {
                        return;
                      }

                      developer.log('刷新关注列表');
                      followingsController.isLoading = true;
                      initFollowingList(followingsController);
                    },
                  ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),

        child: SfDataGrid(
          headerGridLinesVisibility: GridLinesVisibility.both,
          gridLinesVisibility: GridLinesVisibility.both,
          source: userFollowingInfoSource,
          columnWidthMode: ColumnWidthMode.fill,
          selectionMode: SelectionMode.single,
          rowHeight: 25,
          headerRowHeight: 30,
          allowSorting: true,

          //onSelectionChanged: (addedRows, removedRows) =>
          //    developer.log(_dataGridController.selectedIndex.toString()),
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
    followingsController.isLoading = false;
  }
}

//https://api.bilibili.com/x/relation/followings?order=desc&order_type=&vmid=175637270&pn=1&ps=24&gaia_source=main_web&web_location=333.1387
