import 'package:bilihelper/common/network/clients/passport_client.dart';
import 'package:dio/dio.dart';

class PassportApi {
  static Future<Response<dynamic>> qrcodeGenerate({
    CancelToken? cancelToken,
  }) async {
    return PassportXClient.instance.get(
      '/x/passport-login/web/qrcode/generate',
      cancelToken: cancelToken,
    );
  }

  static Future<Response<dynamic>> qrcodePoll(
    String qrcodeKey, {
    CancelToken? cancelToken,
  }) async {
    return PassportXClient.instance.get(
      '/x/passport-login/web/qrcode/poll',
      queryParameters: {'qrcode_key': qrcodeKey},
      cancelToken: cancelToken,
    );
  }

  ///用来处理302重定向获取token
  static Future<Response<dynamic>> passportRequest(
    String url, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final opt = Options(
      followRedirects: false,
      maxRedirects: 10,
      validateStatus: (status) => status == 200 || status == 302,
    );
    return PassportXClient.instance.get(
      url,
      queryParameters: queryParameters,
      options: opt,
    );
  }
}
