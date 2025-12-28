import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/utils/utils.dart';
import '/provider/playing.dart';
import '/model/video/page.dart';

class PageListView extends StatefulWidget {
  const PageListView({super.key});

  @override
  State<StatefulWidget> createState() => _PageListState();
}

class _PageListState extends State<PageListView> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    PlayingState state = context.watch<PlayingState>();
    if (state.detail == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (state.detail!.pageList.length <= 1) {
      return const SizedBox();
    }

    List<VideoPage> pageList = state.detail!.pageList;
    PlayingState mediaState = context.watch<PlayingState>();
    currentIndex =
        pageList.indexWhere((element) => element.cid == mediaState.cid);
    if (currentIndex == -1) currentIndex = 0;

    // 计算合适的高度，最大不超过200，最小不低于100，每个条目约36像素高
    double containerHeight =
        (pageList.length * 36.0 + 60.0).clamp(100.0, 200.0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: containerHeight,
        minHeight: 100,
      ),
      margin: const EdgeInsets.fromLTRB(0, 2, 8, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(
              '视频选集 (${pageList.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
          Flexible(
            child: ListView.builder(
              itemCount: pageList.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int i) {
                bool isCurrentIndex = i == currentIndex;
                VideoPage page = pageList[i];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  child: Material(
                    color: isCurrentIndex
                        ? Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          currentIndex = i;
                          mediaState.switchVideo(
                            item: state.videoItem,
                            cid: page.cid,
                            page: i + 1,
                          );
                          context.read<PlayingState>().switchVideo(
                              item: state.videoItem, cid: page.cid);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: isCurrentIndex
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                                border: isCurrentIndex
                                    ? null
                                    : Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline,
                                        width: 1.5,
                                      ),
                              ),
                              alignment: Alignment.center,
                              child: isCurrentIndex
                                  ? Icon(
                                      Icons.play_arrow,
                                      size: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    )
                                  : Text(
                                      "${i + 1}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: isCurrentIndex
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                page.title,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: isCurrentIndex
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              Utils.timeFormat(page.duration),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
