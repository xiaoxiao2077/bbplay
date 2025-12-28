import 'package:flutter/material.dart';

class BorderConfig {
  final Color color;
  final double width;

  BorderConfig({
    this.color = const Color(0xFF000000),
    this.width = 1.0,
  });
}

class MenuConfig {
  double itemWidth;
  double itemHeight;
  final double arrowHeight;
  final Color backgroundColor;
  final Color highlightColor;
  final Color lineColor;
  final BorderConfig? border;
  final BorderRadiusGeometry? borderRadius;

  MenuConfig({
    this.itemWidth = 120.0,
    this.itemHeight = 40.0,
    this.arrowHeight = 10.0,
    this.backgroundColor = Colors.white,
    this.highlightColor = const Color(0xff353535),
    this.lineColor = const Color(0x55000000),
    this.border,
    this.borderRadius,
  });
}
