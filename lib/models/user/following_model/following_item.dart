class FollowingItem {
  int mid;
  int attribute;
  DateTime mtime;
  int special;
  String uname;
  String face;
  String sign;

  FollowingItem({
    required this.mid,
    required this.attribute,
    required this.mtime,
    required this.special,
    required this.uname,
    required this.face,
    required this.sign,
  });
  factory FollowingItem.fromJson(dynamic json) {
    return FollowingItem(
      mid: json['mid'],
      attribute: json['attribute'],
      mtime: DateTime.fromMillisecondsSinceEpoch(
        json['mtime'] * 1000,
      ).toLocal(),
      special: json['special'],
      uname: json['uname'],
      face: json['face'],
      sign: json['sign'],
    );
  }
}
