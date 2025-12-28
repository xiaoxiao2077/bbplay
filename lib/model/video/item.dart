class VideoItem {
  late int cid;
  late String bvid;
  late String title;
  int seek = 0;
  late int duration;
  late String author;
  late String cover;
  String source = '';
  String created = '';
  bool checked = false;
  int isLiked = 0;
  List<String> tagList = [];

  VideoItem.fromJson(Map<String, dynamic> json) {
    cid = json["cid"];
    bvid = json["bvid"];
    title = json["title"];
    cover = json.containsKey("cover") ? json["cover"] : json["pic"];
    duration = json["duration"];
    seek = json.containsKey('seek') ? json['seek'] : 0;
    author = json.containsKey('owner') ? json['owner']['name'] : json['author'];
  }

  static VideoItem fromRcmd(Map<String, dynamic> json) {
    var item = VideoItem.fromJson(json);
    item.source = 'rcmd';
    return item;
  }

  static VideoItem fromHistory(Map<String, dynamic> json) {
    var item = VideoItem.fromJson(json);
    item.created = json['created'];
    item.isLiked = json['is_liked'];
    item.source = 'history';
    return item;
  }

  static VideoItem fromFavorite(Map<String, dynamic> json) {
    var item = VideoItem.fromJson(json);
    item.created = json['created'];
    item.source = 'favorite';
    return item;
  }

  static VideoItem fromSubject(Map<String, dynamic> json) {
    var item = VideoItem.fromJson(json);
    if (json.containsKey('tags')) {
      item.tagList = json['tags'].split(',');
      if (item.tagList.length > 5) {
        item.tagList = item.tagList.sublist(0, 5);
      }
    }
    item.source = 'subject';
    return item;
  }

  VideoItem.fromBiliFavorite(Map<String, dynamic> json) {
    cid = json['ugc']['first_cid'];
    bvid = json["bvid"];
    title = json["title"];
    cover = json['cover'];
    duration = json["duration"];
    author = json['upper']['name'];
    source = 'bili_favorite';
  }

  static VideoItem fromRelated(Map<String, dynamic> json) {
    var item = VideoItem.fromJson(json);
    item.source = 'related';
    return item;
  }

  VideoItem.fromSearch(Map<String, dynamic> json) {
    source = 'search';
    cid = json['aid'];
    bvid = json['bvid'];
    title = json['title'].replaceAll(RegExp(r'<.*?>'), '');
    cover = json['pic'] != null && json['pic'].startsWith('//')
        ? 'https:${json['pic']}'
        : json['pic'] ?? '';
    duration = parseDuration(json['duration']);
    author = json['author'];
  }

  Map<String, dynamic> toJson() {
    var json = {
      "cid": cid,
      "bvid": bvid,
      "title": title,
      "cover": cover,
      "duration": duration,
      "seek": seek,
      "author": author,
      "source": source,
      "created": created,
    };
    return json;
  }

  static int parseDuration(String duration) {
    List timeList = duration.split(':');
    int len = timeList.length;
    if (len == 2) {
      return int.parse(timeList[0]) * 60 + int.parse(timeList[1]);
    }
    if (len == 3) {
      return int.parse(timeList[0]) * 3600 +
          int.parse(timeList[1]) * 60 +
          int.parse(timeList[2]);
    }
    return 0;
  }
}
