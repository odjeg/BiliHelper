// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:bilihelper/common/services/bili_x_dio_service.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // 从 url 保存 token
  static Future<void> saveTokenFromUrl(String url, {String? type}) async {
    log('保存token，URL: $url');
    var resp = await BiliXDioService.passportRequest(url);
    debugPrint('statusCode=${resp.statusCode}');
    debugPrint('isRedirect=${resp.isRedirect}');
    debugPrint('redirects=${resp.redirects}');
    // 打印最终跳转的uri，看是不是跳到www.bilibili.com
    debugPrint('最终跳转URI: ${resp.requestOptions.uri}');
    // 打印最终响应头，看有没有Set‑Cookie
    debugPrint('最终响应头: ${resp.headers.map}');
    final List<Cookie> cookies = await BiliXDioService.cookieJar.loadForRequest(
      Uri.parse("https://www.bilibili.com"),
    );
    debugPrint('cookies: $cookies');
    //保存token'DedeUserID', value: token['DedeUserID'] ?? '');
    for (var cookie in cookies) {
      await secureStorage.write(key: cookie.name, value: cookie.value);
      log('保存cookie: ${cookie.name}=${cookie.value}');
    }
  }

  static Future<void> getBuvid() async {
    var respnse = await BiliXDioService.get('/frontend/finger/spi');
    //使用try catch处理异常
    try {
      if (respnse.statusCode == 200 && respnse.data['code'] == 0) {
        await secureStorage.write(
          key: 'buvid3',
          value: respnse.data['data']['b_3'],
        );
        await secureStorage.write(
          key: 'buvid4',
          value: respnse.data['data']['b_4'],
        );
      } else {
        throw Exception(
          'refreshBuvid error: ${respnse.statusCode} ${respnse.data}',
        );
      }
    } catch (e) {
      log('获取buvid失败: $e', error: e);
    }
  }

  static Future<void> getWbi() async {
    var respnse = await BiliXDioService.get('/web-interface/nav');
    //使用try catch处理异常
    try {
      if (respnse.statusCode == 200 && respnse.data['code'] == 0) {
        await secureStorage.write(
          key: 'imgKey',
          value: respnse.data['data']['wbi_img']['img_url']
              .split('/')
              .last
              .split('.')
              .first,
        );
        await secureStorage.write(
          key: 'subKey',
          value: respnse.data['data']['wbi_img']['sub_url']
              .split('/')
              .last
              .split('.')
              .first,
        );
      } else {
        throw Exception(
          'refreshWbi error: ${respnse.statusCode} ${respnse.data}',
        );
      }
    } catch (e) {
      log('获取wbi失败: $e', error: e);
    }
  }

  // 读取 token
  static Future<String?> getToken(String key) async {
    return await secureStorage.read(key: key);
  }

  // 清空
  static Future<void> deleteAll() async {
    await secureStorage.deleteAll();
  }
}
