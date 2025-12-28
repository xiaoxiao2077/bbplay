import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/provider/playing.dart';
import '/model/video/item.dart';
import '/service/base_service.dart';
import '/service/video_service.dart';
import '/widgets/horizon_listtile.dart';
import '/widgets/skeleton/horizontal.dart';

class RelatedVideoList extends StatelessWidget {
  final String bvid;

  const RelatedVideoList({super.key, required this.bvid});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayingState>(
      builder: (context, playingState, child) {
        return FutureBuilder<ApiResponse<List<VideoItem>>>(
          future: VideoService.relatedList(
            bvid.isEmpty ? playingState.videoItem.bvid : bvid,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingSkeleton();
            }

            if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error);
            }

            if (snapshot.hasData && snapshot.data!.success) {
              final videos = snapshot.data!.data ?? [];
              if (videos.isEmpty) {
                return _buildEmptyWidget();
              }
              return _buildVideoList(videos, playingState);
            }

            return _buildErrorWidget('加载失败');
          },
        );
      },
    );
  }

  /// 构建加载中的骨架屏
  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return const HorizontalSkeleton();
      },
    );
  }

  /// 构建视频列表
  Widget _buildVideoList(List<VideoItem> videos, PlayingState playingState) {
    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        final item = videos[index];
        return Material(
          color: Colors.transparent,
          child: HorizonListTile(
            selectMode: false,
            item: item,
            onTab: (videoItem) => playingState.switchVideo(
              item: videoItem,
              cid: videoItem.cid,
            ),
          ),
        );
      },
    );
  }

  /// 构建空状态组件
  Widget _buildEmptyWidget() {
    return const Center(
      child: Text(
        '暂无推荐视频',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
      ),
    );
  }

  /// 构建错误状态组件
  Widget _buildErrorWidget(Object? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 10),
          Text(
            error?.toString() ?? '加载失败，请检查网络',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
