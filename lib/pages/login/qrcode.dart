import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '/model/setting.dart';
import '/model/biliuser.dart';
import '/service/login_service.dart';

class QRCodePopup extends StatefulWidget {
  const QRCodePopup({super.key});

  @override
  State<StatefulWidget> createState() => _QRCodeState();
}

class _QRCodeState extends State<QRCodePopup> {
  String? _qrcodeUrl;
  int _countdown = 180;
  Timer? _countdownTimer;
  Timer? _statusCheckTimer;
  late String _qrcodeKey;
  bool _isLoading = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadQRcode();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  /// 获取登录二维码
  Future<void> _loadQRcode() async {
    if (_isLoading || _isRefreshing) return;
    setState(() {
      _isRefreshing = true;
      _qrcodeUrl = null;
    });

    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();

    try {
      final response = await LoginService.getQrcode();

      if (response.success && response.data != null) {
        _qrcodeKey = response.data!['qrcode_key'];
        setState(() {
          _qrcodeUrl = response.data!['url'];
          _countdown = 180;
        });

        // 启动倒计时
        _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            if (_countdown > 0) {
              _countdown--;
            } else {
              timer.cancel();
            }
          });
        });

        // 启动状态检查
        _statusCheckTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
          if (_countdown > 0) {
            _queryWebQrcodeStatus();
          } else {
            timer.cancel();
          }
        });
      } else {
        SmartDialog.showToast(response.message ?? '获取二维码失败');
      }
    } catch (e) {
      SmartDialog.showToast('获取二维码异常: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
        _isLoading = false;
      });
    }
  }

  /// 轮询二维码登录状态
  /// 0：成功
  /// 86101：未扫码
  /// 86038：二维码已失效
  /// 86090：二维码已扫码未确认
  Future<void> _queryWebQrcodeStatus() async {
    final response = await LoginService.queryQrcodeStatus(_qrcodeKey);

    if (response.success) {
      final int? code = response.data!.code;
      switch (code) {
        case 0:
          try {
            final userResponse = await LoginService.loadBiliUser();
            if (userResponse.success) {
              final user = userResponse.data!;
              await LoginService.signin(user);
              _dismiss(user);
            } else {
              SmartDialog.showToast('获取用户信息失败: ${userResponse.message}');
            }
          } catch (e) {
            SmartDialog.showToast('获取用户信息失败: $e');
          }
          break;
        case 86038: // 二维码已失效
          SmartDialog.showToast('二维码已失效，请重新获取');
          _countdownTimer?.cancel();
          _statusCheckTimer?.cancel();
          setState(() {
            _countdown = 0;
          });
          break;
        case 86101: // 未扫码
          // 继续轮询
          break;
        case 86090: // 二维码已扫码未确认
          SmartDialog.showToast('已扫码，请在手机上确认');
          break;
      }
    }
  }

  void _dismiss(BiliUser user) {
    _countdownTimer?.cancel();
    _statusCheckTimer?.cancel();

    Setting.save('mid', user.mid);
    Setting.save('uname', user.uname);
    Setting.save('hasLogin', true);

    SmartDialog.showToast('登录成功');

    // 关闭弹窗并返回登录成功的标志
    if (mounted) {
      Navigator.of(context).pop(true); // 返回true表示登录成功
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _countdownTimer?.cancel();
        _statusCheckTimer?.cancel();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildQrContainer(),
                const SizedBox(height: 12),
                _buildInstructions(),
                const SizedBox(height: 12),
                _buildStatusIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建头部区域
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          '扫码登录',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _loadQRcode,
              icon: const Icon(Icons.refresh),
              tooltip: '刷新二维码',
            ),
            IconButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // 返回false表示用户取消
              icon: const Icon(Icons.close),
              tooltip: '关闭',
            ),
          ],
        ),
      ],
    );
  }

  /// 构建二维码容器
  Widget _buildQrContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 1,
        child: _buildQrContent(),
      ),
    );
  }

  /// 构建二维码内容
  Widget _buildQrContent() {
    if (_isRefreshing) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_qrcodeUrl != null) {
      return QrImageView(
        data: _qrcodeUrl!,
        version: QrVersions.auto,
        size: 190.0,
        gapless: false,
        embeddedImageStyle: const QrEmbeddedImageStyle(
          size: Size(60, 60),
        ),
      );
    }

    return const Center(
      child: Text(
        '二维码加载失败',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  /// 构建操作指引
  Widget _buildInstructions() {
    return const Column(
      children: [
        Text(
          '请使用哔哩哔哩APP扫码登录',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Text(
          '哔哩哔哩APP中「我的」右上角扫码',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  /// 构建状态指示器
  Widget _buildStatusIndicator() {
    final isExpired = _countdown <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isExpired
            ? Colors.red.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isExpired ? Icons.error_outline : Icons.access_time,
            size: 18,
            color:
                isExpired ? Colors.red : Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 14,
              color: isExpired
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    if (_countdown <= 0) {
      return '二维码已失效';
    }
    final minutes = (_countdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (_countdown % 60).toString().padLeft(2, '0');
    return '有效期: $minutes:$seconds';
  }
}
