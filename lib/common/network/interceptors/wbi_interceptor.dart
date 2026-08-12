import 'package:dio/dio.dart';
import 'package:bilihelper/common/utils/wbi_generator.dart';

/// WBI 签名拦截器
/// 挂载位置：仅 bili_x_client
/// 使用方式：请求时在 extra 中添加 `needWbi: true` 即可自动签名
class WbiInterceptor extends Interceptor {
  static const String _keyNeedWbi = 'needWbi';

  /// 便捷方法：生成带标记的extra
  static Map<String, dynamic> needWbi() => {_keyNeedWbi: true};

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bool needWbi = options.extra[_keyNeedWbi] ?? false;
    if (!needWbi) {
      return handler.next(options);
    }

    try {
      final Map<String, dynamic> rawParams = Map.from(options.queryParameters);

      // ✅ 核心修复：按键名字典升序排序，消除Map插入顺序对签名的影响
      final sortedEntries = rawParams.entries.toList();
      sortedEntries.sort((a, b) => a.key.compareTo(b.key));
      final Map<String, dynamic> sortedParams = Map.fromEntries(sortedEntries);

      final Map<String, dynamic> signedParams = await WbiGenerator().genWbi(
        params: sortedParams,
      );
      options.queryParameters = signedParams;
    } catch (e) {
      // 签名失败抛出，由上层错误拦截器统一处理
      return handler.reject(
        DioException(requestOptions: options, error: 'WBI签名失败: $e'),
      );
    }
    return handler.next(options);
  }
}
