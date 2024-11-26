import 'package:flutter/material.dart';
import 'dart:math';

class CustomCircularProgressBarWV extends StatelessWidget {
  final double progress; // Current progress value (0.0 to 1.0)
  final double minValue; // Minimum reference value
  final double maxValue; // Maximum reference value
  final String text;

  const CustomCircularProgressBarWV({
    Key? key,
    required this.progress,
    required this.minValue,
    required this.maxValue,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100, // Width of the progress bar
      height: 100, // Height of the progress bar
      child: CustomPaint(
        painter: CircularProgressBarPainter(
          progress: progress,
          minValue: minValue,
          maxValue: maxValue,
          text: text,
        ),
      ),
    );
  }
}

class CircularProgressBarPainter extends CustomPainter {
  final double progress;
  final double minValue;
  final double maxValue;
  final String text;

  CircularProgressBarPainter({
    required this.progress,
    required this.minValue,
    required this.maxValue,
    required this.text,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    final Paint progressPaint = Paint()
      ..color = (progress >= minValue && progress <= maxValue) ? Colors.green : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final Paint indicatorPaint = Paint()
      ..color = Colors.red // Color for the current value line
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;


    // Draw the background circle
    final double radius = (size.width / 2) - 8;
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw the progress arc
    final double startAngle = -90 * (3.14159 / 180); // Start at the top
    final double sweepAngle = progress * 360 * (3.14159 / 180); // Sweep proportionally
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Draw the current value line (longer version)
    final double currentAngle = startAngle + sweepAngle; // Angle for current progress
    final double innerRadius = radius - 5.55;
    final Offset lineStart = Offset(
      center.dx + innerRadius * cos(currentAngle),
      center.dy + innerRadius* sin(currentAngle),
    );
    final Offset lineEnd = Offset(
      center.dx + (innerRadius + 10) * cos(currentAngle), // Extend the line outward by 20
      center.dy + (innerRadius + 10) * sin(currentAngle),
    );
    canvas.drawLine(lineStart, lineEnd, indicatorPaint);



    // Add text in the center of the progress bar
    final TextSpan textSpan = TextSpan(
      text: text, // Use the passed text
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(minWidth: 0, maxWidth: size.width);

    // Position the text in the center of the circle
    final Offset textOffset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    // Draw the text
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}