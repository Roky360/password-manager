import 'package:flutter/material.dart';

class StripedContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final double lineWidth;
  final double spacing;
  final Color lineColor;
  final Color bgColor;

  // container properties
  final Widget? child;
  final EdgeInsets? padding;
  final Alignment? alignment;

  const StripedContainer({
    super.key,
    this.width,
    this.height,
    this.lineWidth = 4.0,
    this.spacing = 3.0,
    this.lineColor = Colors.yellow,
    this.bgColor = Colors.black,
    // child
    this.child,
    this.padding,
    this.alignment,
  }) : assert(spacing >= 0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: width,
          height: height,
          color: bgColor,
        ),
        ClipRect(
          child: CustomPaint(
            painter: _StripedPainter(
              lineWidth: lineWidth,
              lineSpacing: spacing,
              color: lineColor,
            ),
            child: Container(
              width: width,
              height: height,
              padding: padding,
              alignment: alignment,
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _StripedPainter extends CustomPainter {
  final double lineWidth;
  final double lineSpacing;
  final Color color;

  _StripedPainter({
    required this.lineWidth,
    required this.color,
    this.lineSpacing = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth;

    final spacing = lineWidth * lineSpacing;
    final numOfStripes = ((size.width + size.height) / spacing).ceil();

    for (int i = 0; i < numOfStripes; i++) {
      final double startX = i * spacing;
      final double startY = -lineWidth;

      final double endX = -lineWidth;
      final double endY = i * spacing;
      // final startX = -(size.height - spacing * i);
      // final endX = startX + size.height;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
