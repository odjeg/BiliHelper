import 'dart:math' as math;
import 'package:dio/dio.dart';
import 'package:bilihelper/common/network/clients/bili_x_client.dart';
import 'package:bilihelper/common/services/secure_storage_service.dart';

/// 动态业务接口层
/// 对应 B站 /x/dynamic 系列接口
class DynamicApi {
  /// 转发动态
  /// [dynIdStr] 被转发的动态ID字符串
  /// [rawText] 转发附带的文案内容
  /// [type] 内容类型，默认 1（纯文本）
  /// [scene] 场景值，默认 1
  static Future<dynamic> repostDynamic({
    required String dynIdStr,
    required String rawText,
    int type = 1,
    int scene = 4,
    CancelToken? cancelToken,
  }) async {
    final String? mid = await SecureStorageService.getToken('DedeUserID');
    final String uploadId =
        "${mid}_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(8999) + 1000}";

    return BiliXClient.instance.post(
      '/dynamic/feed/create/dyn',
      queryParameters: {'platform': 'web'},
      needWbi: true,
      data: {
        'dyn_req': {
          'content': {
            'contents': [
              {'raw_text': rawText, 'type': type, 'biz_id': ""},
            ],
          },
          'scene': scene,
          'attach_card': null,
          'upload_id': uploadId,
          'meta': {
            'app_meta': {'from': 'create.dynamic.web', 'mobi_app': 'web'},
          },
          'option': {'aigc': 2},
        },
        'web_repost_src': {'dyn_id_str': dynIdStr},
      },
      cancelToken: cancelToken,
    );
  }

  /// 动态抽奖
  /// [dynamicIdStr] 动态ID字符串
  /// [reserveId] 抽奖预约活动ID
  static Future<dynamic> reserveLottery({
    required String dynamicIdStr,
    required int reserveId,
    CancelToken? cancelToken,
  }) async {
    return BiliXClient.instance.post(
      '/dynamic/feed/reserve/click',
      data: {
        'cur_btn_status': 1,
        'dynamic_id_str': dynamicIdStr,
        'reserve_id': reserveId,
      },
      options: Options(
        headers: {
          'content-type': 'application/json',
          'referer':
              'https://www.bilibili.com/opus/$dynamicIdStr?spm_id_from=333.1387.0.0&spm_id_from=333.1369.0.0',
        },
      ),
      cancelToken: cancelToken,
    );
  }

  /// 点赞/取消点赞
  /// [dynamicIdStr] 动态id
  /// [up] 点赞/取消点赞 1:点赞 2:取消点赞
  static Future<Response<dynamic>> thumbDynamic({
    required String dynamicIdStr,
    required int up,
  }) async {
    var response = await BiliXClient.instance.post(
      '/dynamic/feed/dyn/thumb',
      data: {
        'dyn_id_str': dynamicIdStr,
        'up': up,
        'spmid': '333.1369.0.0',
        'from_spmid': ['333.1387.0.0', '333.1369.0.0'],
      },
      options: Options(
        headers: {
          'content-type': 'application/json',
          'origin': 'https://space.bilibili.com',
          'referer':
              'https://www.bilibili.com/opus/$dynamicIdStr?spm_id_from=333.1387.0.0&spm_id_from=333.1369.0.0',
        },
      ),
    );
    return response;
  }

  /// 删除动态
  /// [dynamicIdStr] 动态ID字符串
  /// [dynType] 动态类型：1=普通动态，2=转发动态，3=点赞动态，4=转发动态
  static Future<dynamic> removeDynamic({
    required String dynamicIdStr,
    required int dynType,
    CancelToken? cancelToken,
  }) async {
    final String? mid = await SecureStorageService.getToken('DedeUserID');
    return BiliXClient.instance.post(
      '/dynamic/feed/operate/remove',
      queryParameters: {'platform': 'web'},
      data: {
        'dyn_id_str': dynamicIdStr,
        'dyn_type': dynType,
        'rid_str': dynamicIdStr,
      },
      options: Options(
        headers: {
          'content-type': 'application/json',
          'referer': 'https://space.bilibili.com/${mid ?? ''}/dynamic',
        },
      ),
      cancelToken: cancelToken,
    );
  }

  /// 获取动态详细信息
  static Future<dynamic> getDynamicDetail({
    required Map<String, dynamic> queryParameters,
    CancelToken? cancelToken,
  }) async {
    return BiliXClient.instance.get(
      '/polymer/web-dynamic/v1/detail',
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  /// 获取动态详细信息,加强版能够获取到动态文字信息
  static Future<dynamic> getDynamicDetail2({
    required Map<String, dynamic> queryParameters,
    CancelToken? cancelToken,
  }) async {
    return BiliXClient.instance.get(
      '/polymer/web-dynamic/v1/opus/detail',
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }
}
