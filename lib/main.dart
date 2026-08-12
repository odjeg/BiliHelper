import 'dart:developer' show log;

import 'package:bilihelper/api/dynamic_api.dart';
import 'package:bilihelper/common/network/bili_dio_core.dart';
import 'package:bilihelper/common/network/clients/bili_vc_client.dart';
import 'package:bilihelper/common/network/clients/bili_x_client.dart';
import 'package:bilihelper/common/network/clients/passport_x_client.dart';
import 'package:bilihelper/common/services/auth_service.dart';
import 'package:bilihelper/common/services/bili_x_dio_service.dart';
import 'package:bilihelper/pages/home/home_page.dart';
import 'package:bilihelper/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
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

  // 1. 先初始化核心底座
  BiliDioCore.instance.init();
  // 2. 再初始化passport客户端
  PassportXClient.instance.init();
  // 3. 再初始化各业务域名客户端
  BiliXClient.instance.init();
  // 4. 再初始化各业务服务
  BiliVcClient.instance.init();

  bool needLogin = await AuthService.checkNeedLogin();
  runApp(ProviderScope(child: MyApp(needLogin: needLogin)));
}

class MyApp extends StatelessWidget {
  final bool needLogin;
  const MyApp({super.key, required this.needLogin});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Noto Sans SC'),
      home: needLogin == true ? const LoginPage() : HomePage(needLogin: false),
    );
  }
}
