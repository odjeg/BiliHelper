import 'dart:developer';
import 'dart:ui';

import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/lottery/lottery_provider.dart';
import 'package:bilihelper/models/lottery/providers.dart/lottery_reply_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight_text/highlight_text.dart';
import 'package:intl/intl.dart';

class DrawLottery extends ConsumerStatefulWidget {
  const DrawLottery({super.key});

  @override
  ConsumerState<DrawLottery> createState() => _DrawLotteryState();
}

class _DrawLotteryState extends ConsumerState<DrawLottery>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> gradientAnimation;
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(
            vsync: this,
            duration: const Duration(seconds: 5), // 渐变滚动速度（值越小越快）
          )
          ..repeat()
          ..stop(); // repeat() 实现无限循环

    // 生成0~1的动画值，驱动渐变平移
    gradientAnimation = Tween<double>(begin: 300, end: 1200.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.linear, // 匀速滚动，无加速减速
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDrawLotteryButton(),
            SizedBox(width: 20),
            Consumer(
              builder: (context, ref, child) {
                var loadState = ref.watch(
                  lotteryProvider.select((value) => value.loadState),
                );
                return IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: loadState == LoadState.loading
                      ? () {
                          if (animationController.isAnimating) {
                            animationController.stop();
                          }
                          ref
                              .read(lotteryProvider.notifier)
                              .updateLoadState(LoadState.none);
                        }
                      : null,
                );
              },
            ),
          ],
        ),
        SizedBox(height: 20),
        Consumer(
          builder: (context, ref, child) {
            var dynamicState = ref.watch(
              lotteryProvider.select((value) => value.dynamicState),
            );
            return dynamicState != null
                ? _buildDynamicDetail()
                : SizedBox.shrink();
          },
        ),
        SizedBox(height: 20),
        _buildReplyList(),
        SizedBox(height: 20),
        _buildLuckUserList(),
      ],
    );
  }

  // 抽奖按钮
  Widget _buildDrawLotteryButton() {
    return Consumer(
      builder: (context, ref, child) {
        var isloading = ref.watch(
          lotteryProvider.select(
            (value) => value.loadState == LoadState.loading,
          ),
        );
        return AnimatedBuilder(
          animation: gradientAnimation,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: AnimatedBuilder(
                    animation: gradientAnimation,
                    builder: (context, child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          children: [
                            SizedBox(width: 200, height: 40),
                            Positioned(
                              left: -gradientAnimation.value,
                              top: 0,
                              child: Container(
                                height: 40,
                                width: 1500,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xffffeb3d),
                                      Color(0xff03a9f4),
                                      Color(0xfff441a5),
                                      Color(0xffffeb3d),
                                      Color(0xff03a9f4),
                                      Color(0xfff441a5),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Positioned(
                        left: -gradientAnimation.value,
                        top: 0,
                        child: Container(
                          height: 40,
                          width: 1500,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xffffeb3d),

                                Color(0xff03a9f4),
                                Color(0xfff441a5),
                                Color(0xffffeb3d),
                                Color(0xff03a9f4),
                                Color(0xfff441a5),
                              ],
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: isloading
                            ? null
                            : () async {
                                animationController.repeat();
                                await ref
                                    .read(lotteryProvider.notifier)
                                    .startDarwLottery();
                                if (animationController.isAnimating) {
                                  animationController.stop();
                                }
                              },
                        style: ButtonStyle(
                          minimumSize: const WidgetStatePropertyAll(
                            Size(200, 40),
                          ),
                          shape: WidgetStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          backgroundColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          foregroundColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          overlayColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          shadowColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          surfaceTintColor: WidgetStatePropertyAll(
                            Colors.transparent,
                          ),
                          padding: WidgetStatePropertyAll(EdgeInsets.zero),
                        ),
                        child: const Text(
                          '开始抽奖',
                          style: TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 0.8),
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDynamicDetail() {
    return Consumer(
      builder: (context, ref, child) {
        var dynamicState = ref.watch(
          lotteryProvider.select((value) => value.dynamicState),
        );
        if (dynamicState == null) {
          return SizedBox.shrink();
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IntrinsicWidth(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    backgroundImage: dynamicState.useImage.isNotEmpty
                        ? NetworkImage(dynamicState.useImage)
                        : null,
                    radius: 25,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dynamicState.userName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dynamicState.userMid.toString(),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      Text(
                        dynamicState.editTime,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            IntrinsicWidth(
              child: Column(
                mainAxisSize: .min,
                mainAxisAlignment: .center,
                children: [
                  Icon(Icons.thumb_up_outlined),
                  Text(
                    dynamicState.likeCount.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.reply_outlined),
                  Text(
                    dynamicState.shareCount.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            SizedBox(width: 20),
            IntrinsicWidth(
              child: Column(
                mainAxisSize: .min,
                mainAxisAlignment: .center,
                children: [
                  Icon(Icons.comment_outlined),
                  Text(
                    dynamicState.commentCount.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            dynamicState.viewCount == null
                ? const SizedBox.shrink()
                : Row(
                    mainAxisSize: .min,
                    children: [
                      SizedBox(width: 20),
                      IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.visibility),
                            Text(
                              dynamicState.viewCount.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            dynamicState.danmakuCount == null
                ? const SizedBox.shrink()
                : Row(
                    mainAxisSize: .min,
                    children: [
                      SizedBox(width: 20),
                      IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.subtitles),
                            Text(
                              dynamicState.danmakuCount.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            dynamicState.favoriteCount == null
                ? const SizedBox.shrink()
                : Row(
                    mainAxisSize: .min,
                    children: [
                      SizedBox(width: 20),
                      IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_border),
                            Text(
                              dynamicState.favoriteCount.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
            dynamicState.coinCount == null
                ? const SizedBox.shrink()
                : Row(
                    mainAxisSize: .min,
                    children: [
                      SizedBox(width: 20),
                      IntrinsicWidth(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.monetization_on),
                            Text(
                              dynamicState.coinCount.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ],
        );
      },
    );
  }

  // 回复列表
  Widget _buildReplyList() {
    return Consumer(
      builder: (context, ref, child) {
        var isLoading = ref.watch(
          lotteryProvider.select(
            (value) => value.loadState == LoadState.loading,
          ),
        );
        var replyCount = ref.watch(
          lotteryReplyProvider.select((value) => value.length),
        );
        if (!isLoading) return SizedBox.shrink();
        return Column(
          children: [
            CircularProgressIndicator(
              color: Colors.pink[200],
              strokeWidth: 0.5,
              constraints: const BoxConstraints.tightFor(width: 30, height: 30),
            ),
            Text('$replyCount条评论加载中...'),
          ],
        );
      },
    );
  }

  // 抽奖用户列表
  Widget _buildLuckUserList() {
    return Consumer(
      builder: (context, ref, child) {
        ref.watch(lotteryProvider.select((value) => value.loadState));
        bool ismultiLotteryFilter = ref.watch(
          lotteryProvider.select((value) => value.isMultiLotteryFilter),
        );
        if (!ismultiLotteryFilter) return _buildSingleLuck();
        return _buildMultiLuck();
      },
    );
  }

  Widget _buildSingleLuck() {
    var luckUserList = ref.read(
      lotteryProvider.select((value) => value.luckUserList),
    );
    if (luckUserList == null || luckUserList.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      children: luckUserList
          .map(
            (item) => Container(
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(5),
              ),
              padding: EdgeInsets.all(10),
              child: Wrap(
                children: [
                  SelectableText(
                    '${item.uname}(${item.mid})[Lv${item.current_level}]{${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(item.ctime * 1000))}}-',
                  ),
                  TextHighlight(
                    text: item.message,
                    words: {
                      ref.read(lotteryProvider).keyWorldFilter: HighlightedWord(
                        textStyle: TextStyle(
                          color: Colors.pink[300],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    },
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMultiLuck() {
    var luckUserList = ref.read(
      lotteryProvider.select((value) => value.luckUserList),
    );
    var prizeItems = ref.read(
      lotteryProvider.select((value) => value.prizeItems),
    );
    if (luckUserList == null || luckUserList.isEmpty) {
      return SizedBox.shrink();
    }
    int index = 0;
    return Column(
      children: [
        for (var (name, count) in prizeItems)
          Column(
            children: [
              Text('$name - $count人'),
              ...luckUserList.skip(index).take(count).map((item) {
                index++;
                return Container(
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: EdgeInsets.all(10),
                  child: Wrap(
                    children: [
                      SelectableText(
                        '${item.uname}(${item.mid})[Lv${item.current_level}]{${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.fromMillisecondsSinceEpoch(item.ctime * 1000))}}-',
                      ),
                      TextHighlight(
                        text: item.message,
                        words: {
                          ref
                              .read(lotteryProvider)
                              .keyWorldFilter: HighlightedWord(
                            textStyle: TextStyle(
                              color: Colors.pink[300],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
      ],
    );
  }
}
