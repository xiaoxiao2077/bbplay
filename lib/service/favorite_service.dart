import '/utils/dbhelper.dart';
import '/model/video/item.dart';
import '/service/base_service.dart';

class FavoriteService extends BaseService {
  static Future<bool> add(VideoItem item) async {
    if (!await exist(item.bvid)) {
      await DBHelper.dbh.insert('favorite', {
        'bvid': item.bvid,
        'cid': item.cid,
        'title': item.title,
        'cover': item.cover,
        'duration': item.duration,
        'author': item.author,
      });
      remoteSubmit(item);
      return true;
    }
    return false;
  }

  static Future<bool> exist(String bvid) async {
    var result = await DBHelper.dbh
        .query('favorite', where: 'bvid = ? LIMIT 1', whereArgs: [bvid]);
    return result.isNotEmpty;
  }

  static Future<VideoItem?> fetch(String bvid) async {
    var result = await DBHelper.dbh
        .query('favorite', where: 'bvid = ? LIMIT 1', whereArgs: [bvid]);
    if (result.isEmpty) {
      return null;
    }
    return VideoItem.fromFavorite(result.first);
  }

  static Future<void> delete(String bvid) async {
    await DBHelper.dbh
        .delete('favorite', where: 'bvid = ? ', whereArgs: [bvid]);
    await remoteDelete(bvid);
  }

  static Future<List<Map<String, dynamic>>> search(String? keyword,
      {int offset = 0, int limit = 10}) async {
    List<String> where = [];
    List<dynamic> whereArgs = [];
    if (keyword != null && keyword.isNotEmpty) {
      where.add('title LIKE ?');
      whereArgs.add('%$keyword%');
    }

    List<Map<String, dynamic>> result = await DBHelper.dbh.query(
      'favorite',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      limit: limit,
      offset: offset,
      orderBy: 'id DESC',
    );
    return result;
  }

  static Future<int> searchCount(String? keyword) async {
    List<String> where = [];
    List<dynamic> whereArgs = [];
    if (keyword != null && keyword.isNotEmpty) {
      where.add('title LIKE ?');
      whereArgs.add('%$keyword%');
    }

    if (where.isEmpty) {
      return await DBHelper.dbh
          .rawQuery('SELECT COUNT(*) as count FROM favorite')
          .then((value) => value.first['count'] as int);
    } else {
      var result = await DBHelper.dbh.rawQuery(
          'SELECT COUNT(*) as count FROM favorite WHERE ${where.join(" AND ")}',
          whereArgs);
      return result.first['count'] as int;
    }
  }

  static Future<void> deleteAll() async {
    await DBHelper.dbh.delete('favorite');
  }

  static Future<ApiResponse<List<VideoItem>>> remoteLoad() async {
    try {
      final client = await BaseService.getBaseClient();
      final response = await BaseService.get<List<VideoItem>>(
        client,
        '/api/favorite/load',
        params: {'page': 1, 'page_size': 10},
        parser: (data) {
          List<VideoItem> list = [];
          if (data != null &&
              data['data'] != null &&
              data['data']['list'] != null) {
            for (var item in data['data']['list']) {
              list.add(VideoItem.fromFavorite(item as Map<String, dynamic>));
            }
          }
          return list;
        },
      );
      return response;
    } catch (e) {
      return ApiResponse.error('加载收藏列表失败: $e');
    }
  }

  static Future remoteSubmit(VideoItem item) async {
    try {
      final client = await BaseService.getBaseClient();
      final response = await BaseService.post<bool>(
        client,
        '/api/favorite/submit',
        data: item.toJson(),
      );
      return response;
    } catch (e) {
      return ApiResponse.error('提交收藏失败');
    }
  }

  static Future<ApiResponse> remoteDelete(String bvid) async {
    try {
      final client = await BaseService.getBaseClient();
      final response = await BaseService.post<bool>(
        client,
        '/api/favorite/delete',
        data: {'bvid': bvid},
      );
      return response;
    } catch (e) {
      return ApiResponse.error('删除收藏失败: $e');
    }
  }

  //加载B站的收藏文件夹
  static Future<ApiResponse<List<Map>>> loadBiliFolder(int mid) async {
    var client = await BaseService.getApiClient();
    final response = await BaseService.get<List<Map<String, dynamic>>>(
      client,
      '/x/v3/fav/folder/created/list-all',
      params: {'pn': 1, 'ps': 20, 'up_mid': mid},
      parser: (data) {
        List<Map<String, dynamic>> list = [];
        for (var item in data['list']) {
          if (item['title'] == 'xiaoxiao' || item['title'] == '小晓') {
            list.add({'media_id': item['id'], 'title': item['title']});
          }
        }
        return list;
      },
    );
    return response;
  }

  //加载B站的收藏夹里小晓频道的视频
  static Future<ApiResponse<List<VideoItem>>> loadBiliXiaoFavorite(
      int mediaId) async {
    var client = await BaseService.getApiClient();
    final response = await BaseService.get<List<VideoItem>>(
      client,
      '/x/v3/fav/resource/list',
      params: {'media_id': mediaId, 'pn': 1, 'ps': 40, 'order': 'mtime'},
      parser: (data) {
        List<VideoItem> list = [];
        if (data['medias'] != null) {
          for (var item in data['medias']) {
            if (item['type'] == 2) {
              list.add(VideoItem.fromBiliFavorite(item));
            }
          }
        }
        return list;
      },
    );
    return response;
  }

  static void asyncBiliFavorite(int mid) async {
    var foldersResponse = await FavoriteService.loadBiliFolder(mid);
    if (!foldersResponse.success || foldersResponse.data == null) {
      return;
    }

    // 2. 遍历收藏文件夹，加载每个文件夹中的视频
    for (var folder in foldersResponse.data!) {
      int mediaId = folder['media_id'];
      var response = await FavoriteService.loadBiliXiaoFavorite(mediaId);
      if (!response.success || response.data == null) {
        continue;
      }
      // 4. 将视频保存到本地数据库
      for (var video in response.data!) {
        await FavoriteService.add(video);
      }
    }
  }
}
