//url: , refresh_token: , timestamp: 0, code: 86101, message: 未扫码
class Qrcode {
  String? url;
  String? refreshToken;
  int? timestamp;
  int? code;
  String? message;

  Qrcode.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    refreshToken = json['refresh_token'];
    timestamp = json['timestamp'];
    code = json['code'];
    message = json['message'];
  }
}
