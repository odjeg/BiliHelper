import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/lottery/lottery_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MultiAwardSection extends ConsumerStatefulWidget {
  const MultiAwardSection({super.key});
  @override
  ConsumerState<MultiAwardSection> createState() => _MultiAwardSectionState();
}

class _MultiAwardSectionState extends ConsumerState<MultiAwardSection> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      lotteryProvider.select((state) => state.loadState == LoadState.loading),
    );
    final prizeItems = ref.watch(
      lotteryProvider.select((state) => state.prizeItems),
    );
    final prizeControllers = prizeItems
        .map(
          (e) => (
            TextEditingController.fromValue(
              TextEditingValue(
                text: e.$1,
                selection: TextSelection.collapsed(offset: e.$1.length),
              ),
            ),
            TextEditingController.fromValue(
              TextEditingValue(
                text: e.$2.toString(),
                selection: TextSelection.collapsed(
                  offset: e.$2.toString().length,
                ),
              ),
            ),
          ),
        )
        .toList();
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        for (int i = 0; i < prizeControllers.length; i++)
          Container(
            padding: EdgeInsets.only(left: 15),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cake, size: 17, color: Colors.blue[300]),
                SizedBox(width: 5),
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 30),
                    child: TextField(
                      enabled: !isLoading,
                      controller: prizeControllers[i].$1,

                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        ref
                            .read(lotteryProvider.notifier)
                            .updatePrizeName(i, value);
                      },
                    ),
                  ),
                ),
                SizedBox(width: 5),
                IntrinsicWidth(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 30),
                    child: TextField(
                      enabled: !isLoading,
                      controller: prizeControllers[i].$2,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 4),
                      ),
                      onChanged: (value) {
                        if (int.tryParse(value) != null &&
                            int.tryParse(value)! > 0) {
                          ref
                              .read(lotteryProvider.notifier)
                              .updatePrizeCount(i, int.parse(value));
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(width: 5),
                IconButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          prizeControllers.removeAt(i);
                          ref.read(lotteryProvider.notifier).removePrizeItem(i);
                        },
                  icon: Icon(Icons.delete_outline),
                ),
              ],
            ),
          ),
        Container(
          key: ValueKey('addMulLottery'),
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: _isHovered ? Colors.pink[300]! : Colors.grey[300]!,
            ),
          ),
          child: InkWell(
            onHover: isLoading
                ? null
                : (event) => setState(() {
                    _isHovered = event;
                  }),
            onTap: isLoading
                ? null
                : () {
                    ref.read(lotteryProvider.notifier).addPrizeItem(('新奖项', 1));
                  },
            child: SizedBox.expand(
              child: Icon(
                Icons.add,
                size: 30,
                color: _isHovered ? Colors.pink[300] : Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
