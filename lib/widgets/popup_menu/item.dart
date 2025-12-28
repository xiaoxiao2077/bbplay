import 'package:flutter/material.dart';

class PopUpMenuItem {
  String title;
  dynamic value;
  TextStyle textStyle;
  TextAlign textAlign;

  PopUpMenuItem({
    required this.title,
    required this.value,
    this.textStyle = const TextStyle(color: Colors.white, fontSize: 12.0),
    this.textAlign = TextAlign.center,
  });
}

class MenuItemWidget extends StatefulWidget {
  final PopUpMenuItem item;
  final bool showLine;
  final Color lineColor;
  final double itemWidth;
  final double itemHeight;

  final Function(PopUpMenuItem item)? clickCallback;

  const MenuItemWidget({
    super.key,
    this.itemWidth = 72.0,
    this.itemHeight = 65.0,
    required this.item,
    this.showLine = false,
    this.clickCallback,
    required this.lineColor,
  });

  @override
  State<StatefulWidget> createState() {
    return _MenuItemWidgetState();
  }
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  var color = const Color(0xff232323);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.clickCallback != null) {
          widget.clickCallback!(widget.item);
        }
      },
      child: Container(
        width: widget.itemWidth,
        height: widget.itemHeight,
        decoration: BoxDecoration(
          color: color,
          border: Border(
            right: BorderSide(
              color: widget.showLine ? widget.lineColor : Colors.transparent,
            ),
          ),
        ),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Text(
              widget.item.title,
              style: widget.item.textStyle,
              textAlign: widget.item.textAlign,
            ),
          ),
        ),
      ),
    );
  }
}
