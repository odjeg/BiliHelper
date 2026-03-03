import 'dart:math';

import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:uuid/uuid.dart';

class CookieGenerator {
  Future<String> genBLsid() async {
    String data = "";
    final random = Random();

    for (int i = 0; i < 8; i++) {
      // Dart中实现 math.ceil(16 * random.uniform(0, 1)) 的等效逻辑
      // random.nextDouble() 返回 0.0 <= x < 1.0 的随机数
      int v1 = (16 * random.nextDouble()).ceil();
      // 转换为大写十六进制字符串（去掉0x前缀）
      String v2 = v1.toRadixString(16).toUpperCase();
      data += v2;
    }

    // 确保字符串长度为8位，不足的话在左侧补0
    String result = data.padLeft(8, '0');

    // 获取当前时间戳（毫秒级）并转换为十六进制
    int e = DateTime.now().millisecondsSinceEpoch;
    String t = e.toRadixString(16).toUpperCase();

    // 拼接最终的LSID
    return "${result}_$t";
  }

  Future<String> genUuid() async {
    // 1. 生成UUID4（对应Python的uuid.uuid4()）
    final uuid = Uuid();
    String uuidSec = uuid.v4();

    // 2. 获取毫秒时间戳，取后5位（对应time.time() * 1000 % 1e5）
    int timeMs = DateTime.now().millisecondsSinceEpoch;
    String timeSec = (timeMs % 100000).toString();

    // 3. 确保是5位，不足左侧补0（对应rjust(5, "0")）
    timeSec = timeSec.padLeft(5, '0');

    // 4. 拼接最终结果
    return "$uuidSec${timeSec}infoc";
  }

  Future<String> genCookie() async {
    String? sessdata = await SecureStorageService.getToken('SESSDATA');
    String? dedeUserID = await SecureStorageService.getToken('DedeUserID');
    String? dedeUserIDMd5 = await SecureStorageService.getToken(
      'DedeUserID__ckMd5',
    );
    String? biliJct = await SecureStorageService.getToken('bili_jct');
    String? buvid3 = await SecureStorageService.getToken('buvid3');
    String? buvid4 = await SecureStorageService.getToken('buvid4');
    String? b_lsid = await genBLsid();
    String? uuid = await genUuid();

    // 3. 拼接Cookie（判空，避免null值）
    String cookie = '';
    if (sessdata != null) cookie += 'SESSDATA=$sessdata; ';
    if (dedeUserID != null) cookie += 'DedeUserID=$dedeUserID; ';
    if (dedeUserIDMd5 != null) cookie += 'DedeUserID__ckMd5=$dedeUserIDMd5; ';
    if (biliJct != null) cookie += 'bili_jct=$biliJct; ';
    if (buvid3 != null) cookie += 'buvid3=$buvid3; ';
    if (buvid4 != null) cookie += 'buvid4=$buvid4; ';
    cookie += '_uuid=$uuid; ';
    cookie += 'b_lsid=$b_lsid';
    return cookie;
  }
}
