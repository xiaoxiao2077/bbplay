import 'package:flutter/material.dart';
import 'package:loading_more_list/loading_more_list.dart';

import 'loader.dart';
import '/utils/navigate.dart';
import '/model/video/item.dart';
import '/widgets/horizon_listtile.dart';
import '/widgets/loading_more_indicator.dart';

class StudyTabView extends StatefulWidget {
  const StudyTabView({super.key, required this.subjectName});
  final String subjectName;

  @override
  State<StatefulWidget> createState() => _TabViewState();
}

class _TabViewState extends State<StudyTabView>
    with AutomaticKeepAliveClientMixin {
  late final SubjectVideoLoader _videoLoader;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _videoLoader = SubjectVideoLoader(widget.subjectName);
  }

  @override
  void dispose() {
    _videoLoader.dispose();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await _videoLoader.refresh(true);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridConfig = _calculateGridConfig(constraints.maxWidth);

        return LoadingMoreList<VideoItem>(
          ListConfig<VideoItem>(
            itemBuilder: _buildListItem,
            sourceList: _videoLoader,
            physics: const FixedOverscrollBouncingScrollPhysics(),
            autoRefresh: true,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: gridConfig.maxCrossAxisExtent,
              childAspectRatio: gridConfig.childAspectRatio,
              mainAxisSpacing: gridConfig.mainAxisSpacing,
              crossAxisSpacing: gridConfig.crossAxisSpacing,
            ),
            indicatorBuilder: (context, status) => LoadingMoreIndicator(
              status: status,
              loadingMoreBase: _videoLoader,
            ),
          ),
        );
      },
    );
  }

  Widget _buildListItem(BuildContext context, VideoItem item, int index) {
    return HorizonListTile(
      item: item,
      selectMode: false,
      onTab: (item) => Navigate.goVideoPlay(context, item),
      onLongPress: () {},
      onSelect: (item) {},
    );
  }

  _GridConfig _calculateGridConfig(double maxWidth) {
    final count = (maxWidth / 500).round();
    final width = maxWidth / count;
    const imageHeight = 100.0;
    final aspectRatio = width / imageHeight;

    return _GridConfig(
      maxCrossAxisExtent: 500,
      childAspectRatio: aspectRatio,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
    );
  }
}

class _GridConfig {
  final double maxCrossAxisExtent;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const _GridConfig({
    required this.maxCrossAxisExtent,
    required this.childAspectRatio,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
  });
}
