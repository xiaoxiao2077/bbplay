import 'package:pager/pager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '/utils/navigate.dart';
import '/utils/function.dart';
import '/model/video/item.dart';
import '/service/history_service.dart';
import '/widgets/horizon_listtile.dart';

class DesktopHistoryPage extends StatefulWidget {
  const DesktopHistoryPage({super.key});

  @override
  State<DesktopHistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<DesktopHistoryPage> {
  List<VideoItem> historyList = [];
  final searchInput = TextEditingController();
  bool isSelecting = false;
  int currentPage = 1;
  int totalPage = 1;
  int totalCount = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData(page: 1);
    searchInput.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    searchInput.removeListener(_handleSearchChanged);
    searchInput.dispose();
    super.dispose();
  }

  int get selectingCount => historyList.where((item) => item.checked).length;

  void _handleSearchChanged() {
    _fetchData(page: 1);
  }

  Future<void> _fetchData({int page = 1}) async {
    if (isLoading) return;
    setState(() => isLoading = true);
    try {
      final keyword = searchInput.text;
      final offset = (page - 1) * 100;

      // 并行获取数据和总数
      final results = await Future.wait([
        HistoryService.search(keyword, offset: offset, limit: 100),
        HistoryService.searchCount(keyword),
      ]);

      final List<dynamic> dataList = List<dynamic>.from(results[0] as List);
      final int count = results[1] as int;

      final List<VideoItem> items =
          dataList.map((item) => VideoItem.fromHistory(item)).toList();

      setState(() {
        if (page == 1) {
          historyList.clear();
        }
        historyList.addAll(items);
        currentPage = page;
        totalCount = count;
        totalPage = count == 0 ? 1 : (count / 100).ceil();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      SmartDialog.showToast('加载失败: $e');
    }
  }

  void _toggleSelectAll() {
    final shouldSelectAll = selectingCount != historyList.length;
    setState(() {
      isSelecting = shouldSelectAll;
      for (final item in historyList) {
        item.checked = shouldSelectAll;
      }
    });
  }

  Future<void> _deleteSelected() async {
    if (selectingCount == 0) {
      SmartDialog.showToast('请先选择要删除的视频');
      return;
    }

    final bool confirmed = await showConfirmDialog(
      context,
      title: '确认删除',
      content: '确定要删除选中的$selectingCount个历史记录吗？',
      confirmText: '删除',
      cancelText: '取消',
    );

    if (confirmed) {
      try {
        final selectedItems =
            historyList.where((item) => item.checked).toList();

        // 批量删除
        for (var item in selectedItems) {
          await HistoryService.delete(item.bvid, item.cid);
        }

        setState(() {
          historyList.removeWhere((item) => item.checked);
          totalCount -= selectedItems.length;
          totalPage = totalCount == 0 ? 1 : (totalCount / 100).ceil();
          if (currentPage > totalPage) {
            currentPage = totalPage;
          }
        });

        SmartDialog.showToast('删除成功');
      } catch (e) {
        SmartDialog.showToast('删除失败: $e');
      }
    }
  }

  Future<void> _clearAllHistory() async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: '确认清空',
      content: '确定要清空所有历史记录吗？此操作不可恢复',
      confirmText: '清空',
      cancelText: '取消',
    );

    if (confirmed) {
      try {
        await HistoryService.deleteAll();

        setState(() {
          historyList.clear();
          totalCount = 0;
          currentPage = 1;
          totalPage = 1;
        });
        SmartDialog.showToast('清空成功');
      } catch (e) {
        SmartDialog.showToast('清空失败: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 234, 243, 239),
      appBar: AppBar(
        toolbarHeight: 1,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildActionToolbar(),
            const SizedBox(height: 16),
            if (historyList.isEmpty)
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildEmptyState(),
              )
            else
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 460,
                      childAspectRatio: 3.3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: historyList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: HorizonListTile(
                            item: historyList[index],
                            selectMode: isSelecting,
                            onTab: (item) {
                              if (isSelecting) {
                                setState(() => item.checked = !item.checked);
                              } else {
                                Navigate.goVideoPlay(context, item);
                              }
                            },
                            onSelect: (item) {
                              setState(() {
                                item.checked = !item.checked;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Pager(
                currentPage: currentPage,
                totalPages: totalPage,
                onPageChanged: (int page) {
                  _fetchData(page: page);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          const Text(
            '观看历史',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Container(
            constraints: const BoxConstraints(maxWidth: 300),
            child: _buildSearchField(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isSelecting
                  ? Colors.blue.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Theme(
                  data: Theme.of(context).copyWith(
                    unselectedWidgetColor: Colors.grey[600],
                  ),
                  child: Checkbox(
                    value: isSelecting,
                    onChanged: (value) {
                      setState(() {
                        isSelecting = value ?? false;
                        if (!isSelecting) {
                          for (final item in historyList) {
                            item.checked = false;
                          }
                        }
                      });
                    },
                    activeColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                  ),
                ),
                TextButton(
                  onPressed: _toggleSelectAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    selectingCount == historyList.length &&
                            historyList.isNotEmpty
                        ? '取消全选'
                        : '全选',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (isSelecting && selectingCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$selectingCount 项已选择',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const Spacer(),
          if (isSelecting)
            Row(
              children: [
                _buildActionButton(
                  icon: Icons.delete_outline,
                  label: '删除',
                  color: Colors.red,
                  onTap: _deleteSelected,
                ),
                const SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.cleaning_services_outlined,
                  label: '清空',
                  color: Colors.orange,
                  onTap: _clearAllHistory,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchInput,
        focusNode: FocusNode(),
        decoration: const InputDecoration(
          hintText: '搜索历史记录...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          prefixIconConstraints: BoxConstraints(minWidth: 40),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
        onSubmitted: (String value) {
          _fetchData(page: 1);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无观看历史',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
