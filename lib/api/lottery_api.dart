import 'package:bilihelper/common/network/clients/bili_vc_client.dart';
import 'package:bilihelper/common/network/clients/bili_x_client.dart';
import 'package:dio/dio.dart';

class LotteryApi {
  /// 获取抽奖详情
  static Future<Response<dynamic>> getLotteryDetail({
    required Map<String, dynamic> queryParameters,
    CancelToken? cancelToken,
  }) async {
    return BiliVcClient.instance.get(
      '/lottery_svr/v1/lottery_svr/lottery_notice',
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );
  }

  /// 进行预约抽奖
  static Future<Response<dynamic>> reserveLottery({
    required String dynamicIdStr,
    required String reserveId,
    CancelToken? cancelToken,
  }) async {
    var response = await BiliXClient.instance.post(
      '/dynamic/feed/reserve/click',
      data: {
        'cur_btn_status': 1,
        'dynamic_id_str': dynamicIdStr,
        'reserve_id': reserveId,
      },
      options: Options(
        headers: {
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
}
