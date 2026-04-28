import 'package:bilihelper/models/home/home_provider.dart';
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
    // ✅✅✅ 只注册一次！永远不会重复！
    ref.listenManual<LoginState>(loginProvider, (previous, current) {
      if (!previous!.isLoginSuccess && current.isLoginSuccess) {
        ref.read(homeProvider.notifier).initProfile();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
