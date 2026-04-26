import 'package:bilihelper/models/home/home_provider.dart';
import 'package:bilihelper/models/user/user_model.dart';
import 'package:bilihelper/pages/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyNavRail extends ConsumerStatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  const MyNavRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  ConsumerState<MyNavRail> createState() => _MyNavRailState();
}

class _MyNavRailState extends ConsumerState<MyNavRail> {
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
            icon: Icon(Icons.card_giftcard_outlined),
            selectedIcon: Icon(Icons.card_giftcard_rounded),
            label: Text('抽奖'),
          ),
        ],
        trailing: Column(
          children: [
            ClipOval(
              child: Image.network(
                ref.watch(homeProvider.select((value) => value.imageUrl ?? '')),
                width: 45,
                height: 45,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
              ),
            ),
            // 退出登录
            IconButton(
              icon: Icon(Icons.logout),
              iconSize: 20,
              onPressed: () async {
                await UserModel().logout(ref);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
        onDestinationSelected: (int index) {
          widget.onDestinationSelected(index);
        },
      ),
    );
  }
}
