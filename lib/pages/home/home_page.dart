import 'package:bilihelper/models/home/home_provider.dart';
import 'package:bilihelper/pages/crawler/crawler_page.dart';
import 'package:bilihelper/pages/home/my_nav_rail.dart';
import 'package:bilihelper/pages/lottery/lottery_page.dart';
import 'package:bilihelper/pages/space/space_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  final bool? needLogin;
  const HomePage({super.key, this.needLogin});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  final List<Widget> _pages = [SpacePage(), LotteryPage(), ClawlerPage()];

  @override
  void initState() {
    super.initState();
    if (widget.needLogin == false) {
      ref.read(homeProvider.notifier).initProfile();
    }
  }

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
              _pageController.jumpToPage(index);
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: _pages, // 禁止滑动
            ),
          ),
        ],
      ),
    );
  }
}
