class VideoStats {
  int? like;
  int? dislike;
  int? coin;
  int? favorite;
  int? view;
  int? danmaku;

  VideoStats({
    this.like,
    this.dislike,
    this.coin,
    this.favorite,
    this.view,
    this.danmaku,
  });

  factory VideoStats.fromJson(Map<String, dynamic> json) {
    return VideoStats(
      like: json['like'] as int?,
      dislike: json['dislike'] as int?,
      coin: json['coin'] as int?,
      favorite: json['favorite'] as int?,
      view: json['view'] as int?,
      danmaku: json['danmaku'] as int?,
    );
  }
}
