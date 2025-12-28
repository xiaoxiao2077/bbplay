import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/provider/playing.dart';
import '/model/video/item.dart';
import '/service/base_service.dart';
import '/service/video_service.dart';
import '/widgets/horizon_listtile.dart';
import '/widgets/skeleton/horizontal.dart';

class RelatedVideoList extends StatelessWidget {
  const RelatedVideoList({super.key});

  @override
  Widget build(BuildContext context) {
    final playingState = Provider.of<PlayingState>(context);

    return FutureBuilder<ApiResponse<List<VideoItem>>>(
      future: VideoService.relatedList(playingState.videoItem.bvid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingSkeleton();
        } else if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error.toString());
        } else if (snapshot.hasData && snapshot.data!.success) {
          return _buildVideoList(context, snapshot.data!.data ?? []);
        } else {
          return _buildErrorWidget(snapshot.data?.message ?? '未知错误');
        }
      },
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 5,
      itemExtent: 85,
      itemBuilder: (_, __) => const HorizontalSkeleton(),
    );
  }

  /// 构建错误提示
  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 8),
          Text(
            '加载失败，请检查网络',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建视频列表
  Widget _buildVideoList(BuildContext context, List<VideoItem> videos) {
    if (videos.isEmpty) {
      return const Center(
        child: Text(
          '暂无相关视频',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: videos.length,
      itemExtent: 86,
      itemBuilder: (context, index) {
        final item = videos[index];
        return Material(
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: HorizonListTile(
              item: item,
              selectMode: false,
              onTab: (item) {
                context
                    .read<PlayingState>()
                    .switchVideo(item: item, cid: item.cid);
              },
            ),
          ),
        );
      },
    );
  }
}
