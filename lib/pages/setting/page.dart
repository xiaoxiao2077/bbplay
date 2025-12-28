import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '/model/setting.dart';
import '/utils/function.dart';
import '/widgets/upgrade.dart';
import '/pages/login/qrcode.dart';
import '/service/login_service.dart';
import '/service/system_service.dart';
import '/service/favorite_service.dart';
import '/pages/desktop/timeslot/page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<SettingPage> {
  int _selectedIndex = 0;
  bool _hasLogin = Setting.hasLogin;
  late final PageController _pageController =
      PageController(initialPage: _selectedIndex);
  late final bool _isWideScreen = MediaQuery.of(context).size.width >= 640;

  final List<Widget> _pages = [
    const SizedBox(),
    const TimeslotPage(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTap(int index, [VoidCallback? action]) {
    setState(() {
      _selectedIndex = index;
      if (_isWideScreen && index < _pages.length) {
        _pageController.jumpToPage(index);
      }
      action?.call();
    });
  }

  void _showSyncBiliFavorite() {
    showConfirmDialog(
      context,
      title: "同步B站收藏夹",
      content: "在 B 站收藏夹中创建名为「小晓」的文件夹，将视频收藏至该文件夹后，视频会同步至本 APP 的推荐列表",
      confirmText: "确定",
    );
    FavoriteService.asyncBiliFavorite(Setting.mid!);
  }

  Future<void> _handleLogout() async {
    final confirm = await showConfirmDialog(
      context,
      title: '退出',
      content: '确认退出登录吗？',
    );

    if (confirm) {
      await LoginService.logout();
      setState(() => _hasLogin = false);
    }
  }

  Future<void> _handleLogin() async {
    if (!_isWideScreen) {
      await context.push('/login');
    } else {
      var hasLogin = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
                minWidth: 300,
                maxHeight: 450,
              ),
              child: const QRCodePopup(),
            ),
          );
        },
      );
      setState(() {
        _hasLogin = hasLogin;
      });
    }
  }

  void _checkUpgrade() async {
    final response = await SystemService.checkUpgrade();
    if (response.success && response.data!.needUpgrade) {
      showDialog(
        context: context,
        builder: (context) => UpgradeDialog(
          title: "检测到新版本",
          content: "1. 新增设备管理功能\n2. 优化网络连接稳定性\n3. 修复已知问题",
          onUpgrade: () {
            var url = Uri.parse(response.data!.url!);
            launchUrl(url);
          },
        ),
      );
    } else {
      SmartDialog.showToast('已经是最新版本');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.topLeft,
          child: Text(
            '我的设置',
            style: TextStyle(fontSize: 16),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.transparent,
      body: Row(
        children: [
          _buildNavigationSidebar(primaryColor),
          if (_isWideScreen)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                children: _pages,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavigationSidebar(Color primaryColor) {
    return Container(
      width: _isWideScreen ? 260 : MediaQuery.of(context).size.width,
      decoration: _isWideScreen
          ? const BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey, width: 1),
              ),
            )
          : null,
      child: Column(
        children: [
          if (Platform.isIOS || Platform.isAndroid) ...[
            _buildNavListTile(
              icon: Icons.history,
              title: "观看记录",
              primaryColor: primaryColor,
              onTap: () => context.push('/history'),
            ),
            _buildNavListTile(
              icon: Icons.star_border,
              title: "我的收藏",
              primaryColor: primaryColor,
              onTap: () => context.push('/favorites'),
            ),
          ],
          _buildNavListTile(
            icon: Icons.upgrade,
            title: "检查更新",
            primaryColor: primaryColor,
            onTap: () => _checkUpgrade(),
          ),
          _buildNavListTile(
            icon: Icons.access_time_outlined,
            title: "时间管理",
            primaryColor: primaryColor,
            onTap: () {
              if (_isWideScreen) {
                _onNavItemTap(1);
              } else {
                context.push('/timeslot');
              }
            },
          ),
          _buildNavListTile(
            icon: Icons.sync,
            title: "收藏同步",
            primaryColor: primaryColor,
            onTap: _showSyncBiliFavorite,
          ),
          if (_hasLogin)
            _buildNavListTile(
              icon: Icons.logout,
              title: '退出登录',
              primaryColor: primaryColor,
              onTap: _handleLogout,
            ),
          if (!_hasLogin)
            _buildNavListTile(
              icon: Icons.login,
              title: '登录',
              primaryColor: primaryColor,
              onTap: _handleLogin,
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNavListTile({
    required IconData icon,
    required String title,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontSize: 15)),
      leading: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Icon(icon, color: primaryColor),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.only(left: 15, top: 2, bottom: 2),
    );
  }
}
