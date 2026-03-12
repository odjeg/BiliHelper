import 'dart:developer' as developer;
import 'package:bilibilihelper/pages/comment/comment_page.dart';
import 'package:bilibilihelper/pages/home/my_nav_rail.dart';
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
  final List<Widget> _pages = [SpacePage(), CommentPage()];

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
