import 'dart:developer' as developer;
import 'package:bilibilihelper/pages/home/my_nav_rail.dart';
import 'package:bilibilihelper/pages/live/live_page.dart';
import 'package:bilibilihelper/pages/space/space_page.dart';
import 'package:bilibilihelper/utils/bili_x_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:bilibilihelper/pages/home/home_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _initMyInfo();
  }

  int _selectedIndex = 0;
  final List<Widget> _pages = [SpacePage(), LivePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          MyNavRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _pages[_selectedIndex],
            ),
          ),
        ],
      ),
    );
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
    homeController.imageUrl.value = response.data['data']['profile']['face']
        .toString();
    homeController.uname.value = response.data['data']['profile']['name']
        .toString();
    homeController.mid.value = response.data['data']['profile']['mid']
        .toString();
  }
}

/*
Scaffold(
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
*/
