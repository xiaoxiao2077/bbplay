//region 2. HELPER WIDGETS & PAINTERS

import 'package:flutter/material.dart';

/// A [CustomPainter] that draws a vertical line to simulate a cursor.
class PinCodePainter extends CustomPainter {
  /// The color of the cursor.
  final Color cursorColor;

  /// The width of the cursor.
  final double cursorWidth;

  PinCodePainter({this.cursorColor = Colors.black, this.cursorWidth = 2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cursorColor
      ..strokeWidth = cursorWidth;
    canvas.drawLine(Offset.zero, Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter old) => false;
}

//endregion
