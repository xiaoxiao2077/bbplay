import 'package:flutter/material.dart';

import '/utils/utils.dart';
import 'badge.dart';
import '/model/video/item.dart';
import '/service/favorite_service.dart';

class HorizonListTile extends StatefulWidget {
  final VideoItem item;
  final bool selectMode;
  final Function(VideoItem item) onTab;
  final Function? onLongPress;
  final Function(VideoItem item)? onSelect;

  const HorizonListTile({
    super.key,
    required this.item,
    required this.selectMode,
    required this.onTab,
    this.onLongPress,
    this.onSelect,
  });

  @override
  State<StatefulWidget> createState() => _HorizonListTileState();
}

class _HorizonListTileState extends State<HorizonListTile> {
  void _handleCheckboxChange(bool? value) {
    if (value == null) return;

    setState(() {
      widget.item.checked = value;
      widget.onSelect?.call(widget.item);
    });
  }

  void _handleTap() {
    widget.onTab(widget.item);
  }

  void _handleLongPress() {
    widget.onLongPress?.call();
  }

  Widget _buildCheckbox() {
    return Checkbox(
      activeColor: Colors.blue,
      value: widget.item.checked,
      onChanged: _handleCheckboxChange,
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 130,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(
          image: NetworkImage(widget.item.cover),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          PBadge(
            text: Utils.timeFormat(widget.item.duration),
            right: 3.0,
            bottom: 5.0,
            type: 'gray',
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: widget.item.duration > 0
                  ? widget.item.seek / widget.item.duration
                  : 0,
              color: const Color.fromARGB(255, 185, 64, 104),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      widget.item.title,
      style: const TextStyle(fontSize: 16),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTagList() {
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        for (var tag in widget.item.tagList)
          Badge(
            label: Text(tag),
            backgroundColor: Colors.black54.withValues(alpha: 0.4),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          ),
      ],
    );
  }

  Widget _buildCreatedDate() {
    if (widget.item.created.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      widget.item.created,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAuthorRow() {
    return Row(
      children: [
        const Image(
          image: AssetImage('assets/images/up_gray.png'),
          width: 18,
          height: 18,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            widget.item.author,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (widget.item.source == 'rcmd' || widget.item.source == 'subject')
          SizedBox(
            width: 24,
            height: 24,
            child: _buildFavoritePopupMenu(),
          ),
        const SizedBox(width: 15),
      ],
    );
  }

  Widget _buildFavoritePopupMenu() {
    return PopupMenuButton(
      position: PopupMenuPosition.under,
      icon: const Icon(Icons.more_vert_outlined),
      tooltip: '收藏',
      padding: const EdgeInsets.all(0),
      menuPadding: const EdgeInsets.all(0),
      onSelected: (_) => FavoriteService.add(widget.item),
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
    );
  }

  Widget _buildContentColumn() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTitle(),
          _buildTagList(),
          _buildCreatedDate(),
          _buildAuthorRow(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap,
      onLongPress: _handleLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.selectMode) _buildCheckbox(),
            _buildThumbnail(),
            const SizedBox(width: 6),
            _buildContentColumn(),
          ],
        ),
      ),
    );
  }
}
