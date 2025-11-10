import 'package:flutter/material.dart';
import 'dart:math' as math;

class GeometricPattern extends StatelessWidget {
  final double opacity;
  final Color lineColor;
  final Color secondaryLineColor;

  const GeometricPattern({
    super.key,
    this.opacity = 0.3,
    this.lineColor = Colors.white,
    this.secondaryLineColor = const Color(0xFF10B981),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GeometricPatternPainter(
        opacity: opacity,
        lineColor: lineColor,
        secondaryLineColor: secondaryLineColor,
      ),
      child: Container(),
    );
  }
}

class _GeometricPatternPainter extends CustomPainter {
  final double opacity;
  final Color lineColor;
  final Color secondaryLineColor;

  _GeometricPatternPainter({
    required this.opacity,
    required this.lineColor,
    required this.secondaryLineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Hexagonal/isometric cube pattern parameters
    final hexRadius = 35.0; // Distance from center to vertex of hexagon
    final hexHeight = hexRadius * math.sqrt(3); // Height of hexagon
    final hexWidth = hexRadius * 2; // Width of hexagon
    final depth = hexRadius * 0.8; // Depth of the 3D effect
    
    // Calculate how many hexagons we need to cover the area
    final cols = (size.width / (hexWidth * 1.5)).ceil() + 2;
    final rows = (size.height / (hexHeight * 0.5)).ceil() + 2;

    // Color for the pattern lines
    paint.color = lineColor.withOpacity(opacity);
    paint.strokeWidth = 1.5;

    // Draw the hexagonal/isometric cube pattern
    for (int row = -1; row < rows; row++) {
      for (int col = -1; col < cols; col++) {
        // Calculate center position of hexagon (offset pattern for hexagonal tiling)
        final offsetX = (row % 2 == 0) ? 0 : hexWidth * 0.75;
        final centerX = col * hexWidth * 1.5 + offsetX;
        final centerY = row * hexHeight * 0.5;

        // Draw hexagon (top face of cube) - rotated 30 degrees
        final hexPoints = <Offset>[];
        for (int i = 0; i < 6; i++) {
          final angle = (math.pi / 3) * i - math.pi / 6; // Rotate by 30 degrees
          hexPoints.add(Offset(
            centerX + hexRadius * math.cos(angle),
            centerY + hexRadius * math.sin(angle),
          ));
        }

        // Draw hexagon outline
        for (int i = 0; i < 6; i++) {
          canvas.drawLine(
            hexPoints[i],
            hexPoints[(i + 1) % 6],
            paint,
          );
        }

        // Draw three parallelograms (side faces of cube) extending from hexagon
        // Each parallelogram extends from alternating edges (3 visible faces)
        for (int i = 0; i < 3; i++) {
          final edgeIndex = i * 2; // Use every other edge: 0, 2, 4
          final startPoint = hexPoints[edgeIndex];
          final endPoint = hexPoints[(edgeIndex + 1) % 6];
          
          // Calculate the direction vector of the edge
          final dx = endPoint.dx - startPoint.dx;
          final dy = endPoint.dy - startPoint.dy;
          
          // Calculate perpendicular direction for depth (isometric projection)
          // The depth extends downward and outward
          final perpX = -dy * 0.5; // Perpendicular x component
          final perpY = dx * 0.5 + depth * 0.6; // Perpendicular y component with depth
          
          // Draw parallelogram (side face) - only 3 visible edges
          final p1 = startPoint;
          final p2 = endPoint;
          final p3 = Offset(endPoint.dx + perpX, endPoint.dy + perpY);
          final p4 = Offset(startPoint.dx + perpX, startPoint.dy + perpY);
          
          // Draw the three visible edges of the parallelogram
          canvas.drawLine(p1, p2, paint); // Top edge (shared with hexagon)
          canvas.drawLine(p2, p3, paint); // Right edge
          canvas.drawLine(p3, p4, paint); // Bottom edge
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

