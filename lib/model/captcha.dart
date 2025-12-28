import '../utils/loggy.dart';

class Geetest {
  String? gt;
  String? challenge;
  Geetest.fromJson(Map<String, dynamic> json) {
    gt = json["gt"];
    challenge = json["challenge"];
  }
}

class Captcha {
  String? type;
  String? token;
  Geetest? geetest;
  String? validate;
  String? seccode;

  Captcha.fromJson(Map<String, dynamic> json) {
    Loggy.d(json);
    type = json["type"];
    token = json["token"];
    geetest =
        json["geetest"] != null ? Geetest.fromJson(json["geetest"]) : null;
  }
}
