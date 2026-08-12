import 'package:dio/dio.dart';
import 'package:bilihelper/common/services/secure_storage_service.dart';

/// CSRF 自动注入拦截器
/// 挂载位置：仅 bili_x_client
/// 注入位置：通过 extra 的 csrfLocation 控制，可选 'query' / 'body'，默认 'query'
class CsrfInterceptor extends Interceptor {
  static const String _keyLocation = 'csrfLocation';
  static const String _csrfKey = 'csrf';

  /// 便捷配置：注入到 query
  static Map<String, dynamic> injectQuery() => {_keyLocation: 'query'};

  /// 便捷配置：注入到 body
  static Map<String, dynamic> injectBody() => {_keyLocation: 'body'};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 仅 POST / PUT 等写入类请求注入
    final method = options.method.toUpperCase();
    if (method != 'POST' && method != 'PUT') {
      return handler.next(options);
    }

    try {
      final String? csrf = await SecureStorageService.getToken('bili_jct');
      if (csrf == null || csrf.isEmpty) {
        return handler.next(options);
      }

      final String location = options.extra[_keyLocation] ?? 'query';
      if (location == 'query') {
        options.queryParameters[_csrfKey] = csrf;
      } else if (location == 'body') {
        // 兼容表单和JSON两种请求体
        if (options.data is Map) {
          options.data[_csrfKey] = csrf;
        }
      }
    } catch (e) {
      // 读取失败不阻断，由业务层校验
    }
    return handler.next(options);
  }
}
