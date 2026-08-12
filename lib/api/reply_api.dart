import 'package:bilihelper/common/network/clients/bili_x_client.dart';
import 'package:dio/dio.dart';

class ReplyApi {
  /// 获取视频或者动态的评论列表
  /// [oid] 视频或动态的oid
  /// [type] 1为视频，11为动态
  /// [mode] 评论获取的排序方式，3为按热度排序，2为按时间排序
  static Future<Response> getReplyList({
    required String oid,
    required int type,
    required int mode,
    required String paginationStr,
    CancelToken? cancelToken,
  }) async {
    return await BiliXClient.instance.get(
      '/v2/reply/wbi/main',
      queryParameters: {
        'oid': oid,
        'type': type,
        'mode': mode,
        'pagination_str': paginationStr,
        'plat': 1,
        'web_location': 1315875,
      },
      needWbi: true,
      cancelToken: cancelToken,
    );
  }
}
