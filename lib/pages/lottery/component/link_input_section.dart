import 'dart:developer';

import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/lottery/lottery_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LinkInputSection extends ConsumerStatefulWidget {
  const LinkInputSection({super.key});

  @override
  ConsumerState<LinkInputSection> createState() => _LinkInputSectionState();
}

class _LinkInputSectionState extends ConsumerState<LinkInputSection> {
  final _linkController = TextEditingController();
  @override
  void initState() {
    log('LinkInputSection initState');
    _linkController.text = ref.read(lotteryProvider).link;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      lotteryProvider.select((state) => state.loadState == LoadState.loading),
    );
    ref.listen(lotteryProvider.select((state) => state.link), (
      previous,
      current,
    ) {
      if (_linkController.text != current) {
        _linkController.text = current;
      }
    });
    return Container(
      alignment: Alignment.center,
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              key: ValueKey('linkInputField'),
              controller: _linkController,
              enabled: !isLoading,
              decoration: InputDecoration(
                labelText: '抽奖动态或视频链接',
                floatingLabelStyle: TextStyle(
                  color: Colors.pink[200],
                  fontSize: 18,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    ref.read(lotteryProvider.notifier).updateLink('');
                  },
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink[200]!),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink[200]!),
                  borderRadius: BorderRadius.circular(5),
                ),
                errorStyle: TextStyle(height: 0, fontSize: 0),
              ),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (RegExp(
                      r'https://www.bilibili.com/opus/\d+',
                    ).hasMatch(value!) ||
                    RegExp(
                      r'https://www.bilibili.com/video/BV\w+',
                    ).hasMatch(value)) {
                  return null;
                }
                return 'error';
              },
              onChanged: (value) {
                ref.read(lotteryProvider.notifier).updateLink(value);
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10),
            child: IconButton(
              icon: Icon(Icons.content_paste),
              tooltip: '粘贴',
              onPressed:
                  ref.watch(lotteryProvider).loadState != LoadState.loading
                  ? () async {
                      await Clipboard.getData(Clipboard.kTextPlain).then((
                        value,
                      ) {
                        if (value != null) {
                          ref
                              .read(lotteryProvider.notifier)
                              .updateLink(value.text!);
                        }
                      });
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
