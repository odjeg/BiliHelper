import 'package:bilibilihelper/controllers/dynamic_controller.dart';
import 'package:bilibilihelper/controllers/followings_controller.dart';
import 'package:bilibilihelper/controllers/lottery_controller.dart';
import 'package:bilibilihelper/pages/home_page.dart';
import 'package:bilibilihelper/pages/log_in_page.dart';
import 'package:bilibilihelper/services/secure_storage_service.dart';
import 'package:bilibilihelper/utils/bili_x_api.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await api.initDio();

  var response = await api.get(
    'https://passport.bilibili.com/x/passport-login/web/cookie/info',
    queryParameters: {'csrf': await SecureStorageService.getToken('bili_jct')},
  );

  bool islogin = response.data['data']['refresh'];

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => FollowingsController()),
        ChangeNotifierProvider(create: (context) => DynamicController()),
        ChangeNotifierProvider(create: (context) => LotteryController()),
      ],
      child: MyApp(islogin: islogin),
    ),
  );
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
