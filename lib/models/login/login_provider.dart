import 'dart:async';
import 'package:bilihelper/api/passport_api.dart';
import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:bilihelper/models/login/login_state.dart';
import 'package:flutter/material.dart';
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

  Future<void> initQrCode() async {
    await _fetchQrData();
  }

  Future<void> _fetchQrData() async {
    log('开始获取二维码');
    try {
      var responseData = await PassportApi.qrcodeGenerate();
      debugPrint('获取到二维码响应：${responseData.data}');
      state = state.copyWith(
        url: responseData.data['url'],
        qrcodeKey: responseData.data['qrcode_key'],
        message: '请扫描二维码登录',
      );
      log('获取到二维码：${state.url}');
      log('二维码key：${state.qrcodeKey}');
      // 开始轮询检查二维码状态
      _startPolling();
    } catch (e, stackTrace) {
      log('获取二维码异常: $e', error: e, stackTrace: stackTrace);
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
      var responseData = await PassportApi.qrcodePoll(state.qrcodeKey!);

      state = state.copyWith(
        message: '${responseData.data['message']}|${DateTime.now()}',
      );
      switch (responseData.data['code']) {
        case 0:
          // 登录成功
          await _handleLoginSuccess(responseData.data['url']);
          break;
        case 86038:
          // 二维码过期
          _handleQrExpired();
          break;
      }
    } catch (e, stackTrace) {
      log('检查二维码状态失败: $e', error: e, stackTrace: stackTrace);
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
    _stopPolling();
    log('登录成功，URL: $url');
    await SecureStorageService.saveTokenFromUrl(url);
    await SecureStorageService.getBuvid();
    await SecureStorageService.getWbi();

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
