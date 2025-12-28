import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'pages_list.dart';
import '/utils/utils.dart';
import '/provider/playing.dart';
import '/config/constants.dart';
import '/model/video/detail.dart';

class VideoDetailPanel extends StatefulWidget {
  const VideoDetailPanel({super.key});

  @override
  State<StatefulWidget> createState() => _VideoDetailPanelState();
}

class _VideoDetailPanelState extends State<VideoDetailPanel> {
  double sheetHeight = 50;
  late final dynamic owner;
  late int mid;
  late String memberHeroTag;
  bool isExpand = false;

  @override
  Widget build(BuildContext context) {
    PlayingState playingState = context.watch<PlayingState>();
    if (playingState.detail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(left: StyleString.safeSpace, top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          buildStaffUp(playingState.detail!),
          ExpansionTile(
            tilePadding: const EdgeInsets.all(0),
            childrenPadding: const EdgeInsets.only(bottom: 10),
            dense: true,
            showTrailingIcon: false,
            title: Text(
              playingState.detail!.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            initiallyExpanded: false,
            subtitle: Text(
              Utils.dateFormat(playingState.detail!.pubdate,
                  formatType: 'detail'),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(
                          text:
                              'https://www.bilibili.com/video/${playingState.videoItem.bvid}',
                        ));
                        SmartDialog.showToast('已复制');
                      },
                      child: Text(
                        'bilibili.com/video/${playingState.videoItem.bvid}',
                        style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableRegion(
                      focusNode: FocusNode(),
                      selectionControls: MaterialTextSelectionControls(),
                      child: Text(
                        playingState.detail!.desc,
                        style: const TextStyle(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          buildActionGrid(context, playingState),
          const PagesList(),
        ],
      ),
    );
  }

  Widget buildActionGrid(BuildContext context, PlayingState playingState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ActionItem(
          icon: FontAwesomeIcons.thumbsUp,
          selectIcon: FontAwesomeIcons.solidThumbsUp,
          onTap: () => _handleLike(context),
          selectStatus: playingState.hasLike,
          text: _formatNumber(playingState.detail!.stat.like ?? 0),
        ),
        _ActionItem(
          icon: FontAwesomeIcons.star,
          selectIcon: FontAwesomeIcons.solidStar,
          onTap: () => _handleFavorite(context),
          selectStatus: playingState.hasFav,
          text: _formatNumber(playingState.detail!.stat.favorite ?? 0),
        ),
        _ActionItem(
          icon: FontAwesomeIcons.thumbsDown,
          selectIcon: FontAwesomeIcons.solidThumbsDown,
          onTap: () => _handleDislike(context),
          selectStatus: playingState.hasDisLike,
          text: '踩',
        ),
      ],
    );
  }

  Widget buildStaffUp(VideoDetail videoDetail) {
    if (videoDetail.authorList.length == 1) {
      return ListTile(
        dense: true,
        contentPadding: const EdgeInsets.all(0),
        leading: SizedBox(
          width: 30,
          height: 30,
          child: CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(videoDetail.authorList[0].face!),
          ),
        ),
        title: Text(
          videoDetail.authorList[0].name!,
          style: const TextStyle(fontSize: 13),
        ),
      );
    } else {
      return SizedBox(
        height: 52,
        child: ListView.builder(
          itemCount: videoDetail.authorList.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemExtent: 90,
          itemBuilder: (context, index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    videoDetail.authorList[index].face!,
                  ),
                ),
                Text(
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.clip,
                  videoDetail.authorList[index].name!,
                  style: const TextStyle(fontSize: 11),
                ),
              ],
            );
          },
        ),
      );
    }
  }

  // 处理点赞
  void _handleLike(BuildContext context) {
    final videoState = context.read<PlayingState>();
    videoState.toggleLike();
  }

  // 处理收藏
  void _handleFavorite(BuildContext context) {
    final videoState = context.read<PlayingState>();
    videoState.toggleFavorite();
  }

  // 处理点踩
  void _handleDislike(BuildContext context) {
    final videoState = context.read<PlayingState>();
    videoState.toggleDislike();
  }

  // 格式化数字显示
  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}万';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final IconData selectIcon;
  final VoidCallback onTap;
  final String text;
  final bool selectStatus;

  const _ActionItem({
    required this.icon,
    required this.selectIcon,
    required this.onTap,
    required this.text,
    required this.selectStatus,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: StyleString.mdRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                selectStatus ? selectIcon : icon,
                key: ValueKey<bool>(selectStatus),
                color: selectStatus
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline,
                size: 18.0,
              ),
            ),
            const SizedBox(width: 4.0),
            Text(
              text,
              style: TextStyle(
                fontSize: 12.0,
                color: selectStatus
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
