import 'dart:io';
import 'package:flutter/material.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:provider/provider.dart';

import '/widgets/wallclock_wrapper.dart';
import './tabconf.dart';

class GradeNotifier extends ChangeNotifier {
  String _selectedGrade = 'primary_upper';

  String get selectedGrade => _selectedGrade;

  void setGrade(String grade) {
    _selectedGrade = grade;
    notifyListeners();
  }
}

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
  final GradeNotifier _gradeNotifier = GradeNotifier();

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
    _gradeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _gradeNotifier,
      child: WallClockWrapper(
        child: Scaffold(
          extendBody: true,
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: _buildContent(),
          floatingActionButton: _buildFloatingActionButton(),
        ),
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
          onTap: (index) {
            _currentIndex = index;
          },
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      width: 62,
      margin: Platform.isAndroid || Platform.isIOS
          ? const EdgeInsets.only(bottom: 66.0)
          : const EdgeInsets.only(bottom: 16.0),
      child: CustomRadioButton<String>(
        elevation: 0,
        horizontal: true,
        absoluteZeroSpacing: false,
        unSelectedColor: Colors.transparent,
        selectedColor: Colors.blue,
        buttonLables: const ['小初', '小高', '初中'],
        buttonValues: const ['primary', 'primary_upper', 'junior'],
        defaultSelected: _gradeNotifier.selectedGrade,
        radioButtonValue: (value) {
          if (value != null) {
            _gradeNotifier.setGrade(value);
          }
        },
        width: 58,
        height: 28,
        enableShape: true,
        shapeRadius: 8,
        margin: const EdgeInsets.all(0),
        selectedBorderColor: Colors.blue,
        unSelectedBorderColor: Colors.grey.withValues(alpha: 0.5),
        buttonTextStyle: const ButtonTextStyle(
          selectedColor: Colors.white,
          unSelectedColor: Colors.grey,
          textStyle: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          selectedTextStyle: TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
