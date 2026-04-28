import 'dart:async';
import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:bilihelper/models/login/login_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';

final loginProvider = NotifierProvider.autoDispose<LoginNotifier, LoginState>(
  LoginNotifier.new,
);

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() {
    ref.onDispose(() {
      log('LoginProvider 被销毁，取消未完成的请求');
    });
    return LoginState(
      url: '',
      qrcodeKey: '',
      message: '',
      isRequesting: false,
      isLoginSuccess: false,
    );
  }

  Timer? _pollingTimer;
  static final Dio dio = Dio()
    ..options.connectTimeout = Duration(seconds: 5)
    ..options.receiveTimeout = Duration(seconds: 5);

  Future<void> initQrCode() async {
    await _fetchQrData();
  }

  Future<void> _fetchQrData() async {
    log('开始获取二维码');
    try {
      var response = await dio.get(
        'https://passport.bilibili.com/x/passport-login/web/qrcode/generate',
      );
      log('获取二维码响应：${response.data}');
      if (response.data['code'] == 0) {
        // 校验接口返回成功
        state = state.copyWith(
          url: response.data['data']['url'],
          qrcodeKey: response.data['data']['qrcode_key'],
          message: '请扫描二维码登录',
        );
        log('获取到二维码：${state.url}');
        log('二维码key：${state.qrcodeKey}');
        _startPolling();
        // 开始轮询检查二维码状态
      } else {
        state = state.copyWith(message: '获取二维码失败：${response.data['message']}');
      }
    } catch (e) {
      log('获取二维码失败: $e', error: e);
      state = state.copyWith(message: '网络异常，无法获取二维码');
      // 延迟重试
      _retryFetchQr();
    }
  }

  Future<void> _checkQrStatus() async {
    log('检查二维码状态');
    // 避免空值请求 + 重复请求
    if (state.qrcodeKey == null || state.isRequesting) return;
    state.isRequesting = true;

    try {
      var response = await dio.get(
        'https://passport.bilibili.com/x/passport-login/web/qrcode/poll',
        queryParameters: {'qrcode_key': state.qrcodeKey},
      );
      state = state.copyWith(
        message: '${response.data['data']['message']} ${DateTime.now()}',
      );
      switch (response.data['data']['code']) {
        case 0:
          // 登录成功
          await _handleLoginSuccess(response.data['data']['url']);
          break;
        case 86038:
          // 二维码过期
          _handleQrExpired();
          break;
      }
    } catch (e) {
      log('检查二维码状态失败: $e', error: e);
    } finally {
      state = state.copyWith(isRequesting: false); // 释放请求锁
    }
  }

  // 重试获取二维码
  void _retryFetchQr() {
    Timer(const Duration(seconds: 3), _fetchQrData);
  }

  // 处理登录成功
  Future<void> _handleLoginSuccess(String url) async {
    await SecureStorageService.saveTokenFromUrl(url);
    await SecureStorageService.getBuvid();
    await SecureStorageService.getWbi();
    _stopPolling();

    // 登录成功后，跳转到主页面
    state = state.copyWith(message: '登录成功', isLoginSuccess: true);
  }

  // 处理二维码过期
  void _handleQrExpired() {
    _stopPolling();
    state = state.copyWith(
      url: '',
      qrcodeKey: null,
      message: '二维码已过期，重新获取中...',
    );
    _fetchQrData();
  }

  void _startPolling() {
    log('开始轮询检查二维码状态');
    _stopPolling();
    // 开始轮询检查二维码状态
    _pollingTimer = Timer.periodic(Duration(seconds: 2), (timer) {
      _checkQrStatus();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}
