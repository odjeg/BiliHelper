class LotteryItem {
  /// [businessId] 抽奖动态id
  String businessId;

  /// [commentIdStr] 用来评论,评论时将commentIdStr作为参数传递给oid
  String? commentIdStr;

  /// [mid] 用户UID
  int? mid;

  /// [name] 用户昵称
  String? name;

  /// [followed] 是否已关注用户
  bool? followed;

  /// [lotteryTime] 开奖时间
  int? lotteryTime;

  /// [ts] 动态时间戳
  /// 用于判断是否是最新动态
  int? ts;

  /// [isForward] 是否转发预约抽奖
  String? isForward;

  /// [lotteryType] 抽奖类型
  /// 官方抽奖 直播预约 视频预约 普通抽奖
  String? lotteryType;

  /// [rid] 预约抽奖需要用到
  String? rid;
  LotteryItem({
    required this.businessId,
    this.mid,
    this.name,
    this.followed,
    this.lotteryTime,
    this.ts,
    this.isForward,
    this.lotteryType,
    this.rid,
  });
}
