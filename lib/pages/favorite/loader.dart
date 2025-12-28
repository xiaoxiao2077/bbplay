import 'dart:async';
import 'package:loading_more_list/loading_more_list.dart';

import '/model/video/item.dart';
import '/service/favorite_service.dart';

class FavoriteLoader extends LoadingMoreBase<VideoItem> {
  int _pageIndex = 1;
  bool _hasMore = true;
  static const int _pageSize = 10;

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
    final results = await FavoriteService.search(
      '',
      offset: (_pageIndex - 1) * _pageSize,
      limit: _pageSize,
    );

    if (_pageIndex == 1) {
      clear();
    }

    for (final item in results) {
      final favorite = VideoItem.fromJson(item);
      if (!contains(favorite) && hasMore) {
        add(favorite);
      }
    }

    _hasMore = results.length >= _pageSize;
    if (_hasMore) {
      _pageIndex++;
    }

    return true;
  }

  /// 选择所有项目
  void selectAll(bool checked) {
    for (final item in this) {
      item.checked = checked;
    }
  }

  /// 获取选中项目的数量
  int get checkedCount {
    int count = 0;
    for (final item in this) {
      if (item.checked) {
        count++;
      }
    }
    return count;
  }

  /// 删除选中的项目
  Future<void> deleteChecked() async {
    final itemsToDelete = <VideoItem>[];

    for (final item in this) {
      if (item.checked) {
        await FavoriteService.delete(item.bvid);
        itemsToDelete.add(item);
      }
    }

    for (final item in itemsToDelete) {
      remove(item);
    }
  }

  int get currentPage => _pageIndex;

  int get loadedCount => length;

  bool get isFirstPage => _pageIndex == 1;

  void reset() {
    _pageIndex = 1;
    _hasMore = true;
    clear();
  }
}
