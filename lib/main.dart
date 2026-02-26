import 'package:bilibilihelper/pages/home_page.dart';
import 'package:bilibilihelper/pages/log_in_page.dart';
import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:bilibilihelper/utils/bili_x_api.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? sessdata = await SecureStorageService.getToken('SESSDATA');
  await api.initDio();

  bool islogin = sessdata != null;
  runApp(MyApp(islogin: islogin));
}

class MyApp extends StatelessWidget {
  final bool islogin;
  const MyApp({super.key, required this.islogin});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      //关闭debug banner
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Noto Sans SC'),
      home: islogin ? const HomePage() : const LogInPage(),
    );
  }
}
