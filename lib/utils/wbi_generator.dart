import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:bilibilihelper/services/secure_storage_service.dart';

// 与Python完全一致的混淆表
class WbiGenerator {
  final List<int> mixinKeyEncTab = [
    46,
    47,
    18,
    2,
    53,
    8,
    23,
    32,
    15,
    50,
    10,
    31,
    58,
    3,
    45,
    35,
    27,
    43,
    5,
    49,
    33,
    9,
    42,
    19,
    29,
    28,
    14,
    39,
    12,
    38,
    41,
    13,
    37,
    48,
    7,
    16,
    24,
    55,
    40,
    61,
    26,
    17,
    0,
    1,
    60,
    51,
    30,
    4,
    22,
    25,
    54,
    21,
    56,
    59,
    6,
    63,
    57,
    62,
    11,
    36,
    20,
    34,
    44,
    52,
  ];

  /// 对 imgKey 和 subKey 进行字符顺序打乱编码（等价Python的getMixinKey）
  String getMixinKey(String orig) {
    final StringBuffer sb = StringBuffer();
    // 按混淆表顺序拼接字符
    for (final int i in mixinKeyEncTab) {
      if (i < orig.length) {
        sb.write(orig[i]);
      }
    }
    // 截取前32位
    return sb.toString().substring(0, 32);
  }

  /// 为请求参数进行WBI签名（等价Python的encWbi）
  Map<String, dynamic> encWbi({
    required Map<String, dynamic> params,
    required String imgKey,
    required String subKey,
  }) {
    // 1. 生成混淆key
    final String mixinKey = getMixinKey(imgKey + subKey);

    // 2. 添加wts字段（当前时间戳秒级）
    final int currTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
    params['wts'] = currTime.toString();

    // 3. 按key排序参数（等价Python的sorted(params.items())）
    final List<String> sortedKeys = params.keys.toList()..sort();
    final Map<String, dynamic> sortedParams = {
      for (final String key in sortedKeys) key: params[key],
    };

    // 4. 过滤value中的 "!'()*" 字符
    final Map<String, String> filteredParams = {};
    for (final entry in sortedParams.entries) {
      final String value = entry.value.toString();
      // 过滤指定字符
      final String filteredValue = value.split('').where((chr) {
        return !"!'()*".contains(chr);
      }).join();
      filteredParams[entry.key] = filteredValue;
    }

    // 5. 序列化参数（等价Python的urllib.parse.urlencode）
    final List<String> queryParts = [];
    for (final entry in filteredParams.entries) {
      // URL编码（与Python的urlencode行为一致）
      final String encodedKey = Uri.encodeComponent(entry.key);
      final String encodedValue = Uri.encodeComponent(entry.value);
      queryParts.add('$encodedKey=$encodedValue');
    }
    final String query = queryParts.join('&');

    // 6. 计算MD5签名（等价Python的md5.hexdigest()）
    final String signStr = query + mixinKey;
    final List<int> signBytes = utf8.encode(signStr);
    final String wbiSign = md5.convert(signBytes).toString();

    // 7. 添加w_rid字段并返回最终参数
    final Map<String, dynamic> resultParams = Map.from(filteredParams);
    resultParams['w_rid'] = wbiSign;

    return resultParams;
  }

  /// 主函数测试
  Future<Map<String, dynamic>> genWbi({
    required Map<String, dynamic> params,
  }) async {
    // 1. 获取最新密钥
    String? imgKey = await SecureStorageService.getToken('imgKey');
    String? subKey = await SecureStorageService.getToken('subKey');

    // 2. 生成签名参数
    final Map<String, dynamic> signedParams = encWbi(
      params: params,
      imgKey: imgKey!,
      subKey: subKey!,
    );
    // 输出结果
    return signedParams;
  }
}
/*
{'bar': '514', 'baz': '1919810', 'foo': '114', 'wts': '1702204169', 'w_rid': 'd3cbd2a2316089117134038bf4caf442'}
bar=514&baz=1919810&foo=114&wts=1702204169&w_rid=d3cbd2a2316089117134038bf4caf442
*/