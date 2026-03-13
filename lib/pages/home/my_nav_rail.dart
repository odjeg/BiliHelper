import 'dart:developer' as developer;
import 'package:bilibilihelper/controllers/theme_controller.dart';
import 'package:bilibilihelper/pages/home/home_controller.dart';
import 'package:bilibilihelper/pages/log_in_page.dart';
import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:bilibilihelper/userdata/user_dynamic_info.dart';
import 'package:bilibilihelper/userdata/user_following_info.dart';
import 'package:bilibilihelper/userdata/user_lottery_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class MyNavRail extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  const MyNavRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  State<MyNavRail> createState() => _MyNavRailState();
}

class _MyNavRailState extends State<MyNavRail> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
      ),
      child: NavigationRail(
        selectedIndex: widget.selectedIndex,
        selectedIconTheme: IconThemeData(color: Colors.pink[200]),
        unselectedIconTheme: IconThemeData(color: Colors.grey),
        selectedLabelTextStyle: TextStyle(color: Colors.pink[200]),
        unselectedLabelTextStyle: TextStyle(color: Colors.grey),
        useIndicator: false,
        minWidth: 60,
        trailingAtBottom: true,
        labelType: NavigationRailLabelType.all,
        destinations: [
          NavigationRailDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: Text('我的'),
            padding: EdgeInsets.only(top: 50),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.comment_outlined),
            selectedIcon: Icon(Icons.comment),
            label: Text('评论'),
            padding: EdgeInsets.symmetric(vertical: 20),
          ),
        ],
        trailing: Column(
          children: [
            // 主题切换
            Consumer<ThemeController>(
              builder: (context, themeController, child) => Switch(
                value: themeController.currThemeMode == ThemeMode.dark,
                onChanged: (value) {
                  if (value) {
                    themeController.themeMode = ThemeMode.dark;
                    developer.log('dark mode');
                  } else {
                    themeController.themeMode = ThemeMode.light;
                    developer.log('light mode');
                  }
                },
              ),
            ),
            // 头像
            Obx(
              () => ClipOval(
                child: Image.network(
                  homeController.imageUrl.value,
                  width: 45,
                  height: 45,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.error),
                ),
              ),
            ),
            // 退出登录
            IconButton(
              icon: Icon(Icons.logout),
              iconSize: 20,
              onPressed: () async {
                Get.to(() => LogInPage());
                await SecureStorageService.deleteToken();
                dynamicInfoList.clear();
                followingList.clear();
                userLotteryInfoList.clear();
              },
            ),
          ],
        ),
        onDestinationSelected: (int index) {
          //developer.log('index: $index');
          widget.onDestinationSelected(index);
        },
      ),
    );
  }
}
