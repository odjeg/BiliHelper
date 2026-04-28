class ReplyState {
  int rpid;
  int mid;
  int root;
  int parent;
  int ctime;
  String uname;
  String avatar;
  int currentLevel;
  String message;
  String? location;
  ReplyState(
    this.rpid,
    this.mid,
    this.root,
    this.parent,
    this.ctime,
    this.uname,
    this.avatar,
    this.currentLevel,
    this.message,
    this.location,
  );
  factory ReplyState.fromJson(Map<String, dynamic> json) => ReplyState(
    json['rpid'],
    json['mid'],
    json['root'],
    json['parent'],
    json['ctime'],
    json['member']['uname'],
    json['member']['avatar'],
    json['member']['level_info']['current_level'],
    json['content']['message'],
    json['reply_control']['location'] ?? '',
  );
}
