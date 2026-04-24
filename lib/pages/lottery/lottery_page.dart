import 'package:bilihelper/models/lottery/lottery_provider.dart';
import 'package:bilihelper/pages/lottery/component/awart_condition_section.dart';
import 'package:bilihelper/pages/lottery/component/content_condition_section.dart';
import 'package:bilihelper/pages/lottery/component/draw_lottery.dart';
import 'package:bilihelper/pages/lottery/component/filter_condition_and_reset_section.dart';
import 'package:bilihelper/pages/lottery/component/link_input_section.dart';
import 'package:bilihelper/pages/lottery/component/multi_awart_section.dart';
import 'package:bilihelper/pages/lottery/component/single_award_section.dart';
import 'package:bilihelper/pages/lottery/component/user_level_filter_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LotteryPage extends ConsumerStatefulWidget {
  const LotteryPage({super.key});

  @override
  ConsumerState<LotteryPage> createState() => _LotteryPageState();
}

class _LotteryPageState extends ConsumerState<LotteryPage>
    with SingleTickerProviderStateMixin {
  late List<(TextEditingController, TextEditingController)> prizeControllers;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            _buildTitle(),
            SizedBox(height: 20),
            LinkInputSection(), // 链接的输入框和清除按钮，以及粘贴按钮
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink[50]!,
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(1, 1), // 阴影方向
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilterConditionAndResetSection(),
                  SizedBox(height: 10),

                  UserLevelFilterSection(), //用户等级限制：lv0,lv1,lv2,lv3,lv4,lv5,lv6
                  SizedBox(height: 10),
                  ContentConditionSection(), //内容与互动：关键词过滤
                  SizedBox(height: 20),
                  AwardConditionSection(), //奖项条件：单奖项/多奖项
                  SizedBox(height: 20),
                  Consumer(
                    builder: (context, ref, child) {
                      final isMultiLotteryFilter = ref.watch(
                        lotteryProvider.select(
                          (state) => state.isMultiLotteryFilter,
                        ),
                      );
                      return isMultiLotteryFilter
                          ? MultiAwardSection() // 多奖项配置
                          : SingleAwardSection(); // 单奖项配置
                    },
                  ),
                ],
              ),
            ),
            DrawLottery(),
          ],
        ),
      ),
    );
  }

  // 标题
  Widget _buildTitle() {
    return Center(
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '更专业、更精细的 ',
              style: TextStyle(
                fontSize: 27,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: 'B站抽奖',
              style: TextStyle(
                color: Colors.pink[200],
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
