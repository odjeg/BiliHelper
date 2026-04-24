import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/lottery/lottery_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContentConditionSection extends ConsumerStatefulWidget {
  const ContentConditionSection({super.key});

  @override
  ConsumerState<ContentConditionSection> createState() =>
      _ContentConditionSectionState();
}

class _ContentConditionSectionState
    extends ConsumerState<ContentConditionSection> {
  final _keyWorldFilterController = TextEditingController();
  @override
  void initState() {
    _keyWorldFilterController.text = ref.read(lotteryProvider).keyWorldFilter;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      lotteryProvider.select((state) => state.loadState == LoadState.loading),
    );

    ref.listen<String>(lotteryProvider.select((s) => s.keyWorldFilter), (
      previous,
      current,
    ) {
      if (_keyWorldFilterController.text != current) {
        _keyWorldFilterController.text = current;
      }
    });

    return Row(
      children: [
        Icon(Icons.message, color: Colors.grey, size: 15),
        SizedBox(width: 5),
        Text('内容与互动', style: TextStyle(fontSize: 13, color: Colors.grey)),
        SizedBox(width: 5),
        SizedBox(
          width: 500,
          child: TextField(
            controller: _keyWorldFilterController,
            enabled: !isLoading,
            onChanged: (value) {
              ref.read(lotteryProvider.notifier).updateKeyWorldFilter(value);
            },

            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: '包含关键词（不区分大小写）',

              labelStyle: TextStyle(fontSize: 13),
              floatingLabelStyle: TextStyle(color: Colors.pink[200]),
              isDense: true,
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.pink[200]!),
                borderRadius: BorderRadius.circular(5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.close, size: 18),
                onPressed: () {
                  _keyWorldFilterController.clear();
                  ref.read(lotteryProvider.notifier).updateKeyWorldFilter('');
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
