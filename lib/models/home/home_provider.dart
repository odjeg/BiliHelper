import 'dart:developer';

import 'package:bilihelper/common/services/bili_x_dio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeProvider = NotifierProvider.autoDispose<HomeNotifier, HomeState>(
  HomeNotifier.new,
);

class HomeNotifier extends Notifier<HomeState> {
  @override
  HomeState build() {
    return HomeState();
  }

  void updateHomeState(String mid, String uname, String imageUrl) {
    state = state.copyWith(mid: mid, uname: uname, imageUrl: imageUrl);
  }

  // 🔥 加一个锁，保证只执行一次（核心修复）

  // bool _hasInit = false;

  Future<void> initProfile() async {
    //if (_hasInit) return;
    //_hasInit = true;
    log('获取用户信息...${DateTime.now()}');
    //log('调用栈:', stackTrace: StackTrace.current);
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
      //_hasInit = false;
      return;
    }
  }

  void logout() {
    state = state.copyWith(mid: null, uname: null, imageUrl: null);

    //_hasInit = false; // 退出登录重置锁
  }
}

class HomeState {
  final String? mid;
  final String? uname;
  final String? imageUrl;

  HomeState({this.mid, this.uname, this.imageUrl});

  HomeState copyWith({String? mid, String? uname, String? imageUrl}) {
    return HomeState(
      mid: mid ?? this.mid,
      uname: uname ?? this.uname,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
