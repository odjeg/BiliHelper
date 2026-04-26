// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/common/services/bili_x_dio_service.dart';
import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:bilihelper/common/utils/wbi_generator.dart';
import 'package:bilihelper/models/user/dynamic_model/dynamic_data_source.dart';
import 'package:bilihelper/models/user/dynamic_model/dynamic_item.dart';
import 'package:bilihelper/models/user/user_model.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

part 'dynamic_provider.g.dart';

@Riverpod(keepAlive: true)
class Dynamic extends _$Dynamic {
  @override
  DynamicState build() {
    final cancelToken = CancelToken();
    var isDisposed = false;
    ref.onDispose(() {
      isDisposed = true;
      cancelToken.cancel();
    });
    return DynamicState(
      loadState: LoadState.none,
      count: 0,
      isDisposed: isDisposed,
      cancelToken: cancelToken,
    );
  }

  final DynamicDataSource dynamicDataSource = DynamicDataSource();

  void updateLoadStatus(LoadState loadState) {
    state = state.copyWith(loadState: loadState);
  }

  void updateCount(int count) {
    state = state.copyWith(count: count);
  }

  Future<void> initDynamicInfo() async {
    updateLoadStatus(LoadState.loading);
    if (state.isDisposed) return;

    String? host_mid = await SecureStorageService.getToken('DedeUserID');
    UserModel().dynamicItems.clear();
    dynamicDataSource.notifyListeners();
    String? offset = '';
    Response<dynamic> response;

    try {
      do {
        log('初始化动态列表...');

        response = await BiliXDioService.get(
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
          cancelToken: state.cancelToken,
        );
        if (state.isDisposed ||
            response.data == null ||
            response.data['data'] == null) {
          return;
        }

        offset = response.data['data']['offset'];

        for (var item in response.data['data']['items']) {
          if (item['type'] == 'DYNAMIC_TYPE_FORWARD') //为转发动态
          {
            UserModel().dynamicItems.add(DynamicItem.fromJson(item));
          }
        }
        if (response.data['data']['has_more'] == false) break;

        updateCount(UserModel().dynamicItems.length);

        dynamicDataSource.notifyListeners(); // 刷新数据表格

        await Future.delayed(Duration(milliseconds: 2500));
        if (UserModel().dynamicItems.length >= 400) {
          updateLoadStatus(LoadState.done);
          dynamicDataSource.notifyListeners(); // 刷新数据表格
          break;
        }
      } while (true);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) return;

      if (!state.isDisposed) {
        log('动态列表请求异常: $e');
        updateLoadStatus(LoadState.error);
      }
    } catch (e) {
      log('初始化动态列表失败: $e');
      //updateLoadStatus(LoadState.error);
    }
  }

  Future<void> deleteSelectedDynamic(
    DataGridController dataGridController,
  ) async {
    updateLoadStatus(LoadState.loading);
    if (dataGridController.selectedRows.isEmpty) {
      return;
    }

    // 先复制一份新列表，再遍历，避免并发修改
    final selectedRows = List.from(dataGridController.selectedRows);

    for (var row in selectedRows) {
      var dynamic_id_str = row.getCells()[0].value;

      // 本地删除
      UserModel().dynamicItems.removeWhere(
        (element) => element.idStr == dynamic_id_str,
      );

      dynamicDataSource.notifyListeners();
      // 请求接口
      try {
        var _ = await BiliXDioService.removeDynamic(
          dynamic_id_str: dynamic_id_str,
          dyn_type: 1,
        );
      } catch (e) {
        log('删除动态失败: $e', error: e);
        continue;
      }
      await Future.delayed(const Duration(milliseconds: 2500));
      Future.delayed(const Duration(milliseconds: 2500));
    }
    // 最后统一清空选择
    dataGridController.selectedRows.clear();
    updateLoadStatus(LoadState.done);
  }
}

class DynamicState {
  final LoadState loadState;
  final int count;

  final bool isDisposed;
  final CancelToken cancelToken;
  // 构造函数
  DynamicState({
    this.loadState = LoadState.none,
    this.count = 0,
    required this.isDisposed,
    required this.cancelToken,
  });

  DynamicState copyWith({
    LoadState? loadState,
    int? count,
    bool? isDisposed,
    CancelToken? cancelToken,
  }) {
    return DynamicState(
      loadState: loadState ?? this.loadState,
      count: count ?? this.count,
      isDisposed: isDisposed ?? this.isDisposed,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }
}
