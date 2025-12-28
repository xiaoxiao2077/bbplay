import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '/model/captcha.dart';
import '/model/setting.dart';
import '/model/biliuser.dart';
import '/pages/login/qrcode.dart';
import '/service/login_service.dart';
import '/service/captcha_service.dart';

class LoginFormPage extends StatefulWidget {
  const LoginFormPage({super.key});

  @override
  State<StatefulWidget> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginFormPage> {
  final GlobalKey<FormState> _telFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _smsFormKey = GlobalKey<FormState>();

  final TextEditingController _telField = TextEditingController();
  final TextEditingController _smsField = TextEditingController();

  final PageController _pageController = PageController();

  Timer? _smsTimer;
  int _smsCountdown = 60;
  bool _smsCanSend = true;

  late String _captchaKey;
  late int _tel;
  late int _smsCode;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _smsTimer?.cancel();
    _telField.dispose();
    _smsField.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _checkLoginStatus() {
    if (Setting.hasLogin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
      });
    }
  }

  void _nextStep() {
    if (_telFormKey.currentState!.validate()) {
      _telFormKey.currentState!.save();
      _navigateToPage(1);
    }
  }

  void _prevStep() {
    _navigateToPage(0);
  }

  void _navigateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _loginWithCode() async {
    if (_smsFormKey.currentState!.validate()) {
      _smsFormKey.currentState!.save();

      try {
        final resp = await LoginService.loginInBySmsCode(
          cid: 86,
          tel: _tel,
          code: _smsCode,
          captchaKey: _captchaKey,
        );

        if (resp.success) {
          final userResp = await LoginService.loadBiliUser();
          if (userResp.success && userResp.data != null) {
            final user = userResp.data!;
            _recordUserAndDismiss(user);
            SmartDialog.showToast('登录成功');
          } else {
            SmartDialog.showToast(userResp.message ?? '获取用户信息失败');
          }
        } else {
          SmartDialog.showToast(resp.message ?? '登录失败');
        }
      } catch (e) {
        SmartDialog.showToast('登录过程中发生错误: $e');
      }
    }
  }

  void _recordUserAndDismiss(BiliUser user) {
    LoginService.signin(user);
    Setting.save('mid', user.mid);
    Setting.save('uname', user.uname);
    Setting.save('hasLogin', true);
    Navigator.of(context).pop();
  }

  Future<void> _sendSmsCode() async {
    if (!_smsCanSend) return;
    if (_telField.text.isEmpty) {
      SmartDialog.showToast('请先输入手机号');
      return;
    }

    try {
      CaptchaService.getCaptcha((Captcha captcha) async {
        try {
          final resp = await LoginService.sendSmsCode(
            cid: 86,
            tel: int.parse(_telField.text),
            token: captcha.token!,
            challenge: captcha.geetest!.challenge!,
            validate: captcha.validate!,
            seccode: captcha.seccode!,
          );
          if (resp.success && resp.data != null) {
            setState(() {
              _captchaKey = resp.data!['captcha_key'];
              _smsCanSend = false;
            });

            SmartDialog.showToast('验证码已发送');
            _startTimer();
          } else {
            SmartDialog.showToast(resp.message ?? '发送验证码失败');
          }
        } catch (e) {
          SmartDialog.showToast('发送验证码时发生错误: $e');
        }
      });
    } catch (e) {
      SmartDialog.showToast('获取验证码时发生错误: $e');
    }
  }

  void _startTimer() {
    _smsTimer?.cancel();
    _smsCountdown = 60;

    _smsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_smsCountdown > 0) {
          _smsCountdown--;
        } else {
          _smsCanSend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: [
                  _buildTelPage(),
                  _buildSmsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close_outlined),
      ),
      actions: [
        TextButton.icon(
          icon: const Icon(Icons.qr_code, size: 20),
          label: const Text('扫码登录'),
          onPressed: _showQRCodePopup,
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildTelPage() {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Form(
        key: _telFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageTitle('手机号验证码登录'),
            _buildPageSubtitle('请使用B站注册的手机号'),
            const SizedBox(height: 40),
            _buildTelInputField(),
            const Spacer(),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSmsPage() {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Form(
        key: _smsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageTitle('输入验证码'),
            _buildPageSubtitle(''),
            const SizedBox(height: 40),
            _buildSmsInputField(),
            const Spacer(),
            _buildSmsPageButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.5,
          ),
    );
  }

  Widget _buildPageSubtitle(String subtitle) {
    return Text(
      subtitle,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
    );
  }

  Widget _buildTelInputField() {
    return TextFormField(
      controller: _telField,
      focusNode: FocusNode(),
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: '手机号码',
        prefixIcon: const Icon(Icons.phone_android_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "手机号码不能为空";
        }
        if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
          return "请输入正确的手机号码";
        }
        return null;
      },
      onSaved: (value) => _tel = int.parse(value!),
      onEditingComplete: _nextStep,
    );
  }

  Widget _buildSmsInputField() {
    return Stack(
      children: [
        TextFormField(
          controller: _smsField,
          focusNode: FocusNode(),
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: '验证码',
            prefixIcon: const Icon(Icons.lock_outline),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              ),
            ),
            counterText: "",
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "验证码不能为空";
            }
            if (value.length != 6) {
              return "验证码为6位数字";
            }
            return null;
          },
          onSaved: (value) => _smsCode = int.parse(value!),
        ),
        Positioned(
          right: 8,
          top: 0,
          bottom: 0,
          child: Center(
            child: SizedBox(
              height: 40,
              child: TextButton(
                onPressed: _smsCanSend ? _sendSmsCode : null,
                child: _smsCanSend
                    ? const Text('获取验证码')
                    : Text('重新获取($_smsCountdown秒)'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _nextStep,
        child: const Text(
          '下一步',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSmsPageButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _prevStep,
            child: const Text(
              '上一步',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _loginWithCode,
            child: const Text(
              '确认登录',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  void _showQRCodePopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          content: ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: 460,
              minHeight: 400,
              maxWidth: 480,
              minWidth: 400,
            ),
            child: const QRCodePopup(),
          ),
        );
      },
    );
  }
}
