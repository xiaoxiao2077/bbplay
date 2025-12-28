class Subtitle {
  int? id; //	        字幕id
  String? lan; //     字幕语言
  String? language; //字幕语言名称
  String? url; //	    json格式字幕文件url

  Subtitle.fromJson(Map<String, dynamic> json) {
    id = json["id"];
    lan = json["lan"];
    language = json["lan_doc"];
    url = json["subtitle_url"];
  }
}
