import 'package:bilihelper/common/network/clients/bili_x_client.dart';
import 'package:dio/dio.dart';

class UserModifyApi {
  /// 用户关注/取消关注
  /// [fid] 关注/取消关注的用户mid
  /// [act] 关注/取消关注 1:关注 2:取消关注
  static Future<Response<dynamic>> userModify({
    required int fid,
    required int act,
    CancelToken? cancelToken,
  }) async {
    return await BiliXClient.instance.post(
      '/relation/modify',
      data: {'fid': fid, 'act': act},
      options: Options(
        headers: {
          'content-type': 'application/x-www-form-urlencoded',
          'origin': 'https://space.bilibili.com',
          'referer': 'https://space.bilibili.com/$fid?',
        },
      ),
      cancelToken: cancelToken,
    );
  }
}
