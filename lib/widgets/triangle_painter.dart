import 'package:flutter/material.dart';

/// Low-poly geometric green background inspired by the reference image.
/// This painter creates a triangle shape with multiple facets for decorative purposes.
class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paints = [
      Paint()..color = const Color(0xFF18B34C), // bright green
      Paint()..color = const Color(0xFF16A65C),
      Paint()..color = const Color(0xFF0F8F63),
      Paint()..color = const Color(0xFF0E7A67),
      Paint()..color = const Color(0xFF0B5F5E),
      Paint()..color = const Color(0xFF083F44), // dark teal
    ];

    // Top-left large bright facet
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width * 0.35, 0)
        ..lineTo(size.width * 0.2, size.height * 0.45)
        ..lineTo(0, size.height * 0.35)
        ..close(),
      paints[0],
    );

    // Left middle triangle
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.35)
        ..lineTo(size.width * 0.2, size.height * 0.45)
        ..lineTo(size.width * 0.1, size.height)
        ..lineTo(0, size.height)
        ..close(),
      paints[1],
    );

    // Center top facet
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.35, 0)
        ..lineTo(size.width * 0.6, size.height * 0.15)
        ..lineTo(size.width * 0.2, size.height * 0.45)
        ..close(),
      paints[2],
    );

    // Center main polygon
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.2, size.height * 0.45)
        ..lineTo(size.width * 0.6, size.height * 0.15)
        ..lineTo(size.width * 0.75, size.height * 0.55)
        ..lineTo(size.width * 0.35, size.height * 0.7)
        ..close(),
      paints[3],
    );

    // Right middle diagonal
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.6, size.height * 0.15)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height * 0.45)
        ..lineTo(size.width * 0.75, size.height * 0.55)
        ..close(),
      paints[4],
    );

    // Bottom right dark facet
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.35, size.height * 0.7)
        ..lineTo(size.width * 0.75, size.height * 0.55)
        ..lineTo(size.width, size.height)
        ..lineTo(size.width * 0.15, size.height)
        ..close(),
      paints[5],
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
