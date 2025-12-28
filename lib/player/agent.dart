import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:media_kit/media_kit.dart';

import '/utils/loggy.dart';
import '/player/models/media_source.dart';

class PlayerAgent {
  static late Player _mediakit;

  static get player {
    return _mediakit;
  }

  static get isPlaying {
    return _mediakit.state.playing;
  }

  static get state {
    return _mediakit.state;
  }

  static get duration {
    return _mediakit.state.duration;
  }

  static get position {
    return _mediakit.state.position;
  }

  static get stream {
    return _mediakit.stream;
  }

  static void togglePlay() {
    isPlaying ? _mediakit.pause() : _mediakit.play();
  }

  static get speed {
    return _mediakit.state.rate;
  }

  // 更换视频源
  static Future<void> setMediaSource(
    MediaSource mediaSource, {
    bool autoplay = true,
    Duration seekTo = Duration.zero, // 初始化播放位置
    double speed = 1.0, // 初始化播放速度
    bool enableSubTitle = false, //  是否开启字幕
  }) async {
    // 初始化全屏方向
    if (_mediakit.state.playing) {
      await pause(notify: false);
    }

    // 配置Player 音轨、字幕等等
    var pp = _mediakit.platform as NativePlayer;
    if (mediaSource.audioSource != null && mediaSource.audioSource != '') {
      await pp.setProperty(
        'audio-files',
        Platform.isWindows
            ? mediaSource.audioSource!.replaceAll(';', '\\;')
            : mediaSource.audioSource!.replaceAll(':', '\\:'),
      );
    }
    await _mediakit.open(
      Media(mediaSource.videoSource!,
          httpHeaders: mediaSource.httpHeaders, start: seekTo),
      play: autoplay,
    );
  }

  // 配置播放器
  static Player initialize() {
    _mediakit = Player(
      configuration: PlayerConfiguration(
        title: '小晓',
        bufferSize: 5 * 1024 * 1024,
        ready: () {
          // 监听播放状态
        },
      ),
    );
    var pp = _mediakit.platform as NativePlayer;
    // 解除倍速限制
    pp.setProperty("af", "scaletempo2=max-speed=3");
    //  音量不一致
    if (Platform.isAndroid) {
      pp.setProperty("volume-max", "100");
    }
    _mediakit.setAudioTrack(AudioTrack.auto());
    //_mediakit.setSubtitleTrack(SubtitleTrack.no());
    _mediakit.setSubtitleTrack(
      SubtitleTrack.uri(
        'https://www.iandevlin.com/html5test/webvtt/upc-video-subtitles-en.vtt',
        title: 'English',
        language: 'en',
      ),
    );

    _mediakit.stream.volume.listen((value) {});
    _mediakit.stream.rate.listen((value) {});
    _mediakit.stream.error.listen((error) {
      Loggy.e('mediakit error:', error);
    });
    return _mediakit;
  }

  /// 跳转至指定位置
  static Future<void> seek(Duration position) async {
    if (position < Duration.zero) {
      position = Duration.zero;
    }
    await _mediakit.seek(position);
  }

  /// 设置倍速
  static Future<void> setSpeed(double speed) async {
    await _mediakit.setRate(speed);
  }

  /// 设置音量
  static Future<void> setVolume(double volume) async {
    await _mediakit.setVolume(volume);
  }

  /// 播放视频
  static Future<void> play({bool repeat = false, Duration? duration}) async {
    if (repeat) {
      await seek(Duration.zero);
    }
    await _mediakit.play();
  }

  /// 暂停播放
  static Future<void> pause(
      {bool notify = true, bool isInterrupt = false}) async {
    await _mediakit.pause();
  }

  /// 截屏
  static Future screenshot() async {
    final Uint8List? screenshot =
        await _mediakit.screenshot(format: 'image/png');
    return screenshot;
  }
}
