import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:bilihelper/common/utils/cookie_generator.dart';
import 'package:bilihelper/common/utils/wbi_generator.dart';
import 'package:dio/dio.dart';
import 'package:random_user_agents/random_user_agents.dart';

class BiliXDioService {
  static final Dio _dio = Dio();
  static Dio get instance => _dio;

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
          try {
            response.data = json.decode(response.data as String);
            handler.next(response);
          } catch (e) {
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
          log('Dio请求错误: $e', error: e);
          return handler.reject(e); // 继续处理错误
        },
      ),
    );
    log('Dio初始化完成');
  }

  // 转发动态
  static Future<Response<dynamic>> repostDynamic({
    required Map<String, dynamic> data,
    CancelToken? cancelToken,
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
      options: Options(headers: {'Cookie': await CookieGenerator.genCookie()}),
      cancelToken: cancelToken,
    );
    return response;
  }

  // 关注/取消关注
  static Future<Response<dynamic>> userModify({
    required int fid,
    required int act, //1关注，2取消关注
    CancelToken? cancelToken,
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
          'cookie': await CookieGenerator.genCookie(),
          'content-type': 'application/x-www-form-urlencoded',
          'origin': 'https://space.bilibili.com',
          'referer': 'https://space.bilibili.com/$fid?',
        },
      ),
      cancelToken: cancelToken,
    );
    return response;
  }

  // 预约抽奖
  static Future<Response<dynamic>> reserveLottery({
    required String dynamicIdStr,
    required int reserveId,
    CancelToken? cancelToken,
  }) async {
    var response = await _dio.post(
      '/dynamic/feed/reserve/click',
      queryParameters: {
        'csrf': await SecureStorageService.getToken('bili_jct'),
      },
      data: {
        'cur_btn_status': 1,
        'dynamic_id_str': dynamicIdStr,
        'reserve_id': reserveId,
      },
      options: Options(
        headers: {
          'cookie': await CookieGenerator.genCookie(),
          'content-type': 'application/json',
          'origin': 'https://space.bilibili.com',
          'referer':
              'https://www.bilibili.com/opus/$dynamicIdStr?spm_id_from=333.1387.0.0&spm_id_from=333.1369.0.0',
        },
      ),
      cancelToken: cancelToken,
    );
    return response;
  }

  // 点赞/取消点赞
  static Future<Response<dynamic>> userThumb({
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
          'cookie': await CookieGenerator.genCookie(),
          'content-type': 'application/json',
          'origin': 'https://space.bilibili.com',
          'referer':
              'https://www.bilibili.com/opus/$dynamic_id_str?spm_id_from=333.1387.0.0&spm_id_from=333.1369.0.0',
        },
      ),
    );
    return response;
  }

  // 评论/回复评论
  static Future<Response<dynamic>> userReplyAdd({
    required String oid,
    required String message,
    required int type,
    CancelToken? cancelToken,
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
          'cookie': await CookieGenerator.genCookie(),
          'content-type': 'application/x-www-form-urlencoded',
          'origin': 'https://space.bilibili.com',
          'referer':
              'https://www.bilibili.com/opus/$oid?spm_id_from=333.1387.0.0&spm_id_from=333.1369.0.0',
        },
      ),
      cancelToken: cancelToken,
    );
    return response;
  }

  //get
  static Future<Response<dynamic>> get(
    String path, {
    dynamic queryParameters,
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

  //删除动态
  static Future<Response<dynamic>> removeDynamic({
    required String dynamic_id_str,
    required int dyn_type, //1删除普通动态，2删除转发动态，3删除点赞动态，44删除转发动态
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
        'dyn_id_str': dynamic_id_str,
        'dyn_type': dyn_type,
        'rid_str': dynamic_id_str,
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
