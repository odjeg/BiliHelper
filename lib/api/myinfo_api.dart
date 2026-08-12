import 'package:bilihelper/common/network/clients/bili_x_client.dart';
import 'package:dio/dio.dart';

class MyInfoApi {
  static Future<Response<dynamic>> getMyInfo() async {
    return BiliXClient.instance.get(
      '/space/v2/myinfo',
      queryParameters: {'web_location': '333.1387'},
    );
  }

  static Future<Response<dynamic>> getMyFollowing({
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return BiliXClient.instance.get(
      '/relation/followings',
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  static Future<Response<dynamic>> getMyDynamic({
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return BiliXClient.instance.get(
      '/polymer/web-dynamic/v1/feed/space',
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      needWbi: true,
    );
  }
}
