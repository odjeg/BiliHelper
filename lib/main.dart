import 'dart:developer' as developer;

import 'package:bilibilihelper/controllers/dynamic_controller.dart';
import 'package:bilibilihelper/controllers/followings_controller.dart';
import 'package:bilibilihelper/controllers/lottery_controller.dart';
import 'package:bilibilihelper/pages/home/home_page.dart';
import 'package:bilibilihelper/pages/log_in_page.dart';
import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:bilibilihelper/utils/bili_x_api.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    title: 'Bilibili Helper',
    minimumSize: Size(850, 600),
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  await api.initDio();

  //需增加异常处理
  var response = await api.get(
    'https://passport.bilibili.com/x/passport-login/web/cookie/info',
    queryParameters: {'csrf': await SecureStorageService.getToken('bili_jct')},
  );

  late bool needLogin;
  if (response.data['code'] == -101 ||
      response.data['data']['refresh'] == true) {
    needLogin = true;
  } else {
    needLogin = false;
  }
  developer.log('needLogin: $needLogin');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FollowingsController()),
        ChangeNotifierProvider(create: (context) => DynamicController()),
        ChangeNotifierProvider(create: (context) => LotteryController()),
      ],
      child: MyApp(needLogin: needLogin),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool needLogin;
  const MyApp({super.key, required this.needLogin});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Noto Sans SC'),
      home: needLogin ? const LogInPage() : const HomePage(),
    );
  }
}
