import 'dart:developer' show log;

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

  await BiliXDioService.init();
  bool needLogin = await AuthService.checkNeedLogin();
  log('needLogin:$needLogin');
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
