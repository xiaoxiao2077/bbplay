class VideoAuthor {
  late int mid;
  late String name;
  late String face;
  String? sign;

  VideoAuthor.fromJson(Map<String, dynamic> json) {
    mid = json["mid"];
    name = json["name"];
    face = json["face"];
  }
}
