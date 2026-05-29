import 'dart:ffi';

class DynamicItem {
  final String idStr; // 个人转发动态id
  final String pubTs; // 动态发布时间戳

  final String origIdStr;
  final int origMid;
  final String origName;
  final bool following;
  final String dynamicText;

  DynamicItem({
    required this.idStr,
    required this.pubTs,
    required this.origIdStr,
    required this.origMid,
    required this.origName,
    required this.following,
    required this.dynamicText,
  });
  factory DynamicItem.fromJson(Map<String, dynamic> json) {
    if (json['orig']['id_str'] == "0") {
      return DynamicItem(
        idStr: json['id_str'],
        pubTs: json['modules']['module_author']['pub_ts'],
        origIdStr: "",
        origMid: 0,
        origName: "",
        following: false,
        dynamicText: "",
      );
    }
    return DynamicItem(
      idStr: json['id_str'],
      pubTs: json['modules']['module_author']['pub_ts'],
      origIdStr: json['orig']['id_str'],
      origMid: json['orig']['modules']['module_author']['mid'],
      origName: json['orig']['modules']['module_author']['name'],
      following: json['orig']['modules']['module_author']['following'],
      dynamicText: json['modules']['module_dynamic']['desc']['text'],
    );
  }
}
