import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/provider/playing.dart';
import '/model/video/page.dart';

class PagesList extends StatelessWidget {
  const PagesList({super.key});

  @override
  Widget build(BuildContext context) {
    final playingState = context.watch<PlayingState>();

    if (playingState.detail == null ||
        playingState.detail!.pageList.length <= 1) {
      return const SizedBox();
    }

    final pageList = playingState.detail!.pageList;

    final currentIndex = pageList.indexWhere(
      (element) => element.cid == playingState.videoItem.cid,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, pageList.length),
        const SizedBox(height: 12),
        _buildPageList(context, pageList, currentIndex, playingState),
      ],
    );
  }

  /// 构建标题栏
  Widget _buildHeader(BuildContext context, int count) {
    return Row(
      children: [
        const Text(
          '视频选集',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count集',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建分页列表
  Widget _buildPageList(
    BuildContext context,
    List<VideoPage> pageList,
    int currentIndex,
    PlayingState playingState,
  ) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: pageList.length,
        itemBuilder: (context, index) {
          final page = pageList[index];
          final isCurrent = index == currentIndex;

          return _buildPageCard(
            context,
            page,
            index,
            isCurrent,
            playingState,
          );
        },
      ),
    );
  }

  /// 构建单个分页卡片
  Widget _buildPageCard(
    BuildContext context,
    VideoPage page,
    int index,
    bool isCurrent,
    PlayingState playingState,
  ) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isCurrent
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isCurrent
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).dividerColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () => playingState.switchVideo(
            item: playingState.videoItem,
            cid: page.cid,
            page: page.page,
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (isCurrent) ...[
                  _buildPlayingIndicator(context),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPageNumber(context, page.page, isCurrent),
                      const SizedBox(height: 2),
                      _buildPageTitle(page.title, isCurrent, context),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建播放指示器
  Widget _buildPlayingIndicator(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.play_arrow,
          color: Colors.white,
          size: 8,
        ),
      ),
    );
  }

  /// 构建分页编号
  Widget _buildPageNumber(
      BuildContext context, int pageNumber, bool isCurrent) {
    return Text(
      'P$pageNumber',
      style: TextStyle(
        fontSize: 11,
        color: isCurrent
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  /// 构建分页标题（限制长度）
  Widget _buildPageTitle(String title, bool isCurrent, BuildContext context) {
    // 限制标题长度，避免过长影响布局
    String displayTitle = title;
    if (displayTitle.length > 18) {
      displayTitle = '${displayTitle.substring(0, 15)}...';
    }

    return Text(
      displayTitle,
      maxLines: 1,
      style: TextStyle(
        fontSize: 12,
        color: isCurrent
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }
}
