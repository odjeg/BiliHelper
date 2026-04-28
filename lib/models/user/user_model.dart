// ignore_for_file: non_constant_identifier_names

import 'dart:developer';

import 'package:bilihelper/common/services/secure_storage_service.dart';
import 'package:bilihelper/models/home/home_provider.dart';
import 'package:bilihelper/models/lottery/providers.dart/lottery_reply_provider.dart';
import 'package:bilihelper/models/space/dynamic_provider.dart';
import 'package:bilihelper/models/space/following_provider.dart';
import 'package:bilihelper/models/space/lottery_provider.dart'
    as space_lottery_provider;
import 'package:bilihelper/models/user/dynamic_model/dynamic_item.dart';
import 'package:bilihelper/models/user/following_model/following_item.dart';
import 'package:bilihelper/models/user/lottery_model/lottery_item.dart';
import 'package:bilihelper/models/lottery/lottery_provider.dart'
    as lottery_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserModel {
  static final UserModel _instance = UserModel._internal();
  factory UserModel() => _instance;
  UserModel._internal();

  List<FollowingItem> followingItems = [];
  List<DynamicItem> dynamicItems = [];
  List<LotteryItem> lotteryItems = [];

  Future<void> logout(WidgetRef ref) async {
    log('正在退出登录...');
    await SecureStorageService.deleteAll();
    followingItems.clear();
    dynamicItems.clear();
    lotteryItems.clear();

    ref.invalidate(followingProvider);
    ref.invalidate(dynamicProvider);
    ref.invalidate(space_lottery_provider.lotteryProvider);
    ref.invalidate(homeProvider);
    ref.invalidate(lottery_provider.lotteryProvider);
    ref.invalidate(lotteryReplyProvider);
  }
}
