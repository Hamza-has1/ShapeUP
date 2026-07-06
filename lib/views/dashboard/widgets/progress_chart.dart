import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ProgressChart extends StatelessWidget {
  final List<double> dataPoints;
  final List<String> labels;

  const ProgressChart({
    super.key,
    required this.dataPoints,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 8, right: 16),
      child: CustomPaint(
        painter: _ChartPainter(
          dataPoints: dataPoints,
          labels: labels,
          lineColor: AppColors.primaryPurple,
          fillColor: AppColors.primaryPurple.withOpacity(0.08),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final List<String> labels;
  final Color lineColor;
  final Color fillColor;

  _ChartPainter({
    required this.dataPoints,
    required this.labels,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paintLine = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final paintFill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final paintGrid = Paint()
      ..color = lineColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double widthBetweenPoints = size.width / (dataPoints.length - 1);
    final double maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    final double minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    final double range = maxVal - minVal == 0 ? 10 : maxVal - minVal;

    final List<Offset> points = [];

    // Draw horizontal grid lines
    const int gridLinesCount = 3;
    for (int i = 0; i <= gridLinesCount; i++) {
      final double y = size.height * (i / gridLinesCount);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    // Calculate points
    for (int i = 0; i < dataPoints.length; i++) {
      final double x = i * widthBetweenPoints;
      final double normalizedY = (dataPoints[i] - minVal) / range;
      // Invert Y axis for screen space
      final double y = size.height - (normalizedY * size.height * 0.7) - 10;
      points.add(Offset(x, y));
    }

    // Draw fill area
    final fillPath = Path();
    fillPath.moveTo(0, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, paintFill);

    // Draw lines between points
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, paintLine);

    // Draw dots and text labels
    for (int i = 0; i < points.length; i++) {
      // Draw point dot
      canvas.drawCircle(points[i], 5.0, Paint()..color = lineColor);
      canvas.drawCircle(points[i], 3.0, Paint()..color = Colors.white);

      // Label below chart
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(points[i].dx - (textPainter.width / 2), size.height + 4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
