import 'package:flutter/material.dart';
import 'dart:math';
import 'package:spiroble/widgets/CircularProgressBar-WV.dart';
import 'package:spiroble/widgets/CircularProgressBar.dart';

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                CustomCircularProgressBarWV(
                    progress: 0.3, // Progress value (0.0 to 1.0)
                    minValue: 0.2, // Minimum reference range
                    maxValue: 0.6, // Maximum reference range
                    text: "5.56 L"
                ),
                CustomCircularProgressBarWV(
                    progress: 0.2, // Progress value (0.0 to 1.0)
                    minValue: 0.8, // Minimum reference range
                    maxValue: 0.9, // Maximum reference range
                    text: "4.95 L"
                ),
                CustomCircularProgressBarWV(
                    progress: 0.3, // Progress value (0.0 to 1.0)
                    minValue: 0.1, // Minimum reference range
                    maxValue: 0.4, // Maximum reference range
                    text: "714 L/m"
                ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

