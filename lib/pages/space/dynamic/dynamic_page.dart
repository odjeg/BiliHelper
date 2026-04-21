import 'package:bilihelper/common/constants/load_state.dart';
import 'package:bilihelper/models/space/dynamic_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DynamicPage extends ConsumerStatefulWidget {
  const DynamicPage({super.key});

  @override
  ConsumerState<DynamicPage> createState() => _DynamicPageState();
}

class _DynamicPageState extends ConsumerState<DynamicPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final DataGridController dataGridController = DataGridController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFollowingActionBar(),
          Expanded(child: _buildDynamicSfDataGrid()),
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
                color: Colors.red[300]!,
                offset: Offset(0, 1),
                blurRadius: 1.0,
              ),
            ],
          ),
          child: Center(
            child: Consumer(
              builder: (context, ref, child) {
                final count = ref.watch(
                  dynamicProvider.select((state) => state.count),
                );
                return Text(textAlign: TextAlign.center, '已获取动态\n$count');
              },
            ),
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            final isLoading = ref.watch(
              dynamicProvider.select(
                (state) => state.loadState == LoadState.loading,
              ),
            );
            return IconButton(
              icon: Icon(Icons.refresh),
              tooltip: '刷新动态列表',
              onPressed: isLoading
                  ? null
                  : () async {
                      ref.read(dynamicProvider.notifier).initDynamicInfo();
                    },
            );
          },
        ),
        Consumer(
          builder: (context, ref, child) {
            final isLoading = ref.watch(
              dynamicProvider.select(
                (state) => state.loadState == LoadState.loading,
              ),
            );
            return IconButton(
              icon: Icon(Icons.delete_outline),
              tooltip: '删除选中动态',
              onPressed: isLoading
                  ? null
                  : () async {
                      await ref
                          .read(dynamicProvider.notifier)
                          .deleteSelectedDynamic(dataGridController);
                    },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDynamicSfDataGrid() {
    return SfDataGrid(
      source: ref.read(dynamicProvider.notifier).dynamicDataSource,
      controller: dataGridController,
      headerGridLinesVisibility: GridLinesVisibility.horizontal,
      gridLinesVisibility: GridLinesVisibility.horizontal,
      columnWidthMode: ColumnWidthMode.fill,
      selectionMode: SelectionMode.multiple,
      rowHeight: 25,
      headerRowHeight: 30,
      allowSorting: true,
      columns: [
        //根据UserDynamicInfo的字段，添加列
        GridColumn(
          columnName: 'id_str',
          label: Container(
            alignment: Alignment.center,
            child: Text('动态ID', style: TextStyle(fontFamily: 'Noto Sans SC')),
          ),
        ),
        GridColumn(
          columnName: 'pub_ts',
          label: Container(
            alignment: Alignment.center,
            child: Text('转发时间', style: TextStyle(fontFamily: 'Noto Sans SC')),
          ),
        ),
        GridColumn(
          columnName: 'orig_id_str',
          label: Container(
            alignment: Alignment.center,
            child: Text('转发动态ID', style: TextStyle(fontFamily: 'Noto Sans SC')),
          ),
        ),
        GridColumn(
          columnName: 'orig_mid',
          label: Container(
            alignment: Alignment.center,
            child: Text(
              '转发用户UID',
              style: TextStyle(fontFamily: 'Noto Sans SC'),
            ),
          ),
        ),
        GridColumn(
          columnName: 'orig_name',
          label: Container(
            alignment: Alignment.center,
            child: Text('转发用户名', style: TextStyle(fontFamily: 'Noto Sans SC')),
          ),
        ),
        GridColumn(
          allowSorting: false,
          width: 50,
          columnName: 'following',
          label: Container(
            alignment: Alignment.center,
            child: Text('关注', style: TextStyle(fontFamily: 'Noto Sans SC')),
          ),
        ),
        GridColumn(
          allowSorting: false,
          width: 80,
          columnName: 'dynamic_text',
          label: Container(
            alignment: Alignment.center,
            child: Text('动态类型', style: TextStyle(fontFamily: 'Noto Sans SC')),
          ),
        ),
      ],
    );
  }
}
