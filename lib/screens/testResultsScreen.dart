import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Monitor',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Roboto',
      ),
      home: HealthMonitorScreen(),
    );
  }
}

class HealthMonitorScreen extends StatefulWidget {
  @override
  _HealthMonitorScreenState createState() => _HealthMonitorScreenState();
}

class _HealthMonitorScreenState extends State<HealthMonitorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3A2A6B), // Üstteki koyu mor
              Color(0xFF2E235A), // Alttaki daha koyu ton
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40), // Üstten boşluk
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white),
                    Icon(Icons.upload_file, color: Colors.white),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  '11 Apr 2020 at 1:09 AM',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                SizedBox(height: 20),
                buildMeasurementRow(),
                SizedBox(height: 30),
                buildSymptomsSection(),
                SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: Text('Add Symptoms'),
                  ),
                ),
                SizedBox(height: 30),
                buildMonthlySummary(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMeasurementRow() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        buildMeasurementCard('FVC', '5.56', 0.8),
        buildMeasurementCard('FEV1', '4.95', 0.9),
        buildMeasurementCard('PEF', '714', 1.0),
        buildMeasurementCard('FEV6', '5.56', 0.9),
        buildMeasurementCard('FEV2575', '6.38', 0.85),
        buildMeasurementCard('FEV1/FVC', '89.03', 0.95),
      ],
    );
  }

  Widget buildMeasurementCard(String title, String value, double percent) {
    return Container(
      width: 100,
      child: Column(
        children: [
          CircularPercentIndicator(
            radius: 50.0,
            lineWidth: 5.0,
            animation: true,
            percent: percent,
            center: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            footer: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Colors.grey.shade800,
            progressColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSymptomRow('Wheezing', 0.5),
        SizedBox(height: 10),
        buildSymptomRow('Breathlessness', 0.3),
      ],
    );
  }

  Widget buildSymptomRow(String symptom, double severity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          symptom,
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(height: 5),
        LinearProgressIndicator(
          value: severity,
          backgroundColor: Colors.grey.shade800,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
        ),
      ],
    );
  }

  Widget buildMonthlySummary() {
    List<double> monthlyData = [
      0.2, 0.3, 0.8, 0.5, 0.6, 0.4, 0.7, 0.9, 0.3, 0.4, 0.7, 0.6
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MONTH SUMMARY',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        SizedBox(height: 10),
        Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: monthlyData.map((value) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 20,
                      height: 50 * value, // Dynamic height based on value
                      decoration: BoxDecoration(
                        color: value > 0.5 ? Colors.purple : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
