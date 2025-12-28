import '/utils/loggy.dart';
import '/utils/dbhelper.dart';
import '/model/video/item.dart';
import '/service/base_service.dart';

class HistoryService {
  static const String tableName = 'history';

  /// 添加历史记录
  static Future<void> add(VideoItem item, int cid, int page) async {
    if (!await _exist(item.bvid, cid)) {
      await DBHelper.dbh.insert(tableName, {
        'bvid': item.bvid,
        'cid': cid,
        'title': item.title,
        'cover': item.cover,
        'duration': item.duration,
        'seek': 0,
        'author': item.author,
        'page': page,
        'is_liked': 0,
        'is_collected': 0,
      });
    }
  }

  /// 设置播放进度
  static Future<void> setSeek({
    required String bvid,
    required int cid,
    required Duration seek,
  }) async {
    await DBHelper.dbh.update(
      tableName,
      {'seek': seek.inSeconds, 'updated': DateTime.now().toString()},
      where: 'bvid = ? AND cid = ?',
      whereArgs: [bvid, cid],
    );
  }

  /// 删除历史记录
  static Future<bool> delete(String bvid, int cid) async {
    try {
      await DBHelper.dbh.delete(
        tableName,
        where: 'bvid = ? AND cid = ?',
        whereArgs: [bvid, cid],
      );
      _remoteDelete(bvid, cid);
      return true;
    } catch (e) {
      Loggy.e("Delete history failed", e);
      return false;
    }
  }

  /// 检查历史记录是否存在
  static Future<bool> _exist(String bvid, int cid) async {
    var result = await DBHelper.dbh.query(
      tableName,
      where: 'bvid = ? AND cid = ?',
      whereArgs: [bvid, cid],
    );
    return result.isNotEmpty;
  }

  /// 获取历史记录
  static Future<VideoItem?> fetch(String bvid, int cid) async {
    var result = await DBHelper.dbh.query(
      tableName,
      where: 'bvid = ? AND cid = ?',
      whereArgs: [bvid, cid],
    );
    if (result.isEmpty) {
      return null;
    }
    return VideoItem.fromHistory(result.first);
  }

  /// 获取所有历史记录的播放进度
  static Future<Map<String, double>> fetchSeekAll(List<String> bvidList) async {
    try {
      if (bvidList.isEmpty) {
        return {};
      }
      var list = await DBHelper.dbh.query(
        tableName,
        where: 'bvid IN (${List.filled(bvidList.length, '?').join(',')})',
        whereArgs: bvidList,
      );

      var result = <String, double>{};
      for (var item in list) {
        result[item['bvid'] as String] = item['seek'] as double;
      }
      return result;
    } catch (e) {
      Loggy.e("Fetch all seek failed", e);
      return <String, double>{};
    }
  }

  /// 删除所有历史记录
  static Future<bool> deleteAll() async {
    try {
      await DBHelper.dbh.delete(tableName);
      return true;
    } catch (e) {
      Loggy.e("Delete all history failed", e);
      return false;
    }
  }

  /// 搜索历史记录
  static Future<List<Map<String, dynamic>>> search(
    String? keyword, {
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      List<String> where = ['page = ?'];
      List<dynamic> whereArgs = [1];

      if (keyword != null && keyword.isNotEmpty) {
        where.add('title LIKE ?');
        whereArgs.add('%$keyword%');
      }

      return await DBHelper.dbh.query(tableName,
          where: where.join(' AND '),
          whereArgs: whereArgs,
          limit: limit,
          offset: offset,
          orderBy: 'updated DESC');
    } catch (e) {
      Loggy.e("Search history failed", e);
      return [];
    }
  }

  /// 获取搜索结果数量
  static Future<int> searchCount(String? keyword) async {
    try {
      List<String> where = ['page = ?'];
      List<dynamic> whereArgs = [1];

      if (keyword != null && keyword.isNotEmpty) {
        where.add('title LIKE ?');
        whereArgs.add('%$keyword%');
      }

      var result = await DBHelper.dbh.rawQuery(
        'SELECT COUNT(*) as count FROM $tableName WHERE ${where.join(' AND ')}',
        whereArgs,
      );
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      Loggy.e("Search count failed", e);
      return 0;
    }
  }

  /// 从服务器同步最近的历史数据
  static Future<ApiResponse<List<VideoItem>>> syncLatestFromServer() async {
    try {
      final client = await BaseService.getBaseClient();
      final response = await BaseService.get<List<VideoItem>>(
        client,
        '/api/history/load',
        parser: (data) {
          final listData = data['data']?['list'];
          final historyList = <VideoItem>[];

          if (listData is List) {
            for (var item in listData) {
              if (item is Map<String, dynamic>) {
                historyList.add(VideoItem.fromJson(item));
              }
            }
          }
          return historyList;
        },
      );
      return response;
    } catch (e) {
      Loggy.e("Sync history from server failed", e);
      return ApiResponse.error('同步历史记录失败: $e');
    }
  }

  /// 提交历史记录到远程服务器
  static Future<void> _remoteSubmit(VideoItem item) async {
    try {
      var param = item.toJson();
      final client = await BaseService.getBaseClient();
      await BaseService.post<bool>(
        client,
        '/api/history/submit',
        data: param,
      );
    } catch (e) {
      Loggy.e("Remote submit failed", e);
    }
  }

  /// 删除远程历史记录
  static Future _remoteDelete(String bvid, int cid) async {
    try {
      final client = await BaseService.getBaseClient();
      final response = await BaseService.post<bool>(
        client,
        '/api/history/delete',
        data: {'bvid': bvid, 'cid': cid},
      );
      return response;
    } catch (e) {
      Loggy.e("Remote delete failed", e);
    }
  }

  /// 点赞视频
  static Future<void> like({required String bvid, required int cid}) async {
    await DBHelper.dbh.update(
      tableName,
      {'is_liked': 1},
      where: 'bvid = ? AND cid = ?',
      whereArgs: [bvid, cid],
    );
  }

  /// 点踩视频
  static Future<void> dislike({required String bvid, required int cid}) async {
    await DBHelper.dbh.update(
      tableName,
      {'is_liked': -1},
      where: 'bvid = ? AND cid = ?',
      whereArgs: [bvid, cid],
    );
  }

  /// 获取未收集且更新时间在3分钟前的历史记录
  static Future<List<Map<String, dynamic>>> fetchUnCollected(int psize) async {
    final result = await DBHelper.dbh.query(
      tableName,
      where: 'is_collected = ? ',
      whereArgs: [0],
      limit: psize,
    );
    return result;
  }

  /// 同步未收集的历史记录到服务器
  static Future<void> syncUnCollectedToServer() async {
    try {
      final uncollectedRecords = await fetchUnCollected(10);
      for (var record in uncollectedRecords) {
        try {
          final videoItem = VideoItem.fromHistory(record);
          await _remoteSubmit(videoItem);
          await markCollected(record['bvid'] as String, videoItem.cid);
        } catch (e) {
          Loggy.e("Sync single uncollected record failed", e);
          continue;
        }
      }
    } catch (e) {
      Loggy.e("Sync uncollected history to server failed", e);
    }
  }

  /// 标记历史记录为已收集
  static Future<void> markCollected(String bvid, int cid) async {
    await DBHelper.dbh.update(
      tableName,
      {'is_collected': 1},
      where: 'bvid = ? AND cid = ?',
      whereArgs: [bvid, cid],
    );
  }
}
