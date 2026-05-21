import 'dart:math';
import 'package:flutter/material.dart';

class LiquidJarPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0
  final Color color;
  final double waveAnimation; // 0.0 to 1.0 (for wave movement)

  LiquidJarPainter({
    required this.progress,
    required this.color,
    required this.waveAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillHeight = size.height * (1 - progress);

    // Wave calculation
    path.moveTo(-10, fillHeight); // Start slightly outside horizontally
    
    // Create a smooth wave effect
    for (double x = -10; x <= size.width + 10; x++) {
      final y = fillHeight + 
               sin((x / size.width * 2.5 * pi) + (waveAnimation * 2 * pi)) * 3.5;
      path.lineTo(x, y);
    }

    // Close the path to the bottom edges
    // We go well outside the visible area to ensure full coverage after clipping
    path.lineTo(size.width + 50, size.height + 50); 
    path.lineTo(-50, size.height + 50);
    path.close();

    // Clip the path to a rounded jar shape
    final jarRect = RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(size.width * 0.25));
    canvas.save(); // Save state before clipping
    canvas.clipRRect(jarRect);
    
    canvas.drawPath(path, paint);

    // Second wave layer for depth
    final secondPaint = Paint()
      ..color = color.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    final secondPath = Path();
    secondPath.moveTo(-10, fillHeight);
    for (double x = -10; x <= size.width + 10; x++) {
      final y = fillHeight + 
               cos((x / size.width * 2.0 * pi) + (waveAnimation * 2 * pi)) * 2.5;
      secondPath.lineTo(x, y);
    }

    // Close second path
    secondPath.lineTo(size.width + 50, size.height + 50);
    secondPath.lineTo(-50, size.height + 50);
    secondPath.close();

    canvas.drawPath(secondPath, secondPaint);
    canvas.restore(); // Restore state after drawing

  }

  @override
  bool shouldRepaint(covariant LiquidJarPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.waveAnimation != waveAnimation;
  }
}
