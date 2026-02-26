// ignore_for_file: non_constant_identifier_names

import 'package:bilibilihelper/utils/bili_x_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer' as developer;

class SecureStorageService {
  static FlutterSecureStorage secureStorage = FlutterSecureStorage();

  //从url保存token
  static Future<void> saveTokenFromUrl(String url, {String? type}) async {
    //使用url解析获取token
    final token = Uri.parse(url).queryParameters;
    //保存token
    await saveToken(
      token['DedeUserID'] ?? '',
      token['DedeUserID__ckMd5'] ?? '',
      token['Expires'] ?? '',
      token['SESSDATA'] ?? '',
      token['bili_jct'] ?? '',
      token['gourl'] ?? '',
      token['first_domain'] ?? '',
    );
    developer.log('saveTokenFromUrl: $token');
  }

  //保存token
  static Future<void> saveToken(
    String DedeUserID,
    String DedeUserID__ckMd5,
    String Expires,
    String SESSDATA,
    String bili_jct,
    String gourl,
    String first_domain,
  ) async {
    await secureStorage.write(key: 'DedeUserID', value: DedeUserID);
    await secureStorage.write(
      key: 'DedeUserID__ckMd5',
      value: DedeUserID__ckMd5,
    );
    await secureStorage.write(key: 'Expires', value: Expires);
    await secureStorage.write(key: 'SESSDATA', value: SESSDATA);
    await secureStorage.write(key: 'bili_jct', value: bili_jct);
    await secureStorage.write(key: 'gourl', value: gourl);
    await secureStorage.write(key: 'first_domain', value: first_domain);
  }

  //读取token
  static Future<String?> getToken(String key) async {
    return await secureStorage.read(key: key);
  }

  //清空token
  static Future<void> deleteToken() async {
    developer.log('deleteToken');
    await secureStorage.deleteAll();
  }

  static Future<void> refreshBuvid() async {
    var respnse = await api.get('/frontend/finger/spi');
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
        developer.log('refreshBuvid success: ${respnse.data}');
      } else {
        throw Exception(
          'refreshBuvid error: ${respnse.statusCode} ${respnse.data}',
        );
      }
    } catch (e) {
      developer.log('refreshBuvid error: $e');
    }
  }

  static Future<void> refreshWbi() async {
    var respnse = await api.get('/web-interface/nav');
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
      developer.log('refreshWbi error: $e');
    }
  }
}
