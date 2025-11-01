import 'package:flutter/material.dart';

class FinancialLogo extends StatelessWidget {
  final double size;
  final Color color;

  const FinancialLogo({
    super.key,
    this.size = 80,
    this.color = const Color(0xFF0D9488),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FinancialGraphPainter(color: color),
    );
  }
}

class _FinancialGraphPainter extends CustomPainter {
  final Color color;

  _FinancialGraphPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw three vertical bars
    final barWidth = size.width * 0.1;
    final spacing = size.width * 0.15;
    final startX = (size.width - (barWidth * 3 + spacing * 2)) / 2;

    // Bar 1 (shortest)
    canvas.drawRect(
      Rect.fromLTWH(startX, size.height * 0.6, barWidth, size.height * 0.3),
      paint,
    );

    // Bar 2 (medium)
    canvas.drawRect(
      Rect.fromLTWH(
          startX + barWidth + spacing, size.height * 0.45, barWidth, size.height * 0.45),
      paint,
    );

    // Bar 3 (tallest)
    canvas.drawRect(
      Rect.fromLTWH(
          startX + (barWidth + spacing) * 2, size.height * 0.3, barWidth, size.height * 0.6),
      paint,
    );

    // Draw upward trending line
    final path = Path();
    path.moveTo(startX + barWidth / 2, size.height * 0.65);
    path.lineTo(startX + barWidth + spacing + barWidth / 2, size.height * 0.5);
    path.lineTo(startX + (barWidth + spacing) * 2 + barWidth / 2, size.height * 0.35);

    // Arrow pointing up-right
    final arrowX = startX + (barWidth + spacing) * 2 + barWidth / 2;
    final arrowY = size.height * 0.35;
    final arrowSize = size.width * 0.1;
    
    path.lineTo(arrowX + arrowSize * 0.7, arrowY - arrowSize * 0.7);
    path.moveTo(arrowX, arrowY);
    path.lineTo(arrowX + arrowSize * 0.7, arrowY - arrowSize * 0.7);
    path.lineTo(arrowX + arrowSize * 0.3, arrowY - arrowSize * 0.3);

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

