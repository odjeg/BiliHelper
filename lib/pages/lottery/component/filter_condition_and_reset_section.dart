import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/lottery/lottery_provider.dart';
import 'package:bilihelper/models/lottery/providers.dart/lottery_level_filter_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterConditionAndResetSection extends ConsumerStatefulWidget {
  const FilterConditionAndResetSection({super.key});

  @override
  ConsumerState<FilterConditionAndResetSection> createState() =>
      _FilterConditionAndResetSectionState();
}

class _FilterConditionAndResetSectionState
    extends ConsumerState<FilterConditionAndResetSection> {
  // 存储按钮 hover 状态（支持刷新）
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // 🔥 用 watch 监听加载状态，自动刷新UI（必须用watch）
    final isLoading = ref.watch(
      lotteryProvider.select((state) => state.loadState == LoadState.loading),
    );
    return Row(
      children: [
        Icon(Icons.filter_alt_outlined, color: Colors.pink[200]),
        const SizedBox(width: 10),
        const Text(
          '筛选条件',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        // 重置筛选按钮
        MouseRegion(
          // 加载中 → 禁用 hover
          onHover: isLoading
              ? null
              : (event) {
                  setState(() => _isHovered = true);
                },
          onExit: isLoading
              ? null
              : (event) {
                  setState(() => _isHovered = false);
                },
          child: GestureDetector(
            // 加载中 → 禁用点击
            onTap: isLoading
                ? null
                : () {
                    ref.read(lotteryLevelFilterProvider.notifier).reset();
                    // 点击后重置 hover 状态
                    setState(() => _isHovered = false);
                  },
            child: Text(
              "重置筛选",
              style: TextStyle(
                color: isLoading
                    ? Colors.grey[300] // 加载中：置灰不可用
                    : (_isHovered
                          ? Colors.pink[200]
                          : Colors.grey), // 正常：hover变色
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
