import 'dart:developer';

import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/common/services/bili_x_dio_service.dart';
import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:bilihelper/models/user/following_model/following_data_source.dart';
import 'package:bilihelper/models/user/following_model/following_item.dart';
import 'package:bilihelper/models/user/user_model.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'following_provider.g.dart';

@Riverpod(keepAlive: true)
class Following extends _$Following {
  @override
  FollowingState build() {
    // ✅ 生命周期由 build 管理，invalidate 就会重置
    _cancelToken = CancelToken();
    ref.onDispose(() {
      log('FollowingProvider 被销毁，取消未完成的请求');
      _cancelToken?.cancel();
    });
    return FollowingState();
  }

  CancelToken? _cancelToken;
  final FollowingDataSource followingDataSource = FollowingDataSource();

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
    final CancelToken cancelToken = _cancelToken!;
    if (cancelToken.isCancelled) return;

    log('初始化关注列表...');

    updateLoadStatus(LoadState.loading);
    UserModel().followingItems.clear();
    followingDataSource.notifyListeners();

    int pn = 0;
    String? vmid = await SecureStorageService.getToken('DedeUserID');
    Response<dynamic> response;

    try {
      do {
        log('初始化关注列表...');
        try {
          response = await BiliXDioService.get(
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
            cancelToken: cancelToken,
          );
        } on DioException catch (e) {
          if (e.type == DioExceptionType.cancel) {
            log('关注列表请求已取消: $e', error: e);
            break;
          }
          rethrow;
        }
        // 取消就退出
        if (cancelToken.isCancelled) break;
        final data = response.data;
        if (data == null) break;
        final list = data['data']['list'] ?? [];
        final total = data['data']['total'] ?? 0;

        for (var item in list) {
          UserModel().followingItems.add(FollowingItem.fromJson(item));
        }

        updateLoadTotal(total);
        updateLoadCount(UserModel().followingItems.length);

        followingDataSource.notifyListeners(); // 刷新数据表格

        await Future.delayed(Duration(milliseconds: 500));

        if (pn * 50 >= total) {
          followingDataSource.notifyListeners();
          updateLoadStatus(LoadState.done);
          break;
        }
      } while (true);
    } catch (e) {
      log('初始化关注列表失败: $e', error: e);
      if (!cancelToken.isCancelled) {
        updateLoadStatus(LoadState.error);
      }
    }
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
