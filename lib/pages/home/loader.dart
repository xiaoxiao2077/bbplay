import 'dart:async';
import 'package:loading_more_list/loading_more_list.dart';

import '/model/video/item.dart';
import '/service/video_service.dart';
import '/service/favorite_service.dart';

class RecmdLoader extends LoadingMoreBase<VideoItem> {
  int _pageIndex = 1;
  bool _hasMore = true;
  static const int _pageSize = 6;
  bool _loadedFavorites = false;

  @override
  bool get hasMore => _hasMore;

  @override
  Future<bool> refresh([bool notifyStateChanged = true]) async {
    _hasMore = true;
    _pageIndex = 1;
    _loadedFavorites = false;
    clear();
    return await super.refresh(notifyStateChanged);
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    if (!hasMore) {
      return true;
    }

    if (_pageIndex > 1 && !_loadedFavorites) {
      return _loadFromLocal();
    } else {
      return _loadFromServer();
    }
  }

  Future<bool> _loadFromServer() async {
    final response = await VideoService.loadRcmdList(
      psize: _pageSize,
      page: _pageIndex,
    );

    if (response.success && response.data != null) {
      final List<VideoItem> newItems = response.data!;

      for (final VideoItem item in newItems) {
        if (!contains(item)) {
          add(item);
        }
      }
      _hasMore = newItems.length >= _pageSize;
      if (_hasMore) {
        _pageIndex++;
      }
      return true;
    } else {
      _hasMore = false;
      return false;
    }
  }

  Future<bool> _loadFromLocal() async {
    final favorites = await FavoriteService.search(
      null,
      offset: 0,
      limit: _pageSize,
    );

    final List<VideoItem> favoriteItems =
        favorites.map((item) => VideoItem.fromFavorite(item)).toList();

    for (final VideoItem item in favoriteItems) {
      if (!contains(item)) {
        add(item);
      }
    }
    _loadedFavorites = true;
    return true;
  }

  // 重置加载器状态
  void reset() {
    _pageIndex = 1;
    _hasMore = true;
    _loadedFavorites = false;
    clear();
  }

  int get currentPage => _pageIndex;

  int get loadedCount => length;

  bool get isFirstPage => _pageIndex == 1;
}
