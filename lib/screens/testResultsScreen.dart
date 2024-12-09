import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class HealthMonitorScreen extends StatelessWidget {
  final Map<String, dynamic> measurement;

  HealthMonitorScreen({
    required this.measurement,
  });

  String _formatDate(DateTime timestamp) {
    return DateFormat('yyyy-MM-dd').format(timestamp); // Format to 'yyyy-MM-dd'
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sonuçlarım'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.white,
      ),

      body: Container(

        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor, // Üstteki koyu mor
              Theme.of(context).scaffoldBackgroundColor, // Alttaki daha koyu ton
            ],
          ),
        ),

        child: SingleChildScrollView(

          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                    _formatDate(measurement['timestamp']),
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    SizedBox(height: 20),

                    buildMeasurementRow(measurement),
                    SizedBox(height: 30),
                    buildSymptomsSection(),
                    SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding:
                              EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        child: Text('Add Symptoms'),
                      ),
                    ),
                    SizedBox(height: 30),
                    buildMonthlySummary(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildMeasurementRow(Map<String, dynamic> measurement) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
          children: [
            buildMeasurementCard('FVC', (double.tryParse(measurement['fvc'].toString())?.toStringAsFixed(3) ?? '0.000'), 0.7),
            buildMeasurementCard('FEV1', (double.tryParse(measurement['fev1'].toString())?.toStringAsFixed(3) ?? '0.000'), 0.9),
            buildMeasurementCard('PEF', (double.tryParse(measurement['pef'].toString())?.toStringAsFixed(3) ?? '0.000'), 1.0),
            buildMeasurementCard('FEV6', (double.tryParse(measurement['fev6'].toString())?.toStringAsFixed(3) ?? '0.000'), 0.9),

          buildMeasurementCard(
              'FEV2575', (double.tryParse(['fef2575'].toString())?.toStringAsFixed(3) ?? '0.000'), 0.85),
            buildMeasurementCard(
                'FEV1/FVC',
                measurement['fev1Fvc'].toStringAsFixed(3), // Assuming it's a numeric value
                0.95
            ),
        ],
      ),
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
              style:
                  TextStyle(fontSize: 18, fontWeight:  FontWeight.bold, color: Colors.white),
            ),
            footer: Text(
              title,
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            backgroundColor: Colors.grey.shade800,
            progressColor: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSymptomRow('Hırıltı', 0.5),
        SizedBox(height: 10),
        buildSymptomRow('Nefes Darlığı', 0.3),
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
      0.2,
      0.3,
      0.8,
      0.5,
      0.6,
      0.4,
      0.7,
      0.9,
      0.3,
      0.4,
      0.7,
      0.6
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
