// ignore_for_file: non_constant_identifier_names

import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:bilihelper/models/user/dynamic_model/dynamic_item.dart';
import 'package:bilihelper/models/user/following_model/following_item.dart';
import 'package:bilihelper/models/user/lottery_model/lottery_item.dart';

class UserModel {
  static final UserModel _instance = UserModel._internal();
  factory UserModel() => _instance;
  UserModel._internal();

  List<FollowingItem> followingItems = [];
  List<DynamicItem> dynamicItems = [];
  List<LotteryItem> lotteryItems = [];

  Future<void> logout() async {
    await SecureStorageService.deleteAll();
    followingItems.clear();
    dynamicItems.clear();
  }
}
