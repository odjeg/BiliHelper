import 'dart:developer';

import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/common/services/bili_x_dio_service.dart';
import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:bilihelper/models/user/following_model/following_data_source.dart';
import 'package:bilihelper/models/user/following_model/following_item.dart';
import 'package:bilihelper/models/user/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final followingProvider =
    NotifierProvider.autoDispose<FollowingNotifier, FollowingState>(
      FollowingNotifier.new,
    );

class FollowingNotifier extends Notifier<FollowingState> {
  @override
  FollowingState build() {
    ref.onDispose(() {
      _isDisposed = true;
      _cancelToken.cancel();
    });
    return FollowingState();
  }

  final FollowingDataSource followingDataSource = FollowingDataSource();
  CancelToken _cancelToken = CancelToken();
  bool _isDisposed = false;

  void updateLoadStatus(LoadState loadState) {
    state = state.copyWith(loadState: loadState);
  }

  void updateLoadTotal(int total) {
    state = state.copyWith(total: total);
  }

  void updateLoadCount(int count) {
    state = state.copyWith(count: count);
  }

  Future<void> initFollowingItems() async {
    if (_isDisposed) return;

    updateLoadStatus(LoadState.loading);
    _cancelToken = CancelToken();
    UserModel().followingItems.clear();
    followingDataSource.notifyListeners();

    int pn = 0;
    String? vmid = await SecureStorageService.getToken('DedeUserID');
    if (vmid == null) {
      updateLoadStatus(LoadState.error);
      return;
    }

    try {
      do {
        if (_isDisposed) return;

        log('初始化关注列表...');

        final response = await BiliXDioService.get(
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
          cancelToken: _cancelToken,
        );

        if (_isDisposed) return;

        final data = response.data;
        if (data == null) break;

        final list = data['data']['list'];
        final total = data['data']['total'] ?? 0;

        if (list != null) {
          for (var item in list) {
            UserModel().followingItems.add(FollowingItem.fromJson(item));
          }
        }

        updateLoadTotal(total);
        updateLoadCount(UserModel().followingItems.length);

        await Future.delayed(Duration(milliseconds: 500));

        if (pn * 50 >= total) break;
      } while (true);

      // 全部加载完成
      if (!_isDisposed) {
        updateLoadStatus(LoadState.done);
      }
    } on DioException catch (e) {
      // 取消请求 → 安静退出
      if (e.type == DioExceptionType.cancel) return;

      if (!_isDisposed) {
        log('关注列表请求异常: $e');
        updateLoadStatus(LoadState.error);
      }
    } catch (e) {
      if (!_isDisposed) {
        log('初始化关注列表失败: $e');
        updateLoadStatus(LoadState.error);
      }
    }
    followingDataSource.notifyListeners();
  }
}

class FollowingState {
  final LoadState loadState;
  final int total;
  final int count;
  // 构造函数
  FollowingState({
    this.loadState = LoadState.none,
    this.total = 0,
    this.count = 0,
  });

  FollowingState copyWith({LoadState? loadState, int? total, int? count}) {
    return FollowingState(
      loadState: loadState ?? this.loadState,
      total: total ?? this.total,
      count: count ?? this.count,
    );
  }
}
