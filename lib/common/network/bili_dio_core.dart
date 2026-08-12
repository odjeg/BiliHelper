import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:random_user_agents/random_user_agents.dart';

/// B站网络层核心
/// 职责：全局Dio单例、Cookie持久化、通用拦截器、基础配置
/// 规则：不设置baseUrl、不包含业务接口、不依赖业务工具类
class BiliDioCore {
  // 单例实现
  BiliDioCore._internal();
  static final BiliDioCore instance = BiliDioCore._internal();

  /// 基础Dio实例（无业务域名，供各业务客户端 clone 后使用）
  late final Dio _baseDio;
  Dio get baseDio => _baseDio;

  /// 全局Cookie容器，所有域名共享Cookie状态
  late final CookieJar _cookieJar;
  CookieJar get cookieJar => _cookieJar;

  /// 初始化核心网络能力，App启动时调用一次
  void init() {
    log('初始化 BiliDioCore');

    // 1. 初始化Cookie容器
    _cookieJar = CookieJar();

    // 2. 生成符合B站Web端特征的随机UA
    final String userAgent = RandomUserAgents((value) {
      return value.contains("Chrome") &&
          value.contains("Safari") &&
          value.contains("Edg");
    }).getUserAgent();

    // 3. 配置基础Dio参数
    _baseDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        responseType: ResponseType.plain,
        headers: {'User-Agent': userAgent},
      ),
    );
    // 4. 注册全局通用拦截器
    _registerGlobalInterceptors();

    log('BiliDioCore 初始化完成');
  }

  /// 注册所有域名通用的拦截器
  void _registerGlobalInterceptors() {
    // 通用响应拦截器：统一JSON解析、错误日志
    _baseDio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          final String contentType =
              response.headers['content-type']?.first ?? '';
          final String? body = response.data as String?;

          final bool isJson = contentType.toLowerCase().contains(
            'application/json',
          );
          final bool canParse = body != null && body.isNotEmpty && isJson;

          if (canParse) {
            try {
              response.data = json.decode(body);
            } catch (e) {
              log('全局JSON解析失败: $e');
            }
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          log('Dio全局请求错误: $error', error: error);
          return handler.reject(error);
        },
      ),
    );

    // Cookie自动管理拦截器
    _baseDio.interceptors.add(CookieManager(_cookieJar));
  }
}
