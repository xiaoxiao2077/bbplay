import 'dart:async';
import 'package:loading_more_list/loading_more_list.dart';

import '/model/video/item.dart';
import '/service/video_service.dart';

class SubjectVideoLoader extends LoadingMoreBase<VideoItem> {
  SubjectVideoLoader(this.subjectName);

  final String subjectName;
  int _pageIndex = 1;
  bool _hasMore = true;
  static const int _pageSize = 20;

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
    if (!hasMore) {
      return true;
    }

    final response = await VideoService.loadSubjectList(
      subjectName,
      page: _pageIndex,
      psize: _pageSize,
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

  // 重置加载器状态
  void reset() {
    _pageIndex = 1;
    _hasMore = true;
    clear();
  }

  int get loadedCount => length;
  int get currentPage => _pageIndex;
  bool get isFirstPage => _pageIndex == 1;
}
