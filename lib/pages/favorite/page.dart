import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import './loader.dart';
import '/utils/function.dart';
import '/model/video/item.dart';
import '/widgets/horizon_listtile.dart';
import '/widgets/loading_more_indicator.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<StatefulWidget> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late final FavoriteLoader dataLoader = FavoriteLoader();
  bool _selectMode = false;
  bool _selectAll = false;

  @override
  void dispose() {
    dataLoader.dispose();
    super.dispose();
  }

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) {
        _selectAll = false;
      }
    });
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _selectAll = value ?? false;
      dataLoader.selectAll(_selectAll);
    });
  }

  Future<void> _handleDeleteSelected() async {
    setState(() {
      dataLoader.deleteChecked();
      _selectMode = false;
      _selectAll = false;
    });
  }

  Future<void> _handleClearAll() async {
    final confirm = await showConfirmDialog(
      context,
      title: '提示',
      content: '确定清空收藏记录吗？',
    );

    if (confirm) {
      setState(() => dataLoader.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_selectMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectMode) {
          setState(() => _selectMode = false);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        bottomNavigationBar: _buildBottomBar(),
        body: RefreshIndicator(
          onRefresh: () => dataLoader.refresh(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(3, 10, 3, 0),
            child: LoadingMoreList<VideoItem>(
              ListConfig<VideoItem>(
                itemBuilder: _buildListItem,
                sourceList: dataLoader,
                physics: const FixedOverscrollBouncingScrollPhysics(),
                padding: const EdgeInsets.all(2.0),
                autoRefresh: true,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 460,
                  childAspectRatio: 4.19,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                indicatorBuilder: (context, status) => LoadingMoreIndicator(
                  status: status,
                  loadingMoreBase: dataLoader,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('收藏'),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_outlined),
          position: PopupMenuPosition.under,
          onSelected: (String value) {
            switch (value) {
              case 'select':
                _toggleSelectMode();
                break;
              case 'clear':
                _handleClearAll();
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'select',
              child: Text('多选删除'),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Text('清空记录'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildListItem(BuildContext context, VideoItem item, int index) {
    return HorizonListTile(
      item: item,
      selectMode: _selectMode,
      onTab: (VideoItem item) {
        if (_selectMode) {
          setState(() {
            item.checked = !item.checked;
          });
        }
      },
      onLongPress: _toggleSelectMode,
      onSelect: (VideoItem item) {},
    );
  }

  Widget _buildBottomBar() {
    if (!_selectMode) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 60,
      color: Colors.white54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Checkbox(
                value: _selectAll,
                onChanged: _toggleSelectAll,
                activeColor: Colors.blue,
              ),
              const Text('全选'),
            ],
          ),
          TextButton.icon(
            onPressed: _handleDeleteSelected,
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('删除'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
              backgroundColor: Colors.red.withValues(alpha: 0.01),
            ),
          ),
        ],
      ),
    );
  }
}
