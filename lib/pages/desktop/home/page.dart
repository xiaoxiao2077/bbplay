import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'loader.dart';
import 'search.dart';
import '/model/setting.dart';
import '/utils/function.dart';
import '/model/video/item.dart';
import '/config/constants.dart';
import '/widgets/wallclock.dart';
import '/pages/login/qrcode.dart';
import '/service/search_service.dart';
import '/widgets/home_search_bar.dart';
import '/widgets/vertical_listtile.dart';
import '/widgets/loading_more_indicator.dart';

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<StatefulWidget> createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHomePage> {
  bool searchMode = false;
  late LoadingMoreBase<VideoItem> listLoader = RcmdVideoLoader();
  bool _hasCheckedLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    if (_hasCheckedLogin) return;

    // 检查用户是否已登录
    if (!Setting.hasLogin) {
      final prefs = await SharedPreferences.getInstance();
      final lastPromptDate = prefs.getString('last_login_prompt');
      final today = DateTime.now().toString().split(' ')[0]; // YYYY-MM-DD

      // 如果今天还没有提示过，则显示登录提示
      if (lastPromptDate != today) {
        await prefs.setString('last_login_prompt', today);
        _showLoginPrompt();
      }
    }

    _hasCheckedLogin = true;
  }

  Future<void> _showLoginPrompt() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('登录提示'),
          content: const Text('登录后可获得更好的使用体验，包括同步收藏、观看历史等功能。'),
          actions: <Widget>[
            TextButton(
              child: const Text('暂不登录'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await showDialog(
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
              },
              child: const Text('去登录'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      clipBehavior: Clip.hardEdge,
      margin: const EdgeInsets.only(
        left: StyleString.safeSpace,
        right: StyleString.safeSpace,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(StyleString.imgRadius),
      ),
      child: RefreshIndicator(
        onRefresh: () async {
          await listLoader.refresh();
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gridConfig = _calculateGridConfig(constraints.maxWidth);
            return LoadingMoreList(
              ListConfig(
                itemBuilder: (BuildContext context, VideoItem item, int index) {
                  return VerticalListTile(
                    item: item,
                    onTap: (item) => goVideoPlay(context, item),
                  );
                },
                sourceList: listLoader,
                lastChildLayoutType: LastChildLayoutType.foot,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 260,
                  childAspectRatio: gridConfig.aspectRatio,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 10,
                ),
                indicatorBuilder: (context, status) {
                  return LoadingMoreIndicator(
                      status: status, loadingMoreBase: listLoader);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  GridConfig _calculateGridConfig(double maxWidth) {
    final count = (maxWidth / 260).ceil();
    final width = maxWidth / count;
    final imageHeight = width / (16 / 10) + 65;
    final aspectRatio = width / imageHeight;
    return GridConfig(count: count, width: width, aspectRatio: aspectRatio);
  }

  Future<List<String>> _fetchSuggestions(String term) async {
    final resp = await SearchService.searchSuggest(term);
    if (resp.success) {
      return resp.data ?? [];
    } else {
      return [];
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return HomeSearchBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      searchBackgroundColor: Theme.of(context)
          .colorScheme
          .onSecondaryContainer
          .withValues(alpha: 0.05),
      onSearch: (word) {
        setState(() {
          searchMode = true;
          listLoader = SearchLoader(keyword: word);
        });
      },
      asyncSuggestions: (value) async => await _fetchSuggestions(value),
      actions: const [
        SizedBox(width: 10),
        ClockButton(),
        SizedBox(width: 8),
      ],
    );
  }
}

class GridConfig {
  final int count;
  final double width;
  final double aspectRatio;

  GridConfig({
    required this.count,
    required this.width,
    required this.aspectRatio,
  });
}

class ClockButton extends StatelessWidget {
  const ClockButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => const SizedBox(
            height: 320,
            child: ClockPanel(),
          ),
          clipBehavior: Clip.hardEdge,
          isScrollControlled: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
          ),
        );
      },
      child: Icon(
        size: 32,
        Icons.punch_clock,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
