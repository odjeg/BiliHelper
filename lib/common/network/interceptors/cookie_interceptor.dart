import 'package:dio/dio.dart';
import 'package:bilihelper/common/utils/cookie_generator.dart';

/// Cookie自动注入拦截器
/// 挂载位置：业务客户端（x域、passport域等需要登录态的域名）
class CookieInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final String cookie = await CookieGenerator.genCookie();
      if (cookie.isNotEmpty) {
        options.headers['Cookie'] = cookie;
      }
    } catch (e) {
      // Cookie生成失败不阻断请求，由业务层判断登录态
    }

    return handler.next(options);
  }
}
