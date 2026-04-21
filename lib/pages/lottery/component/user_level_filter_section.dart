import 'dart:developer';

import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/lottery/lottery_provider.dart';
import 'package:bilihelper/models/lottery/providers.dart/lottery_level_filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserLevelFilterSection extends ConsumerWidget {
  const UserLevelFilterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lvChoiceMap = ref.watch(lotteryLevelFilterProvider);

    final isLoading = ref.watch(
      lotteryProvider.select((s) => s.loadState == LoadState.loading),
    );
    log('isLoading: $isLoading');

    return Row(
      children: [
        const Icon(Icons.people_alt_outlined, color: Colors.grey, size: 15),
        const SizedBox(width: 5),
        const Text(
          '用户等级限制',
          style: TextStyle(fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(width: 5),
        for (final entry in lvChoiceMap.entries)
          ActionChip(
            key: ValueKey('lvChip_${entry.key}'),
            backgroundColor: entry.value ? Colors.pink[200] : Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            visualDensity: VisualDensity.compact,
            label: Text(entry.key),
            labelStyle: TextStyle(
              color: entry.value
                  ? (isLoading ? Colors.pink[500] : Colors.white)
                  : Colors.grey,
            ),
            onPressed: isLoading
                ? null
                : () {
                    // 点击时手动更新
                    ref
                        .read(lotteryLevelFilterProvider.notifier)
                        .toggle(entry.key);
                  },
          ),
      ],
    );
  }
}
