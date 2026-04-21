// ignore_for_file: non_constant_identifier_names

class LotteryItem {
  String business_id; //抽奖动态id
  String? comment_id_str; //用来评论评论id|oid
  int? mid;
  String? name;
  bool? followed; //是否关注
  int? lottery_time; //开奖时间
  int? ts; //动态时间戳
  String? isForward; //是否转发如果是预约抽奖则为是否预约
  String? lotteryType; //官方抽奖 直播预约 视频预约 普通抽奖
  int? rid; //预约抽奖需要用到
  LotteryItem({
    required this.business_id,
    this.mid,
    this.name,
    this.followed,
    this.lottery_time,
    this.ts,
    this.isForward,
    this.lotteryType,
    this.rid,
  });
}
