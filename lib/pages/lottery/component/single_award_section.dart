import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/lottery/lottery_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SingleAwardSection extends ConsumerStatefulWidget {
  const SingleAwardSection({super.key});
  @override
  ConsumerState<SingleAwardSection> createState() => _SingleAwardSectionState();
}

class _SingleAwardSectionState extends ConsumerState<SingleAwardSection> {
  final _countController = TextEditingController();

  @override
  void initState() {
    _countController.text = ref.read(lotteryProvider).count.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      lotteryProvider.select((state) => state.loadState == LoadState.loading),
    );
    ref.listen<int>(lotteryProvider.select((s) => s.count), (
      previous,
      current,
    ) {
      if (_countController.text != current.toString()) {
        _countController.text = current.toString();
        ref
            .read(lotteryProvider.notifier)
            .updateCount(int.parse(_countController.text));
      }
    });
    return Row(
      children: [
        Icon(
          Icons.settings_accessibility_rounded,
          color: Colors.grey,
          size: 15,
        ),
        SizedBox(width: 5),
        Text('抽取人数', style: TextStyle(fontSize: 13, color: Colors.grey)),
        SizedBox(width: 5),
        SizedBox(
          width: 200,
          height: 40,
          child: TextFormField(
            enabled: !isLoading,
            controller: _countController,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: '抽取人数',
              isDense: true,
              labelStyle: TextStyle(fontSize: 13),
              floatingLabelStyle: TextStyle(color: Colors.pink[200]),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.pink[200]!),
                borderRadius: BorderRadius.circular(5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              errorStyle: TextStyle(height: 0, fontSize: 0),
              errorText: null,
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (value) {
              if (int.tryParse(value) != null && int.tryParse(value)! > 0) {
                ref
                    .read(lotteryProvider.notifier)
                    .updateCount(int.parse(value));
              }
            },
            validator: (value) {
              if (value == null ||
                  value.isEmpty ||
                  int.tryParse(value) == null ||
                  int.tryParse(value)! <= 0) {
                return '请输入抽取人数';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
