import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '/provider/playing.dart';

class HeaderView extends StatelessWidget {
  const HeaderView({super.key});

  @override
  Widget build(BuildContext context) {
    PlayingState playingState = context.watch<PlayingState>();
    if (playingState.detail == null) {
      return const SizedBox();
    }

    final detail = playingState.detail!;
    final fullUrl = 'https://www.bilibili.com/video/${detail.bvid}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.title,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              height: 1.25,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6.0),
          Row(
            children: [
              Icon(
                Icons.link,
                size: 12.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4.0),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: fullUrl));
                    SmartDialog.showToast(
                      '链接已复制',
                      displayTime: const Duration(milliseconds: 1500),
                    );
                  },
                  child: Text(
                    'bilibili.com/video/${detail.bvid}',
                    style: TextStyle(
                      fontSize: 11.0,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
