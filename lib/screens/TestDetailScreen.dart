import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestDetailScreen(),
    );
  }
}
class TestDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Detail Screen'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomCircularProgressBar(
            progress: 0.3, // Progress value (0.0 to 1.0)
            minValue: 0.2, // Minimum reference range
            maxValue: 0.6, // Maximum reference range
          ),
        ),
      ),
    );
  }
}

class CustomCircularProgressBar extends StatelessWidget {
  final double progress; // Current progress value (0.0 to 1.0)
  final double minValue; // Minimum reference value
  final double maxValue; // Maximum reference value

  const CustomCircularProgressBar({
    Key? key,
    required this.progress,
    required this.minValue,
    required this.maxValue,
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
        ),
      ),
    );
  }
}

class CircularProgressBarPainter extends CustomPainter {
  final double progress;
  final double minValue;
  final double maxValue;

  CircularProgressBarPainter({
    required this.progress,
    required this.minValue,
    required this.maxValue,
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
    final Offset lineStart = Offset(
      center.dx + radius * cos(currentAngle),
      center.dy + radius * sin(currentAngle),
    );
    final Offset lineEnd = Offset(
      center.dx + (radius + 20) * cos(currentAngle), // Extend the line outward by 20
      center.dy + (radius + 20) * sin(currentAngle),
    );
    canvas.drawLine(lineStart, lineEnd, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}