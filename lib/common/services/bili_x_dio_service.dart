import 'dart:convert';
import 'dart:developer';

import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:bilihelper/common/utils/cookie_generator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:random_user_agents/random_user_agents.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

class BiliXDioService {
  BiliXDioService._internal();
  static final Dio _dio = Dio();
  static Dio get instance => _dio;
  static final _cookieJar = PersistCookieJar(persistSession: true);
  static CookieJar get cookieJar => _cookieJar;

  // 异步初始化Dio（核心修改：异步获取Cookie和真实UA）
  static Future<void> init() async {
    log('初始化Dio');
    // 1. 生成随机UA
    String userAgent = RandomUserAgents((value) {
      return value.contains("Chrome") &&
          value.contains("Safari") &&
          value.contains("Edg");
    }).getUserAgent();
    log('随机UA: $userAgent');

    // 4. 初始化Dio配置
    _dio.options
      ..baseUrl = 'https://api.bilibili.com/x'
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 10)
      ..sendTimeout = const Duration(seconds: 10)
      ..responseType = ResponseType.plain
      ..headers['User-Agent'] = userAgent;
    //添加拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final contentType = response.headers['content-type']?.first ?? '';
          final body = response.data as String?;

          final bool isJson = contentType.toLowerCase().contains(
            'application/json',
          );
          final bool canParse = body != null && body.isNotEmpty && isJson;
          if (canParse) {
            try {
              response.data = json.decode(body);
            } catch (e) {
              debugPrint("JSON解析失败 $e");
            }
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          log('Dio请求错误: $e', error: e);
          return handler.reject(e); // 继续处理错误
        },
      ),
    );
    _dio.interceptors.add(CookieManager(_cookieJar));
    log('Dio初始化完成');
  }

  //get
  static Future<Response<dynamic>> get(
    String path, {
    dynamic queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(headers: {'Cookie': await CookieGenerator.genCookie()}),
      cancelToken: cancelToken,
    );
    return response;
  }

  static Future<Response<dynamic>> passportRequest(
    String url, {
    String method = 'GET',
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Options? options,
  }) async {
    final opt = Options(
      method: method,
      followRedirects: true,
      maxRedirects: 10,
    );
    return _dio.request<dynamic>(
      url,
      queryParameters: queryParameters,
      data: data,
      options: opt,
    );
  }

  //删除动态
  static Future<Response<dynamic>> removeDynamic({
    required String dynamicIdStr,
    required int dynType, //1删除普通动态，2删除转发动态，3删除点赞动态，4删除转发动态
    CancelToken? cancelToken,
  }) async {
    String? mid = await SecureStorageService.getToken('DedeUserID');
    var response = await _dio.post(
      '/dynamic/feed/operate/remove',
      queryParameters: {
        'platform': 'web',
        'csrf': await SecureStorageService.getToken('bili_jct'),
      },
      data: {
        'dyn_id_str': dynamicIdStr,
        'dyn_type': dynType,
        'rid_str': dynamicIdStr,
      },
      options: Options(
        headers: {
          'cookie': await CookieGenerator.genCookie(),
          'content-type': 'application/json',
          'origin': 'https://space.bilibili.com',
          'referer': 'https://space.bilibili.com/${mid!}/dynamic',
        },
      ),
      cancelToken: cancelToken,
    );
    return response;
  }
}
