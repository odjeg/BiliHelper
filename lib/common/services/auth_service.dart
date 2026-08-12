import 'dart:developer';

import 'package:bilihelper/common/network/clients/passport_client.dart';
import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:flutter/material.dart';

class AuthService {
  static Future<bool> checkNeedLogin() async {
    log('开始检查是否需要登录');
    bool needLogin = true;
    try {
      var csrf = await SecureStorageService.getToken('bili_jct');
      debugPrint('csrf: $csrf');
      if (csrf == null || csrf.isEmpty) {
        needLogin = true;
        return needLogin;
      }

      var response = await PassportXClient.instance.get(
        '/x/passport-login/web/cookie/info',
        queryParameters: {'csrf': csrf},
      );
      debugPrint('response: ${response.data}');
      if (response.data['refresh'] == true) {
        needLogin = true;
      } else {
        needLogin = false;
      }
    } catch (e) {
      log('检查是否需要登录失败: $e', error: e);
      needLogin = true;
    } finally {
      log('检查是否需要登录完成 needLogin: $needLogin');
    }
    return needLogin;
  }
}
