import 'dart:developer';

import 'package:bilihelper/api/myinfo_api.dart';
import 'package:bilihelper/models/home/home_state.dart';
import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'home_provider.g.dart';

@Riverpod(keepAlive: true)
class Home extends _$Home {
  @override
  HomeState build() {
    return HomeState();
  }

  void updateHomeState(String mid, String uname, String imageUrl) {
    state = state.copyWith(mid: mid, uname: uname, imageUrl: imageUrl);
  }

  Future<void> initProfile() async {
    log('获取用户信息...${DateTime.now()}');

    Response<dynamic> response;
    try {
      response = await MyInfoApi.getMyInfo();
      state = state.copyWith(
        mid: response.data['profile']['mid'].toString(),
        uname: response.data['profile']['name'].toString(),
        imageUrl: response.data['profile']['face'].toString(),
      );
    } catch (e, stackTrace) {
      log('获取用户信息失败: $e', error: e, stackTrace: stackTrace);
    }
  }
}
