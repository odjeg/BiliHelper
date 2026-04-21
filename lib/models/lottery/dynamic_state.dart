class DynamicState {
  final String userName;
  final int userMid;
  final String useImage;
  final String editTime;
  final int commentType;
  final String oid;
  final int type;

  final int? viewCount; // 播放数
  final int? danmakuCount; // 弹幕数
  final int? favoriteCount; // 收藏数
  final int? coinCount; // 硬币数
  final int? likeCount; // 点赞数
  final int? commentCount; // 评论数
  final int? shareCount; // 分享数

  const DynamicState({
    required this.userName,
    required this.userMid,
    required this.useImage,
    required this.editTime,
    required this.commentType,
    required this.oid,
    required this.type,
    this.viewCount,
    this.danmakuCount,
    this.favoriteCount,
    this.coinCount,
    this.likeCount,
    this.commentCount,
    this.shareCount,
  });
  DynamicState copyWith({
    required String userName,
    required int userMid,
    required String useImage,
    required String editTime,
    required int commentType,
    required String oid,
    required int type,
    int? viewCount,
    int? danmakuCount,
    int? favoriteCount,
    int? coinCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
  }) {
    return DynamicState(
      userName: userName,
      userMid: userMid,
      useImage: useImage,
      editTime: editTime,
      commentType: commentType,
      oid: oid,
      type: type,
      viewCount: viewCount,
      danmakuCount: danmakuCount,
      favoriteCount: favoriteCount,
      coinCount: coinCount,
      likeCount: likeCount,
      commentCount: commentCount,
      shareCount: shareCount,
    );
  }
}
