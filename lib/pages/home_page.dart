import 'dart:developer' as developer;
import 'package:bilibilihelper/pages/space/dynamic_page.dart';
import 'package:bilibilihelper/pages/space/followings_page.dart';
import 'package:bilibilihelper/pages/log_in_page.dart';
import 'package:bilibilihelper/pages/space/lottery_page.dart';
import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:bilibilihelper/userdata/user_dynamic_info.dart';
import 'package:bilibilihelper/userdata/user_following_info.dart';
import 'package:bilibilihelper/userdata/user_lottery_info.dart';
import 'package:bilibilihelper/utils/bili_x_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  RxString imageUrl = ''.obs;
  RxString uname = ''.obs;
  RxString mid = ''.obs;

  @override
  void initState() {
    super.initState();
    _initMyInfo();
  }

  Future<void> _initMyInfo() async {
    //https://api.bilibili.com/x/space/v2/myinfo?web_location=333.1387
    developer.log('initMyInfo');
    Response<dynamic> response = await api.get(
      '/space/v2/myinfo',
      queryParameters: {'web_location': '333.1387'},
    );
    //developer.log(response.data.toString());
    // json解析response.data
    imageUrl.value = response.data['data']['profile']['face'].toString();
    uname.value = response.data['data']['profile']['name'].toString();
    mid.value = response.data['data']['profile']['mid'].toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('欢迎： ${uname.value}')),
        backgroundColor: Colors.purple[100],
      ),

      drawer: Drawer(
        width: 150,
        child: Stack(
          children: [
            Column(
              children: [
                Obx(
                  () => UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Colors.blue[200]),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: NetworkImage(imageUrl.value),
                    ),
                    accountName: Text(
                      uname.value,
                      style: TextStyle(fontSize: 20),
                    ),
                    accountEmail: Text(
                      mid.value,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),

                //listview包裹
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      ListTile(
                        leading: Icon(Icons.people_rounded),
                        title: Text('我的关注'),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => FollowingsPage());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.dynamic_feed_rounded),
                        title: Text('我的动态'),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => DynamicPage());
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.card_giftcard_outlined),
                        title: Text('我的抽奖'),
                        onTap: () {
                          Navigator.pop(context);
                          Get.to(() => LotteryPage());
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                onPressed: () {
                  // 跳转到登录页
                  Get.to(() => LogInPage());
                  // 退出登录
                  SecureStorageService.deleteToken();
                  dynamicInfoList.clear();
                  followingList.clear();
                  userLotteryInfoList.clear();
                },
                icon: Icon(Icons.logout),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        alignment: Alignment.center,
        child: Image.asset('assets/image/empty.png', fit: BoxFit.cover),
      ),
    );
  }
}
