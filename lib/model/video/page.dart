class VideoPage {
  late int cid; //     分P cid
  late int page; //    分P序号
  late String title; //分P标题
  late int duration; //分P时长

  VideoPage.fromJson(Map<String, dynamic> json) {
    cid = json["cid"];
    page = json["page"];
    title = json["part"];
    duration = json["duration"];
  }

  Map toJson() {
    return {
      "cid": cid,
      "page": page,
      "title": title,
      "duration": duration,
    };
  }
}
