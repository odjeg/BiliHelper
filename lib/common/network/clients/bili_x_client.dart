import 'package:dio/dio.dart';
import 'package:bilihelper/common/network/bili_dio_core.dart';
// 导入四个独立拦截器
import 'package:bilihelper/common/network/interceptors/cookie_interceptor.dart';
import 'package:bilihelper/common/network/interceptors/csrf_interceptor.dart';
import 'package:bilihelper/common/network/interceptors/wbi_interceptor.dart';
import 'package:bilihelper/common/network/interceptors/response_interceptor.dart';
import 'package:flutter/foundation.dart';

/// B站 x 域 API 客户端
/// 对应域名：https://api.bilibili.com/x
/// 职责：x 域专属配置、专属拦截器挂载、通用请求方法封装
class BiliXClient {
  BiliXClient._internal();
  static final BiliXClient instance = BiliXClient._internal();

  late final Dio _dio;

  /// 初始化 x 域客户端
  /// 必须在 BiliDioCore.init() 之后调用
  void init() {
    // 1. 从核心底座克隆，继承全局基础配置、CookieJar、通用日志能力
    debugPrint('开始初始化 BiliXClient');
    _dio = BiliDioCore.instance.baseDio.clone();

    // 2. x 域专属基础配置
    _dio.options = _dio.options.copyWith(
      baseUrl: 'https://api.bilibili.com/x',
      headers: {
        'origin': 'https://space.bilibili.com',
        'referer': 'https://space.bilibili.com/',
      },
    );
    // 3. 按执行顺序挂载 x 域专属拦截器
    // 请求阶段：按添加顺序从上到下执行
    // 响应阶段：按添加顺序从下到上执行
    _dio.interceptors.addAll([
      // 第一步：自动注入 Cookie 请求头
      CookieInterceptor(),
      // 第二步：POST 请求自动注入 csrf(bili_jct)
      CsrfInterceptor(),
      // 第三步：GET 请求自动执行 WBI 参数签名（此时 query 已包含 csrf，签名完整）
      WbiInterceptor(),
      // 第四步：响应返回时统一处理业务错误码、剥离外层包装
      ResponseInterceptor(),
    ]);
    debugPrint('初始化 BiliXClient 完成');
  }

  /// 通用 GET 请求封装
  /// [needWbi] 是否需要 WBI 签名，默认 false
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool needWbi = false,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final Options opt = options ?? Options();
    if (needWbi) {
      opt.extra = {...?opt.extra, ...WbiInterceptor.needWbi()};
    }

    final Response response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: opt,
      cancelToken: cancelToken,
    );
    return response;
  }

  /// 通用 POST 请求封装
  /// [csrfLocation] csrf 注入位置：'query' / 'body'，默认 'query'
  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    String csrfLocation = 'query',
    bool needWbi = false,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final Options opt = options ?? Options();
    // 根据参数标记 csrf 注入位置
    opt.extra = {
      ...?opt.extra,
      if (csrfLocation == 'query')
        ...CsrfInterceptor.injectQuery()
      else
        ...CsrfInterceptor.injectBody(),
    };
    if (needWbi) {
      opt.extra = {...?opt.extra, ...WbiInterceptor.needWbi()};
    }

    final Response response = await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: opt,
      cancelToken: cancelToken,
    );
    return response;
  }

  /// 原始 request 方法（特殊场景使用，支持自定义 method、完整 URL）
  Future<Response<dynamic>> request(
    String path, {
    String method = 'GET',
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final Response response = await _dio.request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options?.copyWith(method: method) ?? Options(method: method),
      cancelToken: cancelToken,
    );
    return response;
  }
}
