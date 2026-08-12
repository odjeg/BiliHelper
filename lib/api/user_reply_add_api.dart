import 'package:bilihelper/common/network/clients/bili_x_client.dart';
import 'package:dio/dio.dart';

class UserReplyAddApi {
  /// 评论/回复评论
  /// [oid] 视频oid
  /// [message] 评论内容
  /// [type] 评论类型 1:评论 2:回复评论
  static Future<Response<dynamic>> userReplyAdd({
    required String oid,
    required String message,
    required int type,
    CancelToken? cancelToken,
  }) async {
    var response = await BiliXClient.instance.post(
      '/v2/reply/add',
      data: {
        'plat': 1,
        'oid': oid,
        'type': type,
        'message': message,
        'at_name_to_mid': {},
        'gaia_source': 'main_web',
        'statistics': {'appId': 100, 'platform': 5},
      },
      needWbi: true,
      options: Options(
        headers: {
          'content-type': 'application/x-www-form-urlencoded',
          'origin': 'https://space.bilibili.com',
          'referer':
              'https://www.bilibili.com/opus/$oid?spm_id_from=333.1387.0.0&spm_id_from=333.1369.0.0',
        },
      ),
      cancelToken: cancelToken,
    );
    return response;
  }
}
