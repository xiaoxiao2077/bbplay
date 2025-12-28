import './quality.dart';

class VideoMedia {
  late MediaDash dashMedia; //DASH 流信息
  Map<int, String> qualityList = {};

  VideoMedia.fromJson(Map<String, dynamic> json) {
    dashMedia = (json['dash'] != null ? MediaDash.decode(json['dash']) : null)!;
    List<int> filter = [];
    json['dash']['video'].forEach((element) {
      filter.add(element['id']);
    });
    qualityList = VideoQuality.filter(filter);
  }
}

class MediaDash {
  late int duration; //视频长度
  late List<MediaDashVideo> videoList; //视频流信息
  late List<MediaDashAudio> audioList; //伴音流信息	当视频没有音轨时，此项为 null

  MediaDash.decode(Map<String, dynamic> json) {
    duration = json['duration'];
    videoList = json['video']
        .map<MediaDashVideo>((e) => MediaDashVideo.fromJson(e))
        .toList();
    audioList = json['audio'] != null
        ? json['audio']
            .map<MediaDashAudio>((e) => MediaDashAudio.fromJson(e))
            .toList()
        : [];
  }
}

//视频码流 同一清晰度可拥有 H.264 / H.265 / AV1 多种码流
class MediaDashVideo {
  late int id; //音视频清晰度代码 参考qn视频清晰度标识
  late String baseUrl; //默认流 URL
  late String backupUrl; //备用流 URL
  late String mimeType; //格式 mimetype 类型
  late String codecs; //编码/音频类型
  late int width; //视频宽度
  late int height; //视频高度
  late String frameRate; //视频帧率
  late String sar; //Sample Aspect Ratio（单个像素的宽高比）
  late int codecid; //码流编码标识代码

  MediaDashVideo.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    baseUrl = json['baseUrl'];
    mimeType = json['mime_type'];

    width = json['width'];
    height = json['height'];
    frameRate = json['frameRate'];
    sar = json['sar'];
    codecs = json['codecs'];
    codecid = json['codecid'];
    backupUrl =
        json['backupUrl'] != null ? json['backupUrl'].toList().first : '';
  }
}

class MediaDashAudio {
  late int id;
  late String baseUrl;
  late String backupUrl;
  late String mimeType;
  late String codecs;
  late String frameRate;
  late String sar;
  late int startWithSap;
  late int codecid;

  MediaDashAudio.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    baseUrl = json['baseUrl'];
    backupUrl =
        json['backupUrl'] != null ? json['backupUrl'].toList().first : '';
    mimeType = json['mime_type'];
    frameRate = json['frameRate'];
    sar = json['sar'];
    startWithSap = json['startWithSap'];
    codecs = json['codecs'];
    codecid = json['codecid'];
  }
}
