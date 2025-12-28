import 'package:flutter/material.dart';

import '/widgets/wallclock_wrapper.dart';
import './tabconf.dart';

class StudyVideoPage extends StatefulWidget {
  const StudyVideoPage({super.key});

  @override
  State<StatefulWidget> createState() => _StudyVideoState();
}

class _StudyVideoState extends State<StudyVideoPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final List<Widget> _tabPages;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabPages = tabsConfig.map<Widget>((tab) => tab['page'] as Widget).toList();
    _tabController = TabController(
      initialIndex: _currentIndex,
      length: tabsConfig.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WallClockWrapper(
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        body: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        children: [
          const SizedBox(height: 4),
          _buildTabBar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: TabBarView(
                controller: _tabController,
                children: _tabPages,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: Align(
        alignment: Alignment.center,
        child: TabBar(
          controller: _tabController,
          tabs: [
            for (final tab in tabsConfig) Tab(text: tab['label'] as String)
          ],
          isScrollable: true,
          dividerColor: Colors.transparent,
          enableFeedback: true,
          splashBorderRadius: BorderRadius.circular(10),
          tabAlignment: TabAlignment.center,
          onTap: _onTabTapped,
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() {
      if (_currentIndex == index) {
        // 如果点击的是当前选中的标签，可以执行刷新操作
        // 这里可以根据需要添加具体逻辑
      }
      _currentIndex = index;
    });
  }
}
