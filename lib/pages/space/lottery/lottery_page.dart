import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/space/lottery_provider.dart';
import 'package:bilihelper/models/user/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class LotteryPage extends ConsumerStatefulWidget {
  const LotteryPage({super.key});

  @override
  ConsumerState<LotteryPage> createState() => _LotteryPageState();
}

class _LotteryPageState extends ConsumerState<LotteryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 50,
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange[300]!,
                      offset: Offset(0, 1),
                      blurRadius: 1.0,
                    ),
                  ],
                ),
                child: Center(
                  child: Consumer(
                    builder: (context, ref, child) => Text(
                      '已获取抽奖\n${ref.watch(lotteryProvider).count}/${UserModel().lotteryItems.length}',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, child) {
                  final lotteryState = ref.watch(lotteryProvider);
                  return IconButton(
                    icon: Icon(Icons.refresh),
                    tooltip: '开始抽奖',
                    onPressed: lotteryState.loadState == LoadState.loading
                        ? null
                        : () async {
                            ref
                                .read(lotteryProvider.notifier)
                                .updateLoadStatus(LoadState.loading);
                            await ref
                                .read(lotteryProvider.notifier)
                                .startLottery();
                          },
                    highlightColor: Colors.pink[100],
                    hoverColor: Colors.pink[50],
                  );
                },
              ),
            ],
          ),
          Expanded(
            child: SfDataGrid(
              source: ref.read(lotteryProvider.notifier).lotteryDataSource,
              headerGridLinesVisibility: GridLinesVisibility.horizontal,
              gridLinesVisibility: GridLinesVisibility.horizontal,
              columnWidthMode: ColumnWidthMode.fill,
              selectionMode: SelectionMode.single,
              rowHeight: 25,
              headerRowHeight: 30,
              allowSorting: true,
              columns: [
                GridColumn(
                  columnName: 'business_id',
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '抽奖动态ID',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'mid',
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'UID',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),

                GridColumn(
                  columnName: 'name',
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '用户名',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'followed',
                  allowSorting: false,
                  width: 80,
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '关注',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'lottery_time',
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '开奖时间',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'isForward',
                  allowSorting: false,
                  width: 80,
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '转发/预约',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),

                GridColumn(
                  columnName: 'lotteryType',
                  allowSorting: false,
                  width: 80,
                  label: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '抽奖类型',
                      style: TextStyle(fontFamily: 'Noto Sans SC'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
