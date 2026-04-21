import 'package:bilihelper/models/login/login_provider.dart';
import 'package:bilihelper/models/login/login_state.dart';
import 'package:bilihelper/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

// 必须用 Stateful 版本
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  @override
  void initState() {
    super.initState();
    ref.read(loginProvider.notifier).initQrCode();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginProvider, (previous, current) {
      // 🔥 登录成功 → 跳主页，并且销毁登录页
      if (current.isLoginSuccess) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    });
    final state = ref.watch(loginProvider);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: state.url ?? '',
              version: QrVersions.auto,
              size: 400.0,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              state.message ?? '',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
