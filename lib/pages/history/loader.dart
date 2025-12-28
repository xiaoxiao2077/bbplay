import 'dart:async';
import 'package:loading_more_list/loading_more_list.dart';

import '/utils/loggy.dart';
import '/model/video/item.dart';
import '/service/history_service.dart';

class HistoryLoader extends LoadingMoreBase<VideoItem> {
  int _pageIndex = 1;
  bool _hasMore = true;
  List<VideoItem> historyList = <VideoItem>[];

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
    bool isSuccess = false;
    try {
      List res = await HistoryService.search('', offset: 0, limit: 100);
      if (_pageIndex == 1) {
        clear();
        historyList.clear();
      }
      for (Map<String, dynamic> item in res) {
        VideoItem history = VideoItem.fromJson(item);
        if (!contains(history) && hasMore) {
          add(history);
          historyList.add(history);
        }
      }
      _hasMore = true; // 假设还有更多数据
      _pageIndex++;
      isSuccess = true;
    } catch (exception, stack) {
      isSuccess = false;
      Loggy.e(exception, stack);
    }
    return isSuccess;
  }

  void selectAll(bool isChecked) {
    for (VideoItem item in historyList) {
      item.checked = isChecked;
    }
  }

  void toggleChecked(VideoItem item) {
    item.checked = !item.checked;
  }

  int get checkedCount {
    int checkedCount = 0;
    for (VideoItem item in historyList) {
      if (item.checked) {
        checkedCount++;
      }
    }
    return checkedCount;
  }

  // 删除选中的记录
  Future deleteChecked() async {
    try {
      List<VideoItem> checkedList =
          historyList.where((item) => item.checked).toList();
      for (VideoItem item in checkedList) {
        await HistoryService.delete(item.bvid, item.cid);
        remove(item);
        historyList.remove(item);
      }
    } catch (exception, stack) {
      Loggy.e('deleteChecked', exception, stack);
    }
  }
}
