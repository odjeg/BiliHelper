// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:bilibilihelper/pages/home/home_page.dart';
import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:dio/dio.dart' as Dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';

import 'package:qr_flutter/qr_flutter.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  RxString _url = ''.obs;
  String? _qrcode_key;
  Timer? _timer;
  RxString message = ''.obs;
  // 新增：标记是否正在请求，避免叠加
  bool _isRequesting = false;

  Future<void> _fetchQrData() async {
    try {
      Dio.Response response = await Dio.Dio().get(
        'https://passport.bilibili.com/x/passport-login/web/qrcode/generate',
        // 新增：超时时间，避免卡住
        options: Dio.Options(receiveTimeout: Duration(seconds: 5)),
      );
      if (response.data['code'] == 0) {
        // 校验接口返回成功
        _url.value = response.data['data']['url'];
        _qrcode_key = response.data['data']['qrcode_key'];
        message.value = '请扫描二维码登录';
      } else {
        message.value = '获取二维码失败：${response.data['message']}';
      }
    } catch (e) {
      log('获取二维码异常：$e');
      message.value = '网络异常，无法获取二维码';
      // 延迟重试
      Timer(Duration(seconds: 3), _fetchQrData);
    }
  }

  Future<dynamic> _checkQrStatus() async {
    // 避免空值请求 + 重复请求
    if (_qrcode_key == null || _isRequesting) return null;
    _isRequesting = true;

    try {
      Dio.Response response = await Dio.Dio().get(
        'https://passport.bilibili.com/x/passport-login/web/qrcode/poll',
        queryParameters: {'qrcode_key': _qrcode_key},
        options: Dio.Options(receiveTimeout: Duration(seconds: 5)),
      );
      return response.data;
    } catch (e) {
      log('轮询二维码状态异常：$e');
      message.value = '网络异常，正在重试...';
      return null;
    } finally {
      _isRequesting = false; // 释放请求锁
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _checkQrStatus().then((value) {
        if (value == null) return; // 异常时直接返回

        // ✅ 修复：响应式变量必须用 .value 赋值
        message.value = (value['data']['message'] ?? '') + '${DateTime.now()}';

        if (value['data']['code'] == 0) {
          _timer?.cancel();
          SecureStorageService.saveTokenFromUrl(value['data']['url']).then((_) {
            SecureStorageService.refreshBuvid();
            SecureStorageService.refreshWbi();
            Get.offAll(() => HomePage());
          });
          log(value['data']['url']);
        } else if (value['data']['code'] == 86038) {
          log('二维码过期');
          _handleQrExpired();
        }
      });
    });
  }

  void _handleQrExpired() {
    log('二维码已失效，重新获取...');
    _timer?.cancel();
    message.value = '二维码已失效，正在重新获取...';
    _url.value = '';
    _qrcode_key = null;
    _fetchQrData().then((_) {
      // ✅ 修复：等重新获取二维码完成后，再启动定时器
      _startTimer();
    });
  }

  @override
  void initState() {
    super.initState();
    // ✅ 修复：等获取二维码完成后，再启动定时器
    _fetchQrData().then((_) {
      _startTimer();
    });
  }

  @override
  void dispose() {
    log('time_dispose');
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 修复：移除嵌套的 GetMaterialApp，只返回页面内容
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => QrImageView(
                data: _url.value.isNotEmpty ? _url.value : 'Loading...',
                version: QrVersions.auto,
                size: 400.0,
                // 新增：加载中显示占位，避免空数据导致二维码异常
                backgroundColor: Colors.white,
              ),
            ),
            SizedBox(height: 20), // 新增：间距，避免文字重叠
            Obx(
              () => Text(
                message.value.isNotEmpty ? message.value : '正在生成二维码...',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
