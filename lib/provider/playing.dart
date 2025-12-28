import 'package:flutter/material.dart';

import '/player/agent.dart';
import '/model/video/item.dart';
import '/model/video/media.dart';
import '/model/video/detail.dart';
import '/model/video/summary.dart';
import '/service/video_service.dart';
import '/service/author_service.dart';
import '/service/history_service.dart';
import '/service/favorite_service.dart';
import '/player/models/media_source.dart';

class PlayingState extends ChangeNotifier {
  int cid = 0;
  bool hasFav = false;
  bool hasLike = false;
  bool hasDisLike = false;
  int lastPlayTime = 0;
  VideoItem videoItem;
  VideoDetail? detail;
  VideoSummary? summary;

  int quality = 32;
  double speed = 1.0;
  Map<int, String> qualityList = {};
  List<MediaDashVideo> videoMediaList = [];
  List<MediaDashAudio> audioMediaList = [];

  PlayingState({required this.videoItem}) {
    switchVideo(item: videoItem, cid: videoItem.cid);
  }

  void switchVideo({
    required VideoItem item,
    required int cid,
    int page = 1,
  }) async {
    final resp = await VideoService.loadDetail(item.bvid);
    detail = resp.data!;
    this.cid = cid;
    await loadSummary();
    hasFav = await FavoriteService.exist(item.bvid);
    var history = await HistoryService.fetch(item.bvid, cid);
    if (history == null) {
      HistoryService.add(item, cid, page);
    }
    hasLike = history != null && history.isLiked == 1;
    hasDisLike = history != null && history.isLiked == -1;
    if (history != null && history.seek == history.duration) {
      lastPlayTime = 0;
    } else if (history != null) {
      lastPlayTime = history.seek;
    }

    // 加载视频媒体信息
    await _queryVideoUrl(item.bvid, cid);
    for (var i = 0; i < detail!.authorList.length; i++) {
      detail!.authorList[i].sign =
          await AuthorService.fetchSign(detail!.authorList[i].mid);
    }
    notifyListeners();
  }

  Future<void> loadSummary() async {
    if (detail != null && detail!.authorList.isNotEmpty) {
      final resp = await VideoService.loadSummary(
        bvid: videoItem.bvid,
        cid: cid,
        upmid: detail!.authorList[0].mid,
      );
      if (resp.success) {
        summary = resp.data;
      }
    }
  }

  // 解析视频链接
  _queryVideoUrl(String bvid, int cid) async {
    var resp = await VideoService.videoUrl(cid: cid, bvid: bvid);
    if (resp.success) {
      VideoMedia playmedia = resp.data!;
      qualityList = playmedia.qualityList;
      videoMediaList = playmedia.dashMedia.videoList;
      audioMediaList = playmedia.dashMedia.audioList;
      quality = playmedia.dashMedia.videoList.first.id;
      changeQuality(quality);
    } else {
      return Future.error('获取视频链接失败:${resp.message}');
    }
  }

  void changeQuality(int quality) {
    this.quality = quality;
    var selected = videoMediaList.where((e) => e.id == quality);
    PlayerAgent.setMediaSource(
      MediaSource(
        videoSource: selected.first.baseUrl,
        audioSource: audioMediaList.first.baseUrl,
      ),
      autoplay: true,
      seekTo: Duration(seconds: lastPlayTime), // 使用上次播放时间作为起始位置
    );
    notifyListeners();
  }

  get qualityName {
    return qualityList[quality] ?? quality;
  }

  void changeSpeed(double speed) {
    this.speed = speed;
    PlayerAgent.setSpeed(speed); // 设置播放速度
    notifyListeners();
  }

  // 切换点赞状态
  void toggleLike() {
    hasLike = !hasLike;
    if (hasLike && hasDisLike) {
      hasDisLike = false;
    }
    // 更新点赞数
    if (hasLike) {
      detail!.stat.like = (detail!.stat.like ?? 0) + 1;
    } else {
      detail!.stat.like = (detail!.stat.like ?? 1) - 1;
    }
    notifyListeners();
    HistoryService.like(bvid: videoItem.bvid, cid: cid);
  }

  // 切换点踩状态
  void toggleDislike() {
    hasDisLike = !hasDisLike;
    if (hasDisLike && hasLike) {
      hasLike = false;
    }

    notifyListeners();
    HistoryService.dislike(bvid: videoItem.bvid, cid: cid);
  }

  // 切换收藏状态
  void toggleFavorite() {
    hasFav = !hasFav;
    if (hasFav) {
      detail!.stat.favorite = (detail!.stat.favorite ?? 0) + 1;
      FavoriteService.add(videoItem);
    } else {
      detail!.stat.favorite = (detail!.stat.favorite ?? 1) - 1;
      FavoriteService.delete(videoItem.bvid);
    }
    notifyListeners();
  }
}
