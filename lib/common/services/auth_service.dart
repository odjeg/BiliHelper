import 'dart:developer';

import 'package:bilihelper/common/services/bili_x_dio_service.dart';
import 'package:bilihelper/common/services/secure_storage_service.dart';

class AuthService {
  static Future<bool> checkNeedLogin() async {
    log('开始检查是否需要登录');
    bool needLogin = true;
    try {
      var csrf = await SecureStorageService.getToken('bili_jct');
      if (csrf == null || csrf.isEmpty) {
        needLogin = true;
        return needLogin;
      }

      var response = await BiliXDioService.get(
        'https://passport.bilibili.com/x/passport-login/web/cookie/info',
        queryParameters: {'csrf': csrf},
      );
      if (response.data['code'] == -101 ||
          response.data['data']['refresh'] == true) {
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
