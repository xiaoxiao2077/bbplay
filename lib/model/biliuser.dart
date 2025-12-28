class BiliUser {
  late int mid;
  late String face;
  late String uname;

  BiliUser.fromJson(Map<String, dynamic> json) {
    mid = json.containsKey('mid') ? json['mid'] : 0;
    face = json.containsKey('face') ? json['face'] : '';
    uname = json.containsKey('uname') ? json['uname'] : '';
  }

  BiliUser.defaultUser() {
    mid = 0;
    face = '';
    uname = '';
  }

  Map<String, dynamic> toJson() {
    return {
      'mid': mid,
      'face': face,
      'uname': uname,
    };
  }
}
