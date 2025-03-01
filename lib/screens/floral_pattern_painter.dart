import 'package:flutter/material.dart';

class FloralPatternPainter extends CustomPainter {
  final int patternIndex; // which pattern to draw

  FloralPatternPainter(this.patternIndex);

  @override
  void paint(Canvas canvas, Size size) {
    // Subtle color
    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // We'll draw different small shapes depending on patternIndex
    switch (patternIndex % 6) {
      case 0:
        _drawCircles(canvas, size, paint);
        break;
      case 1:
        _drawLeaves(canvas, size, paint);
        break;
      case 2:
        _drawPetals(canvas, size, paint);
        break;
      case 3:
        _drawWaves(canvas, size, paint);
        break;
      case 4:
        _drawSpirals(canvas, size, paint);
        break;
      case 5:
        _drawDots(canvas, size, paint);
        break;
    }
  }

  void _drawCircles(Canvas canvas, Size size, Paint paint) {
    // Repeating circles
    for (double y = 0; y < size.height; y += 20) {
      for (double x = 0; x < size.width; x += 20) {
        canvas.drawCircle(Offset(x, y), 6, paint);
      }
    }
  }

  void _drawLeaves(Canvas canvas, Size size, Paint paint) {
    // Repeating leaf shape
    for (double y = 0; y < size.height; y += 30) {
      for (double x = 0; x < size.width; x += 30) {
        Path leaf = Path();
        leaf.moveTo(x, y);
        leaf.quadraticBezierTo(x + 10, y + 10, x, y + 20);
        leaf.quadraticBezierTo(x - 10, y + 10, x, y);
        canvas.drawPath(leaf, paint);
      }
    }
  }

  void _drawPetals(Canvas canvas, Size size, Paint paint) {
    // Simple 4-petal shape repeated
    for (double y = 15; y < size.height; y += 40) {
      for (double x = 15; x < size.width; x += 40) {
        _drawFourPetals(canvas, x, y, paint);
      }
    }
  }

  void _drawFourPetals(Canvas canvas, double cx, double cy, Paint paint) {
    final radius = 8.0;
    // top petal
    canvas.drawCircle(Offset(cx, cy - radius), radius, paint);
    // right petal
    canvas.drawCircle(Offset(cx + radius, cy), radius, paint);
    // bottom
    canvas.drawCircle(Offset(cx, cy + radius), radius, paint);
    // left
    canvas.drawCircle(Offset(cx - radius, cy), radius, paint);
  }

  void _drawWaves(Canvas canvas, Size size, Paint paint) {
    // Horizontal wave lines
    for (double y = 0; y < size.height; y += 20) {
      Path path = Path()..moveTo(0, y);
      for (double x = 0; x < size.width; x += 20) {
        path.quadraticBezierTo(
          x + 10,
          y + 10,
          x + 20,
          y,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawSpirals(Canvas canvas, Size size, Paint paint) {
    // Some spiral arcs
    for (double y = 20; y < size.height; y += 40) {
      for (double x = 20; x < size.width; x += 40) {
        Rect rect = Rect.fromCircle(center: Offset(x, y), radius: 15);
        canvas.drawArc(rect, 0, 3.14, false, paint);
      }
    }
  }

  void _drawDots(Canvas canvas, Size size, Paint paint) {
    // Tiny repeated dots
    for (double y = 0; y < size.height; y += 10) {
      for (double x = 0; x < size.width; x += 10) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(FloralPatternPainter oldDelegate) {
    return oldDelegate.patternIndex != patternIndex;
  }
}
