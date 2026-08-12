import 'package:bilihelper/common/network/clients/bili_x_client.dart';
import 'package:dio/dio.dart';

class UserThumbApi {
  /// 点赞/取消点赞
  /// [dynamicIdStr] 动态id
  /// [up] 点赞/取消点赞 1:点赞 2:取消点赞
  static Future<Response<dynamic>> userThumb({
    required String dynamicIdStr,
    required int up,
  }) async {
    var response = await BiliXClient.instance.post(
      '/dynamic/feed/dyn/thumb',
      data: {
        'dyn_id_str': dynamicIdStr,
        'up': up,
        'spmid': '333.1369.0.0',
        'from_spmid': ['333.1387.0.0', '333.1369.0.0'],
      },
      options: Options(
        headers: {
          'content-type': 'application/json',
          'origin': 'https://space.bilibili.com',
          'referer':
              'https://www.bilibili.com/opus/$dynamicIdStr?spm_id_from=333.1387.0.0&spm_id_from=333.1369.0.0',
        },
      ),
    );
    return response;
  }
}
