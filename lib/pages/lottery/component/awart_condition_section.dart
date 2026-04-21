import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/lottery/lottery_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AwardConditionSection extends ConsumerStatefulWidget {
  const AwardConditionSection({super.key});

  @override
  ConsumerState<AwardConditionSection> createState() =>
      _AwardConditionSectionState();
}

class _AwardConditionSectionState extends ConsumerState<AwardConditionSection> {
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      lotteryProvider.select((state) => state.loadState == LoadState.loading),
    );
    final isMultiLotteryFilter = ref.watch(
      lotteryProvider.select((state) => state.isMultiLotteryFilter),
    );
    return Row(
      children: [
        Icon(Icons.stacked_bar_chart, color: Colors.pink[200]),
        Container(
          margin: EdgeInsets.only(left: 10),
          child: Text(
            '奖项配置',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Spacer(),
        Text(
          "启用多级奖项",
          style: TextStyle(
            color: isLoading
                ? Colors.grey
                : isMultiLotteryFilter
                ? Colors.pink[200]
                : Colors.grey,
            fontSize: 11,
          ),
        ),
        Transform.scale(
          scale: 0.6,
          child: Switch(
            value: isMultiLotteryFilter,
            activeThumbColor: Colors.pink[200],
            inactiveThumbColor: Colors.grey,
            onChanged: isLoading
                ? null
                : (value) {
                    ref.read(lotteryProvider.notifier).clearluckUserList();
                    ref
                        .read(lotteryProvider.notifier)
                        .updateIsMultiLotteryFilter(value);
                    ref
                        .read(lotteryProvider.notifier)
                        .updateLoadState(LoadState.none);
                  },
          ),
        ),
      ],
    );
  }
}
