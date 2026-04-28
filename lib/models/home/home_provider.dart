import 'dart:developer';

import 'package:bilihelper/common/services/bili_x_dio_service.dart';
import 'package:bilihelper/models/home/home_state.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_provider.g.dart';

@Riverpod(keepAlive: true)
class Home extends _$Home {
  @override
  HomeState build() {
    ref.onDispose(() {
      log('HomeProvider 被销毁');
    });
    return HomeState();
  }

  void updateHomeState(String mid, String uname, String imageUrl) {
    state = state.copyWith(mid: mid, uname: uname, imageUrl: imageUrl);
  }

  Future<void> initProfile() async {
    log('获取用户信息...${DateTime.now()}');

    Response<dynamic> response;
    try {
      response = await BiliXDioService.get(
        '/space/v2/myinfo',
        queryParameters: {'web_location': '333.1387'},
      );
      state = state.copyWith(
        mid: response.data['data']['profile']['mid'].toString(),
        uname: response.data['data']['profile']['name'].toString(),
        imageUrl: response.data['data']['profile']['face'].toString(),
      );
    } catch (e) {
      log('获取用户信息失败: $e', error: e); // 失败后解锁，允许重试
      return;
    }
  }
}
