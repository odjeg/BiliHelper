// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:bilihelper/common/services/bili_x_dio_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // 从 url 保存 token
  static Future<void> saveTokenFromUrl(String url, {String? type}) async {
    //使用url解析获取token
    final token = Uri.parse(url).queryParameters;
    //保存token'DedeUserID', value: token['DedeUserID'] ?? '');
    await secureStorage.write(
      key: 'DedeUserID',
      value: token['DedeUserID'] ?? '',
    );
    await secureStorage.write(
      key: 'DedeUserID__ckMd5',
      value: token['DedeUserID__ckMd5'] ?? '',
    );
    await secureStorage.write(key: 'Expires', value: token['Expires'] ?? '');
    await secureStorage.write(key: 'SESSDATA', value: token['SESSDATA'] ?? '');
    await secureStorage.write(key: 'bili_jct', value: token['bili_jct'] ?? '');
    await secureStorage.write(key: 'gourl', value: token['gourl'] ?? '');
    await secureStorage.write(
      key: 'first_domain',
      value: token['first_domain'] ?? '',
    );
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
