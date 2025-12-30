import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:auto_orientation_v2/auto_orientation_v2.dart';

import '/player/agent.dart';
import 'widgets/detail.dart';
import '/model/wallclock.dart';
import '/provider/playing.dart';
import '/model/video/item.dart';
import '/player/mobile_video.dart';
import '/pages/video/related.dart';
import '/service/history_service.dart';

class VideoPlayPage extends StatefulWidget {
  final VideoItem item;
  const VideoPlayPage({super.key, required this.item});

  @override
  State<StatefulWidget> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<VideoPlayPage> {
  double videoHeight = 0;
  double videoWidth = 0;
  late Timer _timer;
  late PlayingState _playingState;

  @override
  void initState() {
    super.initState();
    AutoOrientation.portraitAutoMode();
    _playingState = PlayingState(videoItem: widget.item);

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
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      videoHeight = MediaQuery.of(context).size.height;
    } else {
      videoHeight = MediaQuery.sizeOf(context).width * 9 / 16;
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => _playingState,
        ),
      ],
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            scrolledUnderElevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: double.infinity,
              height: videoHeight,
              child: Stack(
                children: [
                  Builder(builder: (context) {
                    PlayingState mediaState = context.watch<PlayingState>();
                    return MobileVideo(title: mediaState.videoItem.title);
                  }),
                ],
              ),
            ),
            const Divider(height: 1),
            const VideoDetailPanel(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
                child: RelatedVideoList(bvid: widget.item.bvid),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
