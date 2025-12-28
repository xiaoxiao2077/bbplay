import 'dart:async';
import 'package:loading_more_list/loading_more_list.dart';

import '/model/video/item.dart';
import '/service/video_service.dart';
import '/service/favorite_service.dart';

class RcmdVideoLoader extends LoadingMoreBase<VideoItem> {
  RcmdVideoLoader();

  int _pageIndex = 1;
  bool _hasMore = true;
  static const int _pageSize = 8;
  bool _loadedFromFavorites = false;

  @override
  bool get hasMore => _hasMore;

  @override
  Future<bool> refresh([bool notifyStateChanged = true]) async {
    _hasMore = true;
    _pageIndex = 1;
    _loadedFromFavorites = false;
    clear();
    return await super.refresh(notifyStateChanged);
  }

  @override
  Future<bool> loadData([bool isLoadMoreAction = false]) async {
    if (!hasMore) {
      return true;
    }
    if (_pageIndex > 1 && !_loadedFromFavorites) {
      return _loadFromFavorites();
    } else {
      return _loadFromRecommendations();
    }
  }

  Future<bool> _loadFromRecommendations() async {
    final resp = await VideoService.loadRcmdList(
      psize: _pageSize,
      page: _pageIndex,
    );

    if (resp.success) {
      final List<VideoItem> videoItems = resp.data ?? [];
      _hasMore = videoItems.length >= _pageSize;
      for (final videoItem in videoItems) {
        if (!contains(videoItem)) {
          add(videoItem);
        }
      }
      if (_hasMore) {
        _pageIndex++;
      }
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _loadFromFavorites() async {
    final favorites = await FavoriteService.search(
      null,
      offset: 0,
      limit: _pageSize,
    );
    final List<VideoItem> favoriteItems =
        favorites.map((item) => VideoItem.fromFavorite(item)).toList();
    for (final videoItem in favoriteItems) {
      if (!contains(videoItem)) {
        add(videoItem);
      }
    }
    _loadedFromFavorites = true;
    return true;
  }

  // 重置加载器状态
  void reset() {
    _pageIndex = 1;
    _hasMore = true;
    _loadedFromFavorites = false;
    clear();
  }

  int get totalLoaded => length;
  int get currentPage => _pageIndex;
}
