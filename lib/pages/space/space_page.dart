import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/space/dynamic_provider.dart';
import 'package:bilihelper/models/space/following_provider.dart';
import 'package:bilihelper/models/space/lottery_provider.dart';
import 'package:bilihelper/pages/space/dynamic/dynamic_page.dart';
import 'package:bilihelper/pages/space/following/following_page.dart';
import 'package:bilihelper/pages/space/lottery/lottery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpacePage extends StatefulWidget {
  const SpacePage({super.key});

  @override
  State<SpacePage> createState() => _SpacePageState();
}

class _SpacePageState extends State<SpacePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
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
                  label: Consumer(
                    builder: (context, ref, child) {
                      final followingState = ref.watch(
                        followingProvider.select((state) => state.loadState),
                      );
                      if (followingState == LoadState.loading) {
                        return CircularProgressIndicator(
                          color: Colors.pink[200],
                          strokeWidth: 0.5,
                          constraints: BoxConstraints.tightFor(
                            width: 10,
                            height: 10,
                          ),
                        );
                      } else if (followingState == LoadState.done) {
                        return Icon(Icons.check, size: 10, color: Colors.green);
                      } else if (followingState == LoadState.error) {
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
                  label: Consumer(
                    builder: (context, ref, child) {
                      final dynamicState = ref.watch(
                        dynamicProvider.select((state) => state.loadState),
                      );
                      if (dynamicState == LoadState.loading) {
                        return CircularProgressIndicator(
                          color: Colors.pink[200],
                          strokeWidth: 0.5,
                          constraints: BoxConstraints.tightFor(
                            width: 10,
                            height: 10,
                          ),
                        );
                      } else if (dynamicState == LoadState.done) {
                        return Icon(Icons.check, size: 10, color: Colors.green);
                      } else if (dynamicState == LoadState.error) {
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
                  label: Consumer(
                    builder: (context, ref, child) {
                      final lotteryState = ref.watch(
                        lotteryProvider.select((state) => state.loadState),
                      );
                      if (lotteryState == LoadState.loading) {
                        return CircularProgressIndicator(
                          color: Colors.pink[200],
                          strokeWidth: 0.5,
                          constraints: BoxConstraints.tightFor(
                            width: 10,
                            height: 10,
                          ),
                        );
                      } else if (lotteryState == LoadState.done) {
                        return Icon(Icons.check, size: 10, color: Colors.green);
                      } else if (lotteryState == LoadState.error) {
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
        body: TabBarView(
          children: [FollowingPage(), DynamicPage(), LotteryPage()],
        ),
      ),
    );
  }
}
