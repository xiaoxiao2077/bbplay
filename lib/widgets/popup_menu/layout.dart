import 'package:flutter/material.dart';
import 'index.dart';
import 'config.dart';
import 'item.dart';

/// list menu layout
class MenuLayout {
  final MenuConfig config;
  final List<PopUpMenuItem> items;
  final VoidCallback onDismiss;
  final BuildContext context;
  final MenuClickCallback? onClickMenu;

  MenuLayout({
    required this.config,
    required this.items,
    required this.onDismiss,
    required this.context,
    this.onClickMenu,
  });

  Widget build() {
    return SizedBox(
      width: width,
      height: height,
      child: Column(
        children: <Widget>[
          ClipRRect(
              borderRadius: config.borderRadius ?? BorderRadius.zero,
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  color: config.backgroundColor,
                  border: config.border != null
                      ? Border.all(
                          color: config.border!.color,
                          width: config.border!.width,
                        )
                      : null,
                  borderRadius: config.borderRadius,
                ),
                child: Column(
                  children: items.map((item) {
                    return GestureDetector(
                      onTap: () {
                        onDismiss();
                        onClickMenu?.call(item);
                      },
                      behavior: HitTestBehavior.translucent,
                      child: SizedBox(
                        height: config.itemHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.only(left: 10),
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: item.textStyle,
                                textAlign: item.textAlign,
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),
        ],
      ),
    );
  }

  double get height =>
      config.itemHeight * items.length +
      (config.border != null ? config.border!.width * 2 : 0);

  double get width => config.itemWidth;
}
