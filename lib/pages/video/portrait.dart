import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auto_orientation_v2/auto_orientation_v2.dart';

import '/player/agent.dart';
import '/model/video/item.dart';
import '/provider/playing.dart';
import '/model/wallclock.dart';
import '/player/mobile_video.dart';
import '/service/history_service.dart';

/// 竖屏全屏视频播放页面，支持上下滑动切换视频
class PortraitPage extends StatefulWidget {
  final VideoItem item;
  const PortraitPage({super.key, required this.item});

  @override
  State<StatefulWidget> createState() => _PortraitVideoState();
}

class _PortraitVideoState extends State<PortraitPage>
    with TickerProviderStateMixin {
  final List<VideoItem> relatedVideos = [];
  late PageController _pageController;
  late PlayingState _playingState;
  late Timer _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    AutoOrientation.portraitAutoMode();

    _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);

    // 初始化当前视频状态
    _playingState = PlayingState(videoItem: widget.item);

    // 定时更新观看历史和时间统计
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (PlayerAgent.isPlaying) {
        HistoryService.setSeek(
            bvid: _playingState.videoItem.bvid,
            cid: _playingState.videoItem.cid,
            seek: PlayerAgent.position);
        WallClock.tick(1);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _switchToVideo(int index) {
    if (index >= 0 && index < relatedVideos.length && index != _currentIndex) {
      setState(() {
        _currentIndex = index;
        _playingState.switchVideo(
            item: relatedVideos[_currentIndex],
            cid: relatedVideos[_currentIndex].cid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => _playingState,
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          onPageChanged: _switchToVideo,
          itemCount: relatedVideos.length,
          itemBuilder: (context, index) {
            return _VideoPageContent();
          },
        ),
      ),
    );
  }
}

class _VideoPageContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var playingState = Provider.of<PlayingState>(context);
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // 视频播放器区域 (占满大部分屏幕)
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                MobileVideo(title: playingState.videoItem.title),
              ],
            ),
          ),

          // 视频信息区域 (底部固定高度)
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 视频标题
                    Text(
                      playingState.videoItem.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 视频作者信息
                    if (playingState.detail?.author != null) ...[
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                NetworkImage(playingState.detail?.author.face),
                            child: null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            playingState.detail?.author!.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],

                    // 视频统计数据
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                            icon: Icons.thumb_up,
                            count: playingState.detail!.stat.like.toString()),
                        _StatItem(
                            icon: Icons.comment,
                            count: playingState.detail!.stat.coin.toString()),
                        _StatItem(
                            icon: Icons.share,
                            count:
                                playingState.detail!.stat.dislike.toString()),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String count;

  const _StatItem({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 4),
        Text(count, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
