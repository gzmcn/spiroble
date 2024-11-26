import 'package:flutter/material.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepOrange, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row with icons and centered text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.share, color: Colors.white, size: 24), // Left icon
                  Text(
                    "SONUÇLAR",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Icon(Icons.close, color: Colors.white, size: 24), // Right icon
                ],
              ),
            ),

            // Rest of the content
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First row of progress bars and text
                      StreamBuilder<Object>(
                        stream: null,
                        builder: (context, snapshot) {
                          return Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CustomCircularProgressBarWV(
                                  progress: 0.3, // Progress value (0.0 to 1.0)
                                  minValue: 0.2, // Minimum reference range
                                  maxValue: 0.6, // Maximum reference range
                                  text: "5.56 L",
                                ),
                                CustomCircularProgressBarWV(
                                  progress: 0.2, // Progress value (0.0 to 1.0)
                                  minValue: 0.8, // Minimum reference range
                                  maxValue: 0.9, // Maximum reference range
                                  text: "4.95 L",
                                ),
                                CustomCircularProgressBarWV(
                                  progress: 0.3, // Progress value (0.0 to 1.0)
                                  minValue: 0.1, // Minimum reference range
                                  maxValue: 0.4, // Maximum reference range
                                  text: "714 L/m",
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "FVC",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "FEV1",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "PEF",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Second row of progress bars and text
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        child: StreamBuilder<Object>(
                          stream: null,
                          builder: (context, snapshot) {
                            return Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  CustomCircularProgressBarWV(
                                    progress: 0.4,
                                    minValue: 0.3,
                                    maxValue: 0.7,
                                    text: "6.25 L",
                                  ),
                                  CustomCircularProgressBarWV(
                                    progress: 0.1,
                                    minValue: 0.4,
                                    maxValue: 0.5,
                                    text: "3.75 L",
                                  ),
                                  CustomCircularProgressBarWV(
                                    progress: 0.5,
                                    minValue: 0.5,
                                    maxValue: 0.8,
                                    text: "800 L/m",
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  "FEV6",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "FEF2575",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  "FEV1%",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

      // Bottom white container
      Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // SEMPTOMLAR title
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "SEMPTOMLAR",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            // Nefes Darlığı row with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Nefes Darlıgı",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(width: 40), // Space between text and icon
                Icon(
                  Icons.air, // Replace with the icon you want
                  color: Colors.grey.shade800,
                  size: 30,
                ),
              ],
            ),
          ],
        ),
      ),

        ]
      ),
      ),
    );
  }
}
