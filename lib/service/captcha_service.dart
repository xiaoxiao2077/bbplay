import 'dart:io';
import 'package:gt3_flutter_plugin/gt3_flutter_plugin.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '/utils/loggy.dart';
import '/model/captcha.dart';
import './base_service.dart';

///注意： gt3不支持mac和windows系统
class CaptchaService extends BaseService {
  /// 从服务器获取极验验证码的基础数据
  static Future<ApiResponse<Captcha>> _queryCaptcha() async {
    var client = await BaseService.getPassportClient();
    var resp = await BaseService.get(
      client,
      '/x/passport-login/captcha?source=main_web',
      parser: (data) => Captcha.fromJson(data),
    );
    return resp;
  }

  /// 获取并显示极验验证码
  static Future<void> getCaptcha(Function(Captcha) onSuccess) async {
    final Gt3FlutterPlugin geetest = Gt3FlutterPlugin();
    SmartDialog.showLoading(msg: '请求中...');

    try {
      var response = await _queryCaptcha();

      if (response.success && response.data != null) {
        SmartDialog.dismiss();
        Captcha captchaData = response.data!;

        // 检查必要数据是否存在
        if (captchaData.geetest?.challenge == null ||
            captchaData.geetest?.gt == null) {
          SmartDialog.showToast('验证码数据不完整');
          return;
        }

        var registerData = Gt3RegisterData(
          challenge: captchaData.geetest!.challenge!,
          gt: captchaData.geetest!.gt!,
          success: true,
        );

        // 注册事件处理器
        geetest.addEventHandler(
          onShow: (Map<String, dynamic> message) async {},
          onClose: (Map<String, dynamic> message) async {
            SmartDialog.showToast('取消验证');
          },
          onResult: (Map<String, dynamic> message) async {
            String code = message["code"];
            if (code == "1") {
              SmartDialog.showToast('验证成功');
              captchaData.validate = message['result']['geetest_validate'];
              captchaData.seccode = message['result']['geetest_seccode'];
              captchaData.geetest!.challenge =
                  message['result']['geetest_challenge'];

              onSuccess(captchaData);
            } else {
              Loggy.e("Captcha result code : $code");
              SmartDialog.showToast('验证失败，请重试');
            }
          },
          onError: (Map<String, dynamic> message) async {
            String code = message["code"];
            if (Platform.isAndroid) {
              _handleAndroidError(code);
            } else if (Platform.isIOS) {
              _handleIOSError(code);
            }
          },
        );

        geetest.startCaptcha(registerData);
      } else {
        SmartDialog.dismiss();
        SmartDialog.showToast(response.message ?? '获取验证码失败');
      }
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('验证码服务异常: $e');
    }
  }

  /// 处理Android平台错误
  static void _handleAndroidError(String code) {
    String errorMsg = '';
    switch (code) {
      case "-2":
        errorMsg = '调用异常';
        break;
      case "-1":
        errorMsg = '参数不合法';
        break;
      case "201":
        errorMsg = '网络无法访问';
        break;
      case "202":
        errorMsg = '数据解析错误';
        break;
      case "204":
        errorMsg = '加载超时';
        break;
      default:
        errorMsg = '验证过程出现错误';
    }
    SmartDialog.showToast(errorMsg);
  }

  /// 处理iOS平台错误
  static void _handleIOSError(String code) {
    String errorMsg = '';
    switch (code) {
      case "-1009":
        errorMsg = '网络无法访问';
        break;
      case "-1004":
        errorMsg = '无法查找到HOST';
        break;
      case "-1002":
        errorMsg = '非法的URL';
        break;
      case "-1001":
        errorMsg = '网络超时';
        break;
      case "-1":
        errorMsg = '参数不合法';
        break;
      default:
        errorMsg = '验证过程出现错误';
    }
    SmartDialog.showToast(errorMsg);
  }
}
