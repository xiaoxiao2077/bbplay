//@todo 处理字幕信息
class MediaSource {
  String? videoSource;
  String? audioSource;
  String? subtitleSource = "";

  Map<String, String>? httpHeaders = {
    'user-agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 13_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.4 Safari/605.1.15',
    'referer': 'https://www.bilibili.com',
  };

  MediaSource({
    this.videoSource,
    this.audioSource,
    this.subtitleSource,
  }) : assert(videoSource != null);

  MediaSource copyWith({
    String? videoSource,
    String? audioSource,
    String? subtitleSource,
    Map<String, String>? httpHeaders,
  }) {
    return MediaSource(
      videoSource: videoSource ?? this.videoSource,
      audioSource: audioSource ?? this.audioSource,
      subtitleSource: subtitleSource ?? this.subtitleSource,
    );
  }
}
