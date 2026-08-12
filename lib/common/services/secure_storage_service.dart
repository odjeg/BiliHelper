// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:bilihelper/api/passport_api.dart';
import 'package:bilihelper/common/network/clients/bili_x_client.dart';
import 'package:bilihelper/common/network/clients/passport_x_client.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // 从 url 保存 token
  static Future<void> saveTokenFromUrl(String url, {String? type}) async {
    await PassportApi.passportRequest(url);
    log('保存token，URL: $url');
    final List<Cookie> cookies = await PassportXClient.instance.cookieJar
        .loadForRequest(Uri.parse("https://www.bilibili.com"));
    debugPrint('cookies: $cookies');
    //保存token'DedeUserID', value: token['DedeUserID'] ?? '');
    for (var cookie in cookies) {
      await secureStorage.write(key: cookie.name, value: cookie.value);
      log('保存cookie: ${cookie.name}=${cookie.value}');
    }
  }

  static Future<void> getBuvid() async {
    var respnse = await BiliXClient.instance.get('/frontend/finger/spi');
    await secureStorage.write(key: 'buvid3', value: respnse.data['b_3']);
    await secureStorage.write(key: 'buvid4', value: respnse.data['b_4']);
  }

  static Future<void> getWbi() async {
    var respnse = await BiliXClient.instance.get('/web-interface/nav');
    await secureStorage.write(
      key: 'imgKey',
      value: respnse.data['wbi_img']['img_url']
          .split('/')
          .last
          .split('.')
          .first,
    );
    await secureStorage.write(
      key: 'subKey',
      value: respnse.data['wbi_img']['sub_url']
          .split('/')
          .last
          .split('.')
          .first,
    );
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
