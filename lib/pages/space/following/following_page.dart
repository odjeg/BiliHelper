import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/space/following_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class FollowingPage extends ConsumerStatefulWidget {
  const FollowingPage({super.key});

  @override
  ConsumerState<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends ConsumerState<FollowingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFollowingActionBar(),
          Expanded(child: _buildFollowingSfDataGrid()),
        ],
      ),
    );
  }

  Widget _buildFollowingActionBar() {
    return Row(
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
                color: Colors.purple[300]!,
                offset: Offset(0, 1),
                blurRadius: 1.0,
              ),
            ],
          ),
          child: Center(
            child: Consumer(
              builder: (context, ref, child) {
                final total = ref.watch(
                  followingProvider.select((state) => state.total),
                );
                final count = ref.watch(
                  followingProvider.select((state) => state.count),
                );

                return Text(
                  '全部关注\n${total == count ? total : '$count/$total'}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Noto Sans SC'),
                );
              },
            ),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final isLoading = ref.watch(
              followingProvider.select(
                (state) => state.loadState == LoadState.loading,
              ),
            );
            return IconButton(
              icon: Icon(Icons.refresh),
              tooltip: '刷新关注列表',
              onPressed: isLoading
                  ? null
                  : () async {
                      await ref
                          .read(followingProvider.notifier)
                          .initFollowingItems();
                    },
            );
          },
        ),
      ],
    );
  }

  Widget _buildFollowingSfDataGrid() {
    return SfDataGrid(
      key: ValueKey('followings_datagrid'),
      headerGridLinesVisibility: GridLinesVisibility.horizontal,
      gridLinesVisibility: GridLinesVisibility.horizontal,
      source: ref.read(followingProvider.notifier).followingDataSource,
      columnWidthMode: ColumnWidthMode.fill,
      selectionMode: SelectionMode.single,
      rowHeight: 25,
      headerRowHeight: 30,
      allowSorting: true,
      columns: [
        GridColumn(
          columnName: 'mid',
          label: Center(
            child: Text('UID', style: TextStyle(fontFamily: 'Noto Sans SC')),
          ),
        ),
        GridColumn(
          columnName: 'uname',
          label: Center(
            child: Text('用户名', style: TextStyle(fontFamily: 'Noto Sans SC')),
          ),
        ),
        GridColumn(
          columnName: 'mtime',
          label: Center(
            child: Text('关注时间', style: TextStyle(fontFamily: 'Noto Sans SC')),
          ),
        ),
        GridColumn(
          columnName: 'special',
          label: Center(
            child: Text('特别关注', style: TextStyle(fontFamily: 'Noto Sans SC')),
          ),
        ),
      ],
    );
  }
}
