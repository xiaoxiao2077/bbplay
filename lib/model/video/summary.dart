///
/// 视频ai总结
/// https://github.com/SocialSisterYi/bilibili-API-collect/blob/master/docs/video/summary.md
class VideoSummary {
  String title = '';
  List<SummarySection> sectionList = [];

  VideoSummary.fromJson(Map<String, dynamic> json) {
    title = json['summary'];
    for (var i in json['outline']) {
      sectionList.add(SummarySection.fromJson(i));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'sectionList': [],
    };
    data['title'] = title;
    data['outline'] = [];
    sectionList.forEach((v) {
      data['outline'].add(v.toJson());
    });
    return data;
  }
}

class SummarySection {
  String title = '';
  List<SummaryOutline> outlineList = [];

  SummarySection.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    for (var i in json['part_outline']) {
      outlineList.add(SummaryOutline.fromJson(i));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['title'] = title;
    data['outlineList'] = [];
    outlineList.forEach((v) {
      data['outlineList'].add(v.toJson());
    });
    return data;
  }
}

class SummaryOutline {
  int timestamp = 0;
  String content = '';

  SummaryOutline.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['content'] = content;
    data['timestamp'] = timestamp;
    return data;
  }
}
