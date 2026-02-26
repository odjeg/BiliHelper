// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:math' as math;
import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:bilibilihelper/utils/cookie_generator.dart';
import 'package:bilibilihelper/utils/wbi_generator.dart';
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class BiliXApi {
  late Dio _dio;

  // 异步初始化Dio（核心修改：异步获取Cookie和真实UA）
  Future<void> initDio() async {
    // 4. 初始化Dio配置
    _dio = Dio();
    _dio.options
      ..baseUrl = 'https://api.bilibili.com/x'
      ..connectTimeout = const Duration(seconds: 5)
      ..receiveTimeout = const Duration(seconds: 5)
      ..sendTimeout = const Duration(seconds: 5)
      ..responseType = ResponseType.plain;
    //添加拦截器
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          //developer.log('onRequest: ${options.path}');
          // 在发送请求之前做些什么
          return handler.next(options); // 继续发送请求
          // 可以在options中添加一些公共参数，如token等
          // 例如：添加token到请求头
          // options.headers['Authorization'] = 'Bearer $token';
        },
        onResponse: (response, handler) {
          try {
            response.data = json.decode(response.data as String);
            //log(response.headers['content-encoding'].toString());
            handler.next(response);
          } catch (e) {
            developer.log('响应解析失败：$e');
            // 构造具体的异常信息，方便排查
            handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: '响应解析异常：$e',
                response: response, // 携带原响应，方便排查
                type: DioExceptionType.badResponse,
              ),
            );
          }
        },
        onError: (DioException e, handler) {
          developer.log('onError: ${e.message}');
          // 当请求发生错误时做些什么
          return handler.reject(e); // 继续处理错误
        },
      ),
    );
  }

  //get
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    String userAgent =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0';
    // 2. 添加Cookie到请求头
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(
        headers: {
          'User-Agent': userAgent,
          'Cookie': await CookieGenerator().genCookie(),
        },
      ),
    );
  }

  Future<Response<dynamic>> repostDynamic({
    required Map<String, dynamic> data,
  }) async {
    var response = await _dio.post(
      '/dynamic/feed/create/dyn',
      queryParameters: await WbiGenerator().genWbi(
        params: {
          'platform': 'web',
          'csrf': await SecureStorageService.getToken('bili_jct'),
        },
      ),
      data: {
        'dyn_req': {
          'content': {
            'contents': [
              {
                'raw_text': data['raw_text'],
                'type': data['type'],
                'biz_id': "",
              },
            ],
          },
          'scene': data['scene'],
          'attach_card': null,
          'upload_id':
              "${await SecureStorageService.getToken('DedeUserID')}_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(8999) + 1000}",
          'meta': {
            'app_meta': {'from': 'create.dynamic.web', 'mobi_app': 'web'},
          },
          'option': {'aigc': 2},
        },
        'web_repost_src': {'dyn_id_str': data['dyn_id_str']},
      },
      options: Options(
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0',
          'Cookie': await CookieGenerator().genCookie(),
        },
      ),
    );
    return response;
  }

  Future<Response<dynamic>> userModify({
    required int fid,
    required int act, //1关注，2取消关注
  }) async {
    var response = await _dio.post(
      '/relation/modify',
      data: {
        'fid': fid,
        'act': act,
        'csrf': await SecureStorageService.getToken('bili_jct'),
      },
      options: Options(
        headers: {
          'cookie': await CookieGenerator().genCookie(),
          'content-type': 'application/x-www-form-urlencoded',
          'origin': 'https://space.bilibili.com',
          'referer': 'https://space.bilibili.com/$fid?',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0',
        },
      ),
    );
    return response;
  }

  Future<Response<dynamic>> reserveLottery({
    //预约抽奖
    required String dynamic_id_str,
    required int reserve_id,
  }) async {
    var response = await _dio.post(
      '/dynamic/feed/reserve/click',
      queryParameters: {
        'csrf': await SecureStorageService.getToken('bili_jct'),
      },
      data: {
        'cur_btn_status': 1,
        'dynamic_id_str': dynamic_id_str,
        'reserve_id': reserve_id,
      },
      options: Options(
        headers: {
          'cookie': await CookieGenerator().genCookie(),
          'content-type': 'application/json',
          'origin': 'https://space.bilibili.com',
          'referer':
              'https://www.bilibili.com/opus/$dynamic_id_str?spm_id_from=333.1387.0.0&spm_id_from=333.1369.0.0',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0',
        },
      ),
    );
    return response;
  }

  Future<Response<dynamic>> userThumb({
    required String dynamic_id_str,
    required int up, //1点赞，2取消点赞
  }) async {
    var response = await _dio.post(
      '/dynamic/feed/dyn/thumb',
      queryParameters: {
        'csrf': await SecureStorageService.getToken('bili_jct'),
      },
      //{"dyn_id_str":"1169139614670127109","up":1,"spmid":"333.1369.0.0","from_spmid":["333.1387.0.0","333.1369.0.0"]}
      data: {
        'dyn_id_str': dynamic_id_str,
        'up': up,
        'spmid': '333.1369.0.0',
        'from_spmid': ['333.1387.0.0', '333.1369.0.0'],
      },
      options: Options(
        headers: {
          'cookie': await CookieGenerator().genCookie(),
          'content-type': 'application/json',
          'origin': 'https://space.bilibili.com',
          'referer':
              'https://www.bilibili.com/opus/$dynamic_id_str?spm_id_from=333.1387.0.0&spm_id_from=333.1369.0.0',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0',
        },
      ),
    );
    return response;
  }

  Future<Response<dynamic>> userReplyAdd({
    required String oid,
    required String message,
    required int type,
  }) async {
    var response = await _dio.post(
      '/v2/reply/add',
      queryParameters: await WbiGenerator().genWbi(params: {}),
      data: {
        'plat': 1,
        'oid': oid,
        'type': type,
        'message': message,
        'at_name_to_mid': {},
        'gaia_source': 'main_web',
        'csrf': await SecureStorageService.getToken('bili_jct'),
        'statistics': {'appId': 100, 'platform': 5},
      },
      options: Options(
        headers: {
          'cookie': await CookieGenerator().genCookie(),
          'content-type': 'application/x-www-form-urlencoded',
          'origin': 'https://space.bilibili.com',
          'referer':
              'https://www.bilibili.com/opus/$oid?spm_id_from=333.1387.0.0&spm_id_from=333.1369.0.0',
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36 Edg/145.0.0.0',
        },
      ),
    );
    return response;
  }
}

BiliXApi api = BiliXApi();
