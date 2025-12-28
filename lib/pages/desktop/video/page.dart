import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './related.dart';
import '/player/agent.dart';
import 'widgets/header.dart';
import 'widgets/bottom.dart';
import 'widgets/author.dart';
import 'widgets/summary.dart';
import 'widgets/pagelist.dart';
import '/provider/playing.dart';
import '/model/wallclock.dart';
import '/model/video/item.dart';
import '/player/desktop_video.dart';
import '/service/history_service.dart';
import '/widgets/wallclock_wrapper.dart';

class VideoPlayPage extends StatefulWidget {
  final VideoItem item;

  const VideoPlayPage({super.key, required this.item});

  @override
  State<VideoPlayPage> createState() => _VideoPlayPageState();
}

class _VideoPlayPageState extends State<VideoPlayPage> {
  late Timer _historyTimer;
  late PlayingState _playingState;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _startTracking();
  }

  /// 初始化状态
  void _initializeState() {
    _playingState = PlayingState(videoItem: widget.item);
  }

  /// 开始历史记录跟踪
  void _startTracking() {
    _historyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (PlayerAgent.isPlaying) {
        HistoryService.setSeek(
          bvid: _playingState.videoItem.bvid,
          cid: _playingState.videoItem.cid,
          seek: PlayerAgent.position,
        );
        WallClock.tick(1);
      }
    });
  }

  @override
  void dispose() {
    _historyTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WallClockWrapper(
      child: _buildMultiProvider(),
    );
  }

  /// 构建多Provider包装器
  Widget _buildMultiProvider() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PlayingState>(
          lazy: false,
          create: (_) => _playingState,
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  /// 构建AppBar
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(0),
      child: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }

  /// 构建页面主体内容
  Widget _buildBody() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        _buildMainContent(),
        _buildSideContent(),
      ],
    );
  }

  /// 构建主内容区域
  Widget _buildMainContent() {
    return Expanded(
      flex: 7,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HeaderView(),
              _buildPlayer(),
              const SizedBox(height: 10),
              const VideoBottomView(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建侧边栏内容
  Widget _buildSideContent() {
    return const Expanded(
      flex: 3,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VideoAuthorView(),
            SummaryView(),
            SizedBox(height: 10),
            PageListView(),
            SizedBox(height: 10),
            Expanded(child: RelatedVideoList()),
          ],
        ),
      ),
    );
  }

  /// 构建播放器组件
  Widget _buildPlayer() {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.space): const SpacebarPressedIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          SpacebarPressedIntent: CallbackAction<SpacebarPressedIntent>(
            onInvoke: (SpacebarPressedIntent intent) =>
                PlayerAgent.togglePlay(),
          ),
        },
        child: Focus(
          autofocus: true,
          child: GestureDetector(
            onTap: () => PlayerAgent.togglePlay(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxWidth * 9 / 16;
                return SizedBox(
                  height: height,
                  width: constraints.maxWidth,
                  child: Stack(
                    children: [
                      Consumer<PlayingState>(
                        builder: (context, playingState, child) {
                          return DesktopVideo(
                            title: playingState.videoItem.title,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 自定义意图类，表示空格键被按下
class SpacebarPressedIntent extends Intent {
  const SpacebarPressedIntent();
}
