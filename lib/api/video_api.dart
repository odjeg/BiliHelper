import 'package:bilihelper/common/network/clients/bili_x_client.dart';
import 'package:dio/dio.dart';

class VideoApi {
  /// 获取视频详情
  /// [bvid] 视频BV
  static Future<Response<dynamic>> getVideoDetail({
    required String bvid,
    CancelToken? cancelToken,
  }) async {
    return await BiliXClient.instance.get(
      '/web-interface/view',
      queryParameters: {'bvid': bvid},
      needWbi: true,
      cancelToken: cancelToken,
    );
  }
}
