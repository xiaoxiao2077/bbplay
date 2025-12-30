import 'dart:math';

import '/utils/wbi_sign.dart';
import '/model/video/item.dart';
import '/model/video/media.dart';
import '/model/video/detail.dart';
import '/model/video/summary.dart';
import '/service/base_service.dart';

class VideoService {
  /// 获取相关视频列表
  static Future<ApiResponse<List<VideoItem>>> relatedList(String bvid) async {
    try {
      final client = await BaseService.getApiClient();
      final response = await BaseService.get<List<VideoItem>>(
        client,
        '/x/web-interface/archive/related',
        params: {'bvid': bvid},
        parser: (data) {
          final listData = data as List;
          return listData
              .map(
                  (item) => VideoItem.fromRelated(item as Map<String, dynamic>))
              .toList();
        },
      );
      return response;
    } catch (e) {
      return ApiResponse.error('获取相关视频失败: $e');
    }
  }

  /// 获取字幕配置
  static Future<ApiResponse<dynamic>> getSubtitle({
    int? cid,
    String? bvid,
  }) async {
    final client = await BaseService.getApiClient();
    final response = await BaseService.get(client, '/x/player/v2', params: {
      'cid': cid,
      'bvid': bvid,
    });
    return response;
  }

  /// 获取视频AI总结
  static Future<ApiResponse<VideoSummary>> loadSummary({
    required String bvid,
    required int cid,
    required int upmid,
  }) async {
    final params = await WbiSign().makSign({
      'cid': cid,
      'bvid': bvid,
      'up_mid': upmid,
    });

    final client = await BaseService.getApiClient();
    final response = await BaseService.get<VideoSummary>(
      client,
      '/x/web-interface/view/conclusion/get',
      params: params,
      parser: (data) {
        final summary =
            VideoSummary.fromJson(data['model_result'] as Map<String, dynamic>);
        return summary;
      },
    );
    return response;
  }

  /// 加载视频详情
  static Future<ApiResponse<VideoDetail>> loadDetail(String bvid) async {
    final client = await BaseService.getApiClient();
    final response = await BaseService.get<VideoDetail>(
      client,
      '/x/web-interface/view',
      params: {'bvid': bvid},
      parser: (data) {
        return VideoDetail.fromJson(data as Map<String, dynamic>);
      },
    );
    return response;
  }

  /// 加载推荐视频列表
  static Future<ApiResponse<List<VideoItem>>> loadRcmdList({
    required int page,
    required int psize,
  }) async {
    final client = await BaseService.getBaseClient();
    final response = await BaseService.get<List<VideoItem>>(
      client,
      '/api/video/hotest',
      params: {'psize': psize, 'page': page},
      parser: (data) {
        final listData = data as List?;
        if (listData != null) {
          final list = listData
              .map((item) => VideoItem.fromRcmd(item as Map<String, dynamic>))
              .toList();
          return list;
        }
        return [];
      },
    );
    return response;
  }

  ///学科视频
  static Future<ApiResponse<List<VideoItem>>> loadSubjectList(
    String subject,
    String grade, {
    int page = 1,
    int psize = 10,
  }) async {
    final client = await BaseService.getBaseClient();
    final response = await BaseService.get<List<VideoItem>>(
      client,
      '/api/video/subject',
      params: {'subject': subject, 'page': page, 'psize': psize},
      parser: (data) {
        final listData = data as List?;
        if (listData != null) {
          final list = listData
              .map(
                  (item) => VideoItem.fromSubject(item as Map<String, dynamic>))
              .toList();
          return list;
        }
        return [];
      },
    );

    return response;
  }

  static Future<ApiResponse<VideoMedia>> videoUrl({
    String? bvid,
    required int cid,
    int? qn,
  }) async {
    Map<String, dynamic> data = {
      'bvid': bvid,
      'cid': cid,
      'qn': qn ?? 80, //1080p
      'fnval': 4048, // 获取所有格式的视频
    };

    Map<String, dynamic> params = await WbiSign().makSign({
      ...data,
      'fourk': 1,
      'voice_balance': 1,
      'gaia_source': 'pre-load',
      'web_location': 1550101,
    });

    var client = await BaseService.getApiClient();
    final response = await BaseService.get<VideoMedia>(
      client,
      '/x/player/wbi/playurl',
      params: params,
      parser: (data) {
        final media = VideoMedia.fromJson(data as Map<String, dynamic>);
        return media;
      },
    );
    return response;
  }
}
