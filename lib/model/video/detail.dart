import './page.dart';
import './stats.dart';
import './author.dart';
import './subtitle.dart';

class VideoDetail {
  late int cid;
  late String bvid;
  late String cover;
  late String title;
  late int pubdate;
  late String desc = '';
  late int duration;
  late VideoStats stat;

  List<VideoPage> pageList = [];
  List<Subtitle> subtitleList = [];
  List<VideoAuthor> authorList = []; //合作者
  get author {
    return authorList.first;
  }

  VideoDetail.fromJson(Map<String, dynamic> json) {
    bvid = json["bvid"];
    cid = json["cid"];
    cover = json["pic"];
    title = json["title"];
    pubdate = json["pubdate"];
    duration = json["duration"];
    if (json['desc_v2'] != null && json['desc_v2'][0] != null) {
      desc = json['desc_v2'][0]['raw_text'];
    } else {
      desc = json["desc"];
    }

    stat = VideoStats.fromJson(json["stat"]);

    pageList = json["pages"] == null
        ? []
        : List<VideoPage>.from(
            json["pages"]!.map((e) => VideoPage.fromJson(e)));
    subtitleList = json["subtitle"]["list"] == null
        ? []
        : List<Subtitle>.from(
            json["subtitle"]["list"].map((e) => Subtitle.fromJson(e)));

    if (json["owner"] != null) {
      authorList.add(VideoAuthor.fromJson(json["owner"]));
    } else if (json["staff"] != null) {
      authorList.addAll(List<VideoAuthor>.from(
          json["staff"]!.map((e) => VideoAuthor.fromJson(e))));
    }
  }
}
