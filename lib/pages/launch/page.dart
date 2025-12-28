import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '/model/setting.dart';
import '/pages/home/page.dart';
import '/pages/study/page.dart';
import '/pages/setting/page.dart';
import '/service/history_service.dart';
import '/pages/desktop/home/page.dart';
import '/service/favorite_service.dart';
import '/pages/desktop/history/page.dart';
import '/pages/desktop/favorite/page.dart';

class LaunchPage extends StatefulWidget {
  const LaunchPage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<LaunchPage>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  List<Widget> pages = <Widget>[];
  late PageController pageController;
  DateTime? _lastPressedAt;
  late bool isWideScreen = MediaQuery.of(context).size.width >= 640;

  final List navigationBars = [
    if (Platform.isAndroid || Platform.isIOS) ...[
      {
        'label': "首页",
        'icon': const Icon(Icons.home_outlined, size: 21),
        'selectIcon': const Icon(Icons.home, size: 21),
        'page': const HomeVideoPage(),
      },
    ] else ...[
      {
        'label': "首页",
        'icon': const Icon(Icons.home_outlined, size: 21),
        'selectIcon': const Icon(Icons.home, size: 21),
        'page': const DesktopHomePage(),
      },
    ],
    {
      'label': "学习",
      'icon': const Icon(Icons.trending_up, size: 21),
      'selectIcon': const Icon(Icons.trending_up_outlined, size: 21),
      'page': const StudyVideoPage(),
    },
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) ...[
      {
        'label': "收藏",
        'icon': const Icon(Icons.bookmark_border_outlined, size: 20),
        'selectIcon': const Icon(Icons.bookmark_border, size: 21),
        'page': const DesktopFavoritePage(),
      },
      {
        'label': "历史",
        'icon': const Icon(Icons.history_outlined, size: 20),
        'selectIcon': const Icon(Icons.history, size: 21),
        'page': const DesktopHistoryPage(),
      },
    ],
    {
      'label': "我的",
      'icon': const Icon(Icons.settings_outlined, size: 20),
      'selectIcon': const Icon(Icons.settings, size: 21),
      'page': const SettingPage(),
    }
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: selectedIndex);
    selectedIndex = 0;
    pages = navigationBars.map<Widget>((e) => e['page']).toList();
    AutoOrientation.portraitAutoMode();

    if (Setting.hasLogin) {
      Future.delayed(const Duration(seconds: 10), () {
        FavoriteService.asyncBiliFavorite(Setting.mid!);
      });

      Timer.periodic(const Duration(seconds: 10), (timer) {
        HistoryService.syncUnCollectedToServer();
      });
    }
  }

  void onBackPressed(BuildContext context) {
    if (_lastPressedAt == null ||
        DateTime.now().difference(_lastPressedAt!) >
            const Duration(seconds: 2)) {
      _lastPressedAt = DateTime.now();
      if (selectedIndex != 0) {
        pageController.jumpTo(0);
      }
      SmartDialog.showToast("再按一次退出");
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) => {onBackPressed(context)},
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Opacity(
                opacity: 0.6,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.7),
                          Theme.of(context).colorScheme.surface,
                          Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.1, 0.3, 5]),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                if (isWideScreen)
                  NavigationRail(
                    minWidth: 55.0,
                    backgroundColor: Colors.transparent,
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (int pageIndex) {
                      pageController.jumpToPage(pageIndex);
                    },
                    labelType: NavigationRailLabelType.all,
                    selectedLabelTextStyle: const TextStyle(
                      color: Colors.amber,
                    ),
                    leading: const Column(
                      children: [
                        SizedBox(height: 28),
                      ],
                    ),
                    unselectedLabelTextStyle: const TextStyle(
                      color: Colors.black54,
                    ),
                    destinations: [
                      ...navigationBars.map((e) {
                        return NavigationRailDestination(
                          icon: e['icon'],
                          selectedIcon: e['selectIcon'],
                          label: Text(e['label']),
                        );
                      }).toList(),
                    ],
                  ),
                Expanded(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: pageController,
                    onPageChanged: (index) {
                      setState(() => selectedIndex = index);
                    },
                    children: pages,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: isWideScreen
            ? null
            : NavigationBar(
                selectedIndex: selectedIndex,
                onDestinationSelected: (int pageIndex) =>
                    pageController.jumpToPage(pageIndex),
                destinations: [
                  ...navigationBars.map((e) {
                    return NavigationDestination(
                      icon: e['icon'],
                      selectedIcon: e['selectIcon'],
                      label: e['label'],
                    );
                  }).toList(),
                ],
              ),
      ),
    );
  }
}
