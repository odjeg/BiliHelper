import 'package:bilihelper/common/network/bili_dio_core.dart';
import 'package:bilihelper/common/network/interceptors/cookie_interceptor.dart';
import 'package:bilihelper/common/network/interceptors/response_interceptor.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';

/// B站 x 域 API 客户端
/// 对应域名：https://passport.bilibili.com/x/passport-login
/// 职责：x 域专二维码登录的属配置、专属拦截器挂载、通用请求方法封装

class PassportXClient {
  PassportXClient._internal();
  static final PassportXClient instance = PassportXClient._internal();
  late final Dio _dio;
  CookieJar get cookieJar => BiliDioCore.instance.cookieJar;

  void init() {
    _dio = BiliDioCore.instance.baseDio.clone();

    _dio.options = _dio.options.copyWith(
      baseUrl: 'https://passport.bilibili.com',
    );
    _dio.interceptors.addAll([CookieInterceptor(), ResponseInterceptor()]);
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final Response response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return response;
  }
}
