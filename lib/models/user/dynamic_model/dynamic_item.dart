// ignore_for_file: non_constant_identifier_names

class DynamicItem {
  final String id_str; // 个人转发动态id
  final String pub_ts; // 动态发布时间戳

  final String orig_id_str;
  final int orig_mid;
  final String orig_name;
  final bool following;
  final String dynamic_text;

  DynamicItem({
    required this.id_str,
    required this.pub_ts,
    required this.orig_id_str,
    required this.orig_mid,
    required this.orig_name,
    required this.following,
    required this.dynamic_text,
  });
  factory DynamicItem.fromJson(Map<String, dynamic> json) {
    return DynamicItem(
      id_str: json['id_str'],
      pub_ts: json['modules']['module_author']['pub_ts'],
      orig_id_str: json['orig']['id_str'],
      orig_mid: json['orig']['modules']['module_author']['mid'],
      orig_name: json['orig']['modules']['module_author']['name'],
      following: json['orig']['modules']['module_author']['following'],
      dynamic_text: json['modules']['module_dynamic']['desc']['text'],
    );
  }
}
