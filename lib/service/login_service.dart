import '/model/qrcode.dart';
import '/model/setting.dart';
import '/model/biliuser.dart';
import '/service/base_service.dart';
import '/utils/request/cookie.dart';

class LoginService extends BaseService {
  /// web端发送短信验证码
  static Future<ApiResponse<dynamic>> sendSmsCode({
    int? cid,
    required int tel,
    required String token,
    required String challenge,
    required String validate,
    required String seccode,
  }) async {
    try {
      final data = {
        'cid': cid,
        'tel': tel,
        "source": "main-fe-header",
        'token': token,
        'challenge': challenge,
        'validate': validate,
        'seccode': seccode,
      };
      final client = await BaseService.getPassportClient();
      final response = await BaseService.post(
        client,
        '/x/passport-login/web/sms/send', // 使用正确的路径
        data: data,
      );

      return response;
    } catch (e) {
      return ApiResponse.error('发送验证码失败: $e');
    }
  }

  /// web端验证码登录
  static Future<ApiResponse<dynamic>> loginInBySmsCode({
    int? cid,
    required int tel,
    required int code,
    required String captchaKey,
  }) async {
    try {
      final data = {
        "cid": cid,
        "tel": tel,
        "code": code,
        "source": "main_mini",
        "keep": 0,
        "captcha_key": captchaKey,
        "go_url": "https://www.bilibili.com/",
      };

      final client = await BaseService.getPassportClient();
      final response = await BaseService.post(
        client,
        '/x/passport-login/web/login/sms', // 使用正确的路径
        data: data,
      );
      return response;
    } catch (e) {
      return ApiResponse.error('短信登录失败: $e');
    }
  }

  /// 获取盐hash跟PubKey
  static Future<ApiResponse<dynamic>> getWebKey() async {
    try {
      final client = await BaseService.getPassportClient();
      final response = await client.get(
        '/x/passport-login/web/key',
        {'disable_rcmd': 0, 'local_id': ''},
      );

      return response;
    } catch (e) {
      return ApiResponse.error('获取密钥失败: $e');
    }
  }

  /// web端登录二维码
  static Future<ApiResponse<dynamic>> getQrcode() async {
    final client = await BaseService.getPassportClient();
    final response =
        await BaseService.get(client, '/x/passport-login/web/qrcode/generate');
    return response;
  }

  /// web端二维码轮询登录状态
  static Future<ApiResponse<Qrcode>> queryQrcodeStatus(String qrcodeKey) async {
    final client = await BaseService.getPassportClient();
    final response = await BaseService.get(
      client,
      '/x/passport-login/web/qrcode/poll',
      params: {'qrcode_key': qrcodeKey},
      parser: (data) {
        return Qrcode.fromJson(data);
      },
    );
    return response;
  }

  /// 小程序注册
  static Future<ApiResponse<dynamic>> signin(BiliUser user) async {
    try {
      final client = await BaseService.getBaseClient();
      final response = await BaseService.post(
        client,
        '/api/users/signin',
        data: user.toJson(),
      );

      return response;
    } catch (e) {
      return ApiResponse.error('注册失败: $e');
    }
  }

  static Future<ApiResponse<BiliUser>> loadBiliUser() async {
    try {
      final client = await BaseService.getApiClient();
      final response = await BaseService.get<BiliUser>(
        client,
        '/x/web-interface/nav',
        parser: (data) {
          return BiliUser.fromJson(data);
        },
      );
      return response;
    } catch (e) {
      return ApiResponse.error('获取用户信息失败: $e');
    }
  }

  static Future logout() async {
    Setting.hasLogin = false;
    var manager = await RequestCookie.getManager();
    manager.cookieJar.deleteAll();
  }
}
