import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '/provider/playing.dart';
import '/config/constants.dart';

class VideoBottomView extends StatelessWidget {
  const VideoBottomView({super.key});

  @override
  Widget build(BuildContext context) {
    PlayingState playingState = context.watch<PlayingState>();
    if (playingState.detail == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final description = playingState.detail!.desc;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 操作按钮区域
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
          ),
          // 分割线
          Divider(
            thickness: 0.3,
            color: Theme.of(context).dividerColor,
          ),
          const SizedBox(height: 6.0),
          // 视频描述
          if (description.isNotEmpty) ...[
            SelectableRegion(
              focusNode: FocusNode(),
              selectionControls: MaterialTextSelectionControls(),
              child: Text(
                description,
                style: TextStyle(
                  height: 1.4,
                  fontSize: 13.0,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }

  // 处理点赞
  void _handleLike(BuildContext context) {
    final playingState = context.read<PlayingState>();
    playingState.toggleLike();
  }

  // 处理收藏
  void _handleFavorite(BuildContext context) {
    final playingState = context.read<PlayingState>();
    playingState.toggleFavorite();
  }

  // 处理点踩
  void _handleDislike(BuildContext context) {
    final playingState = context.read<PlayingState>();
    playingState.toggleDislike();
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
