import 'package:flutter/material.dart';

import '/utils/utils.dart';
import 'badge.dart';
import '/model/video/item.dart';
import '/service/favorite_service.dart';

/// 视频卡片 - 垂直布局
class VerticalListTile extends StatelessWidget {
  final VideoItem item;
  final Function(VideoItem) onTap;

  const VerticalListTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(context),
          const SizedBox(height: 4),
          _buildTitle(),
          _buildAuthorRow(context),
        ],
      ),
    );
  }

  /// 构建缩略图部分
  Widget _buildThumbnail(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width / (16 / 9);

        return Stack(
          children: [
            Image.network(
              item.cover,
              fit: BoxFit.fill,
              width: width,
              height: height,
            ),
            PBadge(
              bottom: 6,
              right: 7,
              size: 'small',
              type: 'gray',
              text: Utils.timeFormat(item.duration),
            )
          ],
        );
      },
    );
  }

  /// 构建标题部分
  Widget _buildTitle() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 38),
      child: Text(
        item.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// 构建作者信息行
  Widget _buildAuthorRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Image(
          image: AssetImage('assets/images/up_gray.png'),
          width: 18,
          height: 18,
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 1,
          child: Text(
            item.author,
            maxLines: 1,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ),
        _buildFavoriteButton(),
      ],
    );
  }

  /// 构建收藏按钮
  Widget _buildFavoriteButton() {
    return SizedBox(
      width: 24,
      height: 24,
      child: PopupMenuButton(
        position: PopupMenuPosition.under,
        icon: const Icon(Icons.more_vert_outlined),
        tooltip: '收藏',
        padding: const EdgeInsets.all(0),
        menuPadding: const EdgeInsets.all(0),
        onSelected: (_) => FavoriteService.add(item),
        constraints: const BoxConstraints(maxHeight: 50, maxWidth: 80),
        itemBuilder: (BuildContext context) {
          return [
            const PopupMenuItem<String>(
              value: 'bookmark',
              child: Row(
                children: [
                  Icon(Icons.bookmark_border_outlined),
                  SizedBox(width: 2),
                  Text('收藏'),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }
}
