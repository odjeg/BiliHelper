import 'package:bilibilihelper/controllers/dynamic_controller.dart';
import 'package:bilibilihelper/controllers/followings_controller.dart';
import 'package:bilibilihelper/controllers/load_status.dart';
import 'package:bilibilihelper/controllers/lottery_controller.dart';
import 'package:bilibilihelper/pages/space/tabs/dynamic_page.dart';
import 'package:bilibilihelper/pages/space/tabs/followings_page.dart';
import 'package:bilibilihelper/pages/space/tabs/lottery_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpacePage extends StatefulWidget {
  const SpacePage({super.key});

  @override
  State<SpacePage> createState() => _SpacePageState();
}

class _SpacePageState extends State<SpacePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: Colors.pink[200],
              dividerHeight: 1,
              dividerColor: Colors.pink[200],
              indicatorWeight: 1,
              labelColor: Colors.pink[200],
              unselectedLabelColor: Colors.grey,
              mouseCursor: SystemMouseCursors.click,
              tabs: [
                Tab(
                  child: Badge(
                    backgroundColor: Colors.transparent,
                    offset: Offset(10, -10),
                    label: Consumer<FollowingsController>(
                      builder: (context, controller, child) {
                        if (controller.loadStatus == LoadStatus.loading) {
                          return CircularProgressIndicator(
                            color: Colors.pink[200],
                            strokeWidth: 0.5,
                            constraints: BoxConstraints.tightFor(
                              width: 10,
                              height: 10,
                            ),
                          );
                        } else if (controller.loadStatus == LoadStatus.done) {
                          return Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.green,
                          );
                        } else if (controller.loadStatus == LoadStatus.error) {
                          return Icon(Icons.close, size: 10, color: Colors.red);
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                    child: Text('关注'),
                  ),
                ),
                Tab(
                  child: Badge(
                    backgroundColor: Colors.transparent,
                    offset: Offset(10, -10),
                    label: Consumer<DynamicController>(
                      builder: (context, controller, child) {
                        if (controller.loadStatus == LoadStatus.loading) {
                          return CircularProgressIndicator(
                            color: Colors.pink[200],
                            strokeWidth: 0.5,
                            constraints: BoxConstraints.tightFor(
                              width: 10,
                              height: 10,
                            ),
                          );
                        } else if (controller.loadStatus == LoadStatus.done) {
                          return Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.green,
                          );
                        } else if (controller.loadStatus == LoadStatus.error) {
                          return Icon(Icons.close, size: 10, color: Colors.red);
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                    child: Text('动态'),
                  ),
                ),

                Tab(
                  child: Badge(
                    backgroundColor: Colors.transparent,
                    offset: Offset(10, -10),
                    label: Consumer<LotteryController>(
                      builder: (context, controller, child) {
                        if (controller.loadStatus == LoadStatus.loading) {
                          return CircularProgressIndicator(
                            color: Colors.pink[200],
                            strokeWidth: 0.5,
                            constraints: BoxConstraints.tightFor(
                              width: 10,
                              height: 10,
                            ),
                          );
                        } else if (controller.loadStatus == LoadStatus.done) {
                          return Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.green,
                          );
                        } else if (controller.loadStatus == LoadStatus.error) {
                          return Icon(Icons.close, size: 10, color: Colors.red);
                        } else {
                          return SizedBox.shrink();
                        }
                      },
                    ),
                    child: Text('抽奖'),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [FollowingsPage(), DynamicPage(), LotteryPage()],
        ),
      ),
    );
  }
}
