import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:media_kit_video/media_kit_video.dart' as mediakit;

import '/player/agent.dart';
import '/provider/playing.dart';
import 'models/duration.dart';
import '/widgets/drawer_menu.dart';

class MobileVideo extends StatefulWidget {
  const MobileVideo({super.key, this.title = ''});
  final String title;

  @override
  State<StatefulWidget> createState() => _MobileVideoState();
}

class _MobileVideoState extends State<MobileVideo> {
  late PlayingState playingState;
  final GlobalKey<mediakit.VideoState> _videoKey = GlobalKey();

  late mediakit.VideoController videoController = mediakit.VideoController(
    PlayerAgent.player,
    configuration: const mediakit.VideoControllerConfiguration(
      enableHardwareAcceleration: true,
      androidAttachSurfaceAfterVideoParameters: false,
    ),
  );

  @override
  Widget build(BuildContext context) {
    playingState = context.watch<PlayingState>();
    return _buildVideoPlayer();
  }

  Widget _buildVideoPlayer() {
    return mediakit.MaterialVideoControlsTheme(
      normal: _buildNormalControls(),
      fullscreen: _buildFullscreenControls(),
      child: mediakit.Video(
        key: _videoKey,
        fit: BoxFit.cover,
        aspectRatio: 16 / 9,
        controller: videoController,
        alignment: Alignment.center,
        subtitleViewConfiguration: const mediakit.SubtitleViewConfiguration(),
      ),
    );
  }

  mediakit.MaterialVideoControlsThemeData _buildNormalControls() {
    return mediakit.MaterialVideoControlsThemeData(
      seekBarThumbColor: Colors.blue,
      seekBarPositionColor: Colors.blue,
      brightnessGesture: true,
      seekGesture: true,
      speedUpOnLongPress: true,
      volumeIndicatorBuilder: _buildVolumeIndicator,
      seekIndicatorBuilder: _buildSeekIndicator,
      brightnessIndicatorBuilder: _buildBrightnessIndicator,
      speedUpIndicatorBuilder: _buildSpeedUpIndicator,
      topButtonBar: _buildNormalTopButtonBar(),
      bottomButtonBar: _buildNormalBottomButtonBar(),
    );
  }

  mediakit.MaterialVideoControlsThemeData _buildFullscreenControls() {
    return mediakit.MaterialVideoControlsThemeData(
      displaySeekBar: true,
      volumeGesture: true,
      seekGesture: true,
      brightnessGesture: true,
      speedUpOnLongPress: true,
      seekBarThumbColor: Colors.blue,
      seekBarPositionColor: Colors.blue,
      topButtonBar: _buildFullscreenTopButtonBar(),
      bottomButtonBar: _buildFullscreenBottomButtonBar(),
      automaticallyImplySkipNextButton: false,
      automaticallyImplySkipPreviousButton: false,
    );
  }

  List<Widget> _buildNormalTopButtonBar() {
    return [
      mediakit.MaterialCustomButton(
        onPressed: _handleBackButtonPressed,
        icon: const Icon(Icons.arrow_back_ios),
      ),
      const Spacer(),
      mediakit.MaterialCustomButton(
        onPressed: _handleMoreButtonPressed,
        icon: const Icon(Icons.more_vert),
      ),
    ];
  }

  List<Widget> _buildNormalBottomButtonBar() {
    return const [
      mediakit.MaterialPlayOrPauseButton(),
      mediakit.MaterialPositionIndicator(),
      Spacer(),
      mediakit.MaterialFullscreenButton(),
    ];
  }

  List<Widget> _buildFullscreenTopButtonBar() {
    return [
      mediakit.MaterialCustomButton(
        onPressed: _handleExitFullscreenPressed,
        icon: const Icon(Icons.arrow_back_ios),
      ),
      Text(
        widget.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: const TextStyle(color: Colors.white),
      ),
      const Spacer(),
    ];
  }

  List<Widget> _buildFullscreenBottomButtonBar() {
    return [
      const mediakit.MaterialPlayOrPauseButton(),
      const mediakit.MaterialPositionIndicator(),
      const Spacer(),
      _buildSpeedButton(),
      _buildResolutionButton(),
    ];
  }

  Widget _buildSpeedButton() {
    return MaterialButton(
      onPressed: showSpeedDrawer,
      child: const Text(
        '倍速',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildResolutionButton() {
    return Builder(
      builder: (context) {
        return MaterialButton(
          onPressed: showResolutionDrawer,
          child: Text(
            playingState.qualityName,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  void _handleBackButtonPressed() {
    PlayerAgent.pause();
    Navigator.of(context).pop();
  }

  void _handleMoreButtonPressed() {
    // TODO: 实现更多选项功能
  }

  void _handleExitFullscreenPressed() {
    AutoOrientation.portraitAutoMode();
    _videoKey.currentState?.exitFullscreen();
  }

  Widget _buildVolumeIndicator(BuildContext context, double volume) {
    return Text(
      '${(volume * 100).round()}%',
      style: const TextStyle(color: Colors.white, fontSize: 24),
    );
  }

  Widget _buildSeekIndicator(BuildContext context, Duration position) {
    return Text(
      position.presentation(),
      style: const TextStyle(color: Colors.white, fontSize: 24),
    );
  }

  Widget _buildBrightnessIndicator(BuildContext context, double brightness) {
    return Text(
      '${(brightness * 100).round()}%',
      style: const TextStyle(color: Colors.white, fontSize: 24),
    );
  }

  Widget _buildSpeedUpIndicator(BuildContext context, double speed) {
    return Text(
      'x$speed',
      style: const TextStyle(color: Colors.white, fontSize: 24),
    );
  }

  void showSubtitleDrawer() {
    var m = DrawerMenu(context: context, menuItems: [], onTap: (value) {});
    m.show();
  }

  void showSpeedDrawer() {
    var m = DrawerMenu(
      context: context,
      menuItems: [
        const MenuItem(title: '0.5x', value: 0.5),
        const MenuItem(title: '0.75x', value: 0.75),
        const MenuItem(title: '1.0x', value: 1.0),
        const MenuItem(title: '1.25x', value: 1.25),
        const MenuItem(title: '1.5x', value: 1.5),
        const MenuItem(title: '1.75x', value: 1.75),
      ],
      onTap: (value) {
        double speed = value == null ? 1.0 : double.parse(value);
        PlayerAgent.setSpeed(speed);
      },
    );
    m.show();
  }

  void showResolutionDrawer() {
    var m = DrawerMenu(
      context: context,
      menuItems: [
        for (var entry in playingState.qualityList.entries)
          MenuItem(title: entry.value, value: entry.key),
      ],
      onTap: (title) {},
    );
    m.show();
  }
}
