import 'package:bilihelper/common/network/bili_dio_core.dart';
import 'package:bilihelper/common/network/interceptors/response_interceptor.dart';
import 'package:dio/dio.dart';

/// B站 vc 域 API 客户端
/// 对应域名：https://api.vc.bilibili.com
/// 职责：vc 域 API 请求的封装、拦截器挂载、通用请求方法封装

class BiliVcClient {
  BiliVcClient._internal();
  static final BiliVcClient instance = BiliVcClient._internal();
  late final Dio _dio;

  void init() {
    _dio = BiliDioCore.instance.baseDio.clone();
    _dio.options = _dio.options.copyWith(
      baseUrl: 'https://api.vc.bilibili.com',
    );
    _dio.interceptors.addAll([ResponseInterceptor()]);
  }

  Future<Response<dynamic>> get(
    String path, {
    required Map<String, dynamic>? queryParameters,
    required CancelToken? cancelToken,
  }) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }
}
