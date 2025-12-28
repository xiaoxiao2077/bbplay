import 'dart:async';
import 'package:loading_more_list/loading_more_list.dart';

import '/model/video/item.dart';
import '/service/search_service.dart';

class SearchLoader extends LoadingMoreBase<VideoItem> {
  SearchLoader({required this.keyword});

  int _pageIndex = 1;
  bool _hasMore = true;
  final String keyword;

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
    final response = await SearchService.searchByType(
      keyword: keyword,
      page: _pageIndex,
    );

    if (response.success && response.data != null) {
      final List<VideoItem> newItems = response.data!;
      if (_pageIndex == 1) {
        clear();
      }

      for (final VideoItem item in newItems) {
        if (!contains(item)) {
          add(item);
        }
      }

      // 更新是否有更多数据的标志
      _hasMore = newItems.isNotEmpty;
      _pageIndex++;
      return true;
    } else {
      _hasMore = false;
      return false;
    }
  }
}
