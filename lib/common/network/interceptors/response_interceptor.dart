import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 业务响应统一处理拦截器
/// 挂载位置：各业务客户端
/// 功能：统一判断 code、抛出业务异常、规整响应数据
class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final data = response.data;
    final skipParse =
        response.requestOptions.extra["skipResponseParse"] == true;

    // ✅ 跳过解析条件：302重定向 / 手动标记跳过 / 返回不是json Map
    if (skipParse ||
        response.statusCode == 302 ||
        data is! Map<String, dynamic>) {
      return handler.next(response);
    }

    final int code = data['code'];
    final String message = data['message'];
    if (data['data'].isEmpty) {
      debugPrint('ResponseInterceptor: data 为空，返回 message: $message');
      response.data = message;
      return handler.next(response);
    }
    // 业务成功：直接返回 data 字段，简化业务层取值
    if (code == 0) {
      response.data = data['data'];
      return handler.next(response);
    }

    // 业务失败：抛出 DioException，携带业务错误码和信息
    return handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        response: response,
        error: 'B站接口错误 [$code]: $message',
        type: DioExceptionType.badResponse,
      ),
    );
  }
}
