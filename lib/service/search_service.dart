import 'dart:convert';

import '/utils/loggy.dart';
import '/utils/wbi_sign.dart';
import '/model/video/item.dart';
import '/service/base_service.dart';

class SearchService {
  /// 获取热门搜索列表
  static Future<ApiResponse<List<String>>> hotSearchList() async {
    try {
      final client = await BaseService.getSearchClient();
      final response =
          await BaseService.get(client, '/main/hotword', parser: (data) {
        final hotlist = <String>[];
        for (var item in data['list']) {
          hotlist.add(item['show_name']);
        }
        return hotlist;
      });

      return response;
    } catch (e, stack) {
      Loggy.e("hotword", e, stack);
      return ApiResponse.error('获取热门搜索列表失败: $e');
    }
  }

  /// 获取搜索建议
  static Future<ApiResponse<List<String>>> searchSuggest(String term) async {
    try {
      final client = await BaseService.getSearchClient();
      final response = await client.get(
        '/main/suggest',
        {'term': term, 'main_ver': 'v1', 'highlight': term},
        rawoutput: true,
      );
      var jsonData = jsonDecode(response.data);
      List<String> suggestList = [];
      int i = 0;
      for (var item in jsonData['result']['tag']) {
        if (i++ > 12) {
          break;
        }
        suggestList.add(item['value']);
      }
      return ApiResponse.success(suggestList);
    } catch (e, stack) {
      Loggy.e("search suggest", e, stack);
      return ApiResponse.error('获取搜索建议失败: $e');
    }
  }

  /// 分类搜索
  static Future<ApiResponse<List<VideoItem>>> searchByType({
    required String keyword,
    required int page,
  }) async {
    var query = {
      'search_type': 'video',
      'keyword': keyword,
      'tids': 0,
      'duration': 0,
      'order': 'totalrank',
      'page': page,
    };
    var client = await BaseService.getApiClient();
    var resp = await BaseService.get(
      client,
      '/x/web-interface/wbi/search/type',
      params: query,
      parser: (data) {
        List<VideoItem> videoList = [];
        for (var item in data['result']) {
          if (item['type'] == 'video') {
            videoList.add(VideoItem.fromSearch(item));
          }
        }
        return videoList;
      },
    );
    return resp;
  }

  /// 搜索计数
  static Future<ApiResponse<int>> searchCount({required String keyword}) async {
    try {
      final params = await WbiSign().makSign({
        'keyword': keyword,
        'web_location': 333.999,
      });

      final client = await BaseService.getApiClient();
      final response = await BaseService.get(
        client,
        '/x/web-interface/wbi/search/all/v2',
        params: params,
        parser: (data) {
          return data as int;
        },
      );

      return response;
    } catch (e, stack) {
      Loggy.e("search count", e, stack);
      return ApiResponse.error('搜索计数失败: $e');
    }
  }
}
