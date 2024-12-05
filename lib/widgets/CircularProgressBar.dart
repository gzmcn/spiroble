import 'package:flutter/material.dart';

class CustomCircularProgressBar extends StatelessWidget {
  final double progress;
  final double minValue;
  final double maxValue;
  final String text; // Text to display in the center

  CustomCircularProgressBar({
    required this.progress,
    required this.minValue,
    required this.maxValue,
    required this.text, // Accept the text parameter
  });

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
      ..color = (progress >= minValue && progress <= maxValue)
          ? Colors.purple
          : Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    // Draw the background circle
    final double radius = (size.width / 2) - 8;
    final Offset center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw the progress arc
    final double startAngle = -90 * (3.14159 / 180); // Start at the top
    final double sweepAngle =
        progress * 360 * (3.14159 / 180); // Sweep proportionally
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
