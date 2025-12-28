import 'dart:async';
import 'package:loading_more_list/loading_more_list.dart';
import '/service/search_service.dart';
import '/model/video/item.dart';

/// 搜索数据加载器
class SearchLoader extends LoadingMoreBase<VideoItem> {
  int _pageIndex = 1;
  bool _hasMore = true;
  final String keyword;

  SearchLoader({required this.keyword});

  @override
  bool get hasMore => _hasMore;

  @override
  Future<bool> refresh([bool notifyStateChanged = true]) async {
    _hasMore = true;
    _pageIndex = 1;
    return await super.refresh(notifyStateChanged);
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    try {
      final response = await SearchService.searchByType(
        keyword: keyword,
        page: _pageIndex,
      );

      if (!response.success) {
        _handleErrorResponse(response.message);
        return false;
      }

      // 如果是第一页，清空现有数据
      if (_pageIndex == 1) {
        clear();
      }

      final videoItems = response.data;

      // 处理空数据情况
      if (_isNullOrEmpty(videoItems)) {
        _hasMore = false;
        return true;
      }

      // 添加新数据
      final itemsAdded = _addNewItems(videoItems!);

      // 更新分页状态
      _updatePaginationState(itemsAdded);

      return true;
    } catch (exception, stackTrace) {
      _handleException(exception, stackTrace);
      return false;
    }
  }

  /// 检查视频列表是否为空或null
  bool _isNullOrEmpty(List<VideoItem>? items) {
    return items == null || items.isEmpty;
  }

  /// 添加新项目到列表中
  bool _addNewItems(List<VideoItem> items) {
    bool itemsAdded = false;

    for (final item in items) {
      if (!contains(item) && hasMore) {
        add(item);
        itemsAdded = true;
      }
    }

    return itemsAdded;
  }

  /// 更新分页状态
  void _updatePaginationState(bool hasNewItems) {
    _hasMore = hasNewItems;
    if (_hasMore) {
      _pageIndex++;
    }
  }

  /// 处理错误响应
  void _handleErrorResponse(String? message) {
    print('搜索失败: $message');
  }

  /// 处理异常
  void _handleException(Object exception, StackTrace stackTrace) {
    print('搜索异常: $exception');
    print(stackTrace);
  }
}
