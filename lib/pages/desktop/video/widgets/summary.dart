import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/utils/utils.dart';
import '/player/agent.dart';
import '/provider/playing.dart';

class SummaryView extends StatefulWidget {
  const SummaryView({super.key});

  @override
  State<StatefulWidget> createState() => _SummaryState();
}

class _SummaryState extends State<SummaryView> {
  @override
  Widget build(BuildContext context) {
    PlayingState playingState = context.watch<PlayingState>();

    if (playingState.summary == null ||
        playingState.summary!.sectionList.isEmpty) {
      return const SizedBox();
    }

    // 获取所有时间节点并展平
    final allItems = playingState.summary!.sectionList
        .expand((section) => section.outlineList)
        .toList();

    // 计算合适的高度，最大不超过220，最小不低于120
    double containerHeight =
        (allItems.length * 50.0 + 60.0).clamp(120.0, 220.0);

    return Container(
      constraints: BoxConstraints(
        maxHeight: containerHeight,
        minHeight: 120.0,
        minWidth: 0.0,
      ),
      margin: const EdgeInsets.fromLTRB(0, 5, 5, 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.summarize_outlined,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '视频概要',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 0.5,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
          ),
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: allItems.length,
              itemBuilder: (context, index) {
                final item = allItems[index];

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        PlayerAgent.seek(Duration(seconds: item.timestamp));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 时间戳标记
                            Container(
                              width: 48,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.2),
                                  width: 0.5,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                Utils.timeFormat(item.timestamp),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 播放图标
                            Icon(
                              Icons.play_circle_outline,
                              size: 20,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.6),
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
