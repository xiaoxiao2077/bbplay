import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '/player/agent.dart';
import '/provider/playing.dart';
import '/widgets/popup_menu/index.dart';
import '/widgets/popup_menu/item.dart';

class DesktopVideo extends StatefulWidget {
  const DesktopVideo({super.key, this.title = ''});
  final String title;

  @override
  State<DesktopVideo> createState() => _DesktopVideoState();
}

class _DesktopVideoState extends State<DesktopVideo> {
  late final VideoController _videoController;
  final GlobalKey<VideoState> _videoPlayerKey = GlobalKey();

  // 普通模式按键
  final GlobalKey _speedKey = GlobalKey();
  final GlobalKey _resolutionKey = GlobalKey();

  // 全屏模式按键
  final GlobalKey _speedKeyFullscreen = GlobalKey();
  final GlobalKey _resolutionKeyFullscreen = GlobalKey();

  final _speedMap = {
    0.5: '0.5x',
    0.75: '0.75x',
    1.0: '1.0x',
    1.25: '1.25x',
    1.5: '1.5x',
    2.0: '2.0x'
  };

  @override
  void initState() {
    super.initState();
    _videoController = VideoController(
      PlayerAgent.player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
        androidAttachSurfaceAfterVideoParameters: false,
      ),
    );
  }

  void _showSpeedPopupMenu(GlobalKey key) {
    final playingState = context.read<PlayingState>();
    final menu = PopupMenu(
      context: context,
      items: [
        for (var speed in _speedMap.entries)
          PopUpMenuItem(
            title: playingState.speed == speed.key
                ? '${speed.value} ✓'
                : speed.value,
            value: speed.key,
          ),
      ],
      onClickMenu: (item) {
        context.read<PlayingState>().changeSpeed(item.value as double);
      },
    );
    menu.show(widgetKey: key);
  }

  void _showResolutionPopupMenu(
    GlobalKey key,
    Map<int, String> qualityList,
    Function(int) onChangeQuality,
  ) {
    final playerState = context.read<PlayingState>();
    final menu = PopupMenu(
      context: context,
      items: [
        for (final entry in qualityList.entries)
          PopUpMenuItem(
              title: playerState.quality == entry.key
                  ? " ${entry.value} ✓"
                  : entry.value,
              value: entry.key),
      ],
      onClickMenu: (item) {
        onChangeQuality(item.value as int);
      },
    );
    menu.show(widgetKey: key);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: _buildNormalControls(),
      fullscreen: _buildFullscreenControls(),
      child: Video(key: _videoPlayerKey, controller: _videoController),
    );
  }

  MaterialDesktopVideoControlsThemeData _buildNormalControls() {
    var playingState = context.watch<PlayingState>();
    return MaterialDesktopVideoControlsThemeData(
      playAndPauseOnTap: true,
      displaySeekBar: true,
      seekBarThumbColor: Colors.blue,
      seekBarPositionColor: Colors.blue,
      toggleFullscreenOnDoublePress: true,
      topButtonBar: [
        MaterialCustomButton(
          onPressed: () {
            PlayerAgent.pause();
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        const Spacer(),
      ],
      bottomButtonBar: [
        const MaterialDesktopPlayOrPauseButton(),
        const MaterialDesktopPositionIndicator(),
        const Spacer(),
        MaterialButton(
          key: _resolutionKey,
          onPressed: () => _showResolutionPopupMenu(
            _resolutionKey,
            playingState.qualityList,
            playingState.changeQuality,
          ),
          child: Builder(builder: (context) {
            return Text(
              playingState.qualityName.toString(),
              style: const TextStyle(color: Colors.white),
            );
          }),
        ),
        MaterialButton(
          key: _speedKey,
          onPressed: () => _showSpeedPopupMenu(_speedKey),
          child: Builder(builder: (context) {
            return Text(
              playingState.speed == 1.0 ? '倍速' : _speedMap[playingState.speed]!,
              style: const TextStyle(color: Colors.white),
            );
          }),
        ),
        const MaterialDesktopVolumeButton(),
        const MaterialDesktopFullscreenButton(),
      ],
    );
  }

  MaterialDesktopVideoControlsThemeData _buildFullscreenControls() {
    var playingState = context.watch<PlayingState>();
    return MaterialDesktopVideoControlsThemeData(
      topButtonBar: [
        MaterialCustomButton(
          onPressed: () {
            _videoPlayerKey.currentState?.exitFullscreen();
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
      bottomButtonBar: [
        const MaterialDesktopPlayOrPauseButton(),
        const MaterialDesktopPositionIndicator(),
        const Spacer(),
        MaterialButton(
          key: _resolutionKeyFullscreen,
          onPressed: () => _showResolutionPopupMenu(
            _resolutionKeyFullscreen,
            playingState.qualityList,
            playingState.changeQuality,
          ),
          child: Builder(builder: (context) {
            return Text(
              playingState.qualityName.toString(),
              style: const TextStyle(color: Colors.white),
            );
          }),
        ),
        MaterialButton(
          key: _speedKeyFullscreen,
          onPressed: () => _showSpeedPopupMenu(_speedKeyFullscreen),
          child: Builder(
            builder: (context) {
              return Text(
                playingState.speed == 1.0
                    ? '倍速'
                    : _speedMap[playingState.speed]!,
                style: const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        const MaterialDesktopVolumeButton(),
        const MaterialDesktopFullscreenButton(),
      ],
    );
  }
}
