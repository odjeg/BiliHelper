import 'package:bilihelper/models/user/user_model.dart';

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
      //由于b站接口更改，导致无法直接从动态列表当中获取是否关注
      following: UserModel().followingItems.any(
        (item) =>
            item.mid == json['orig']['modules']['module_author']['mid'] as int,
      ),
      dynamicText: json['modules']['module_dynamic']['desc']['text'],
    );
  }
}
