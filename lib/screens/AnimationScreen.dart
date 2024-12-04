import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'package:spiroble/bluetooth/bluetooth_constant.dart';

class AnimationScreen extends StatefulWidget {
  @override
  _AnimationScreenState createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen> {
  late BluetoothConnectionManager _bleManager;
  StreamSubscription<List<double>>? _dataSubscription;
  List<Measurement> measurements = [];
  bool isAnimating = false;

  // Respiratory Metrics
  double fvc = 0.0;
  double fev1 = 0.0;
  double pef = 0.0;
  double fev6 = 0.0;
  double fev2575 = 0.0;
  double fev1Fvc = 0.0;

  // Reference Start Time
  double? referenceStartTime;

  @override
  void initState() {
    super.initState();
    _bleManager =
        Provider.of<BluetoothConnectionManager>(context, listen: false);
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }

  void _startAnimation() async {
    if (_bleManager.connectedDeviceId != null) {
      await _bleManager.sendChar1(
        BleUuids.Uuid3Services,
        BleUuids.Uuid3Characteristic,
        _bleManager.connectedDeviceId!,
      );

      setState(() {
        isAnimating = true;
        // Reset measurements and reference start time when starting animation
        measurements.clear();
        referenceStartTime = null;
      });

      _dataSubscription = _bleManager
          .notifyAsDoubles(_bleManager.connectedDeviceId!)
          .listen((data) {
        // Ensure data has at least 3 elements: flowRate, volume, time
        if (data.length < 3) {
          print('Invalid data received: $data');
          return;
        }

        double flowRate = data[0];
        double volume = data[1];
        double time = data[2];

        // Initialize referenceStartTime with the first received time
        if (referenceStartTime == null) {
          referenceStartTime = time;
          print('Reference Start Time set to: $referenceStartTime ms');
        }

        // Calculate relative time
        double relativeTime = time - referenceStartTime!;

        // Avoid negative relative times
        if (relativeTime < 0) {
          relativeTime = 0;
        }

        // Create a new Measurement with relative time
        Measurement measurement = Measurement(
          flowRate: flowRate,
          volume: volume,
          time: relativeTime,
        );

        // Debug: Print received and relative data
        print(
            'Received Data - Flow Rate: $flowRate, Volume: $volume, Time: $relativeTime ms');

        setState(() {
          measurements.add(measurement);
          // Limit the number of measurements to prevent performance issues
          if (measurements.length > 10000) {
            measurements.removeAt(0);
          }
          _calculateMetrics();
        });
      }, onError: (error) {
        print('Error receiving data: $error');
      });
    } else {
      print('No device connected.');
    }
  }

  void _stopAnimation() {
    _dataSubscription?.cancel();
    _bleManager.stopScan();
    setState(() {
      isAnimating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bağlantı İptal Edildi')),
    );
  }

  void _calculateMetrics() {
    if (measurements.isEmpty) return;

    // Ensure there are measurements with time <= 1000 ms and <= 6000 ms
    Measurement? fev1Measurement = measurements.firstWhere(
      (m) => m.time <= 1000,
      orElse: () => Measurement(volume: 0.0, flowRate: 0.0, time: 0),
    );

    Measurement? fev6Measurement = measurements.firstWhere(
      (m) => m.time <= 6000,
      orElse: () => Measurement(volume: 0.0, flowRate: 0.0, time: 0),
    );

    // Measurements between 2500 ms and 7500 ms for fev2575
    List<Measurement> fev2575Measurements =
        measurements.where((m) => m.time >= 2500 && m.time <= 7500).toList();

    // Debug: Print the metrics calculation steps
    print('Calculating Metrics...');
    print('FVC: ${measurements.last.volume}');
    print('FEV1 Measurement: ${fev1Measurement.volume}');
    print('FEV6 Measurement: ${fev6Measurement.volume}');
    print('FEV2575 Measurements Count: ${fev2575Measurements.length}');

    fvc = measurements.last.volume;
    fev1 = fev1Measurement.volume;
    pef = measurements.map((m) => m.flowRate).reduce((a, b) => a > b ? a : b);
    fev6 = fev6Measurement.volume;
    fev2575 = fev2575Measurements.isNotEmpty
        ? fev2575Measurements.fold(0.0, (sum, m) => sum + m.volume) /
            fev2575Measurements.length
        : 0.0;
    fev1Fvc = fvc != 0.0 ? fev1 / fvc : 0.0;

    // Debug: Print calculated metrics
    print(
        'Calculated Metrics - FVC: $fvc, FEV1: $fev1, PEF: $pef, FEV6: $fev6, FEV2575: $fev2575, FEV1/FVC: $fev1Fvc');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Animation Screen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: isAnimating ? null : _startAnimation,
                  child: Text('Start Animation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Example background color
                    foregroundColor: Colors.white, // Example text color
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isAnimating ? _stopAnimation : null,
                  child: Text('Stop Animation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors
                        .redAccent, // Replaced 'primary' with 'backgroundColor'
                    foregroundColor: Colors.white, // Optional: Set text color
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isAnimating ? _buildAnimation() : _buildIdleState(),
          ),
          _buildMetrics(),
        ],
      ),
    );
  }

  Widget _buildIdleState() {
    return Center(
      child: Text(
        'Press "Start Animation" to begin.',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  Widget _buildAnimation() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SizedBox(
          width: double.infinity, // Make the graph take full width
          height: 300, // Increased height for better visibility
          child: CustomPaint(
            painter: FlowVolumePainter(measurements: measurements),
            child: Container(),
          ),
        ),
      ),
    );
  }

  Widget _buildMetrics() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          MetricCard(title: 'FVC', value: fvc.toStringAsFixed(2)),
          MetricCard(title: 'FEV1', value: fev1.toStringAsFixed(2)),
          MetricCard(title: 'PEF', value: pef.toStringAsFixed(2)),
          MetricCard(title: 'FEV6', value: fev6.toStringAsFixed(2)),
          MetricCard(title: 'FEV2575', value: fev2575.toStringAsFixed(2)),
          MetricCard(title: 'FEV1/FVC', value: fev1Fvc.toStringAsFixed(2)),
        ],
      ),
    );
  }
}

class Measurement {
  final double flowRate;
  final double volume;
  final double time;

  Measurement({
    required this.flowRate,
    required this.volume,
    required this.time,
  });
}

class FlowVolumePainter extends CustomPainter {
  final List<Measurement> measurements;
  FlowVolumePainter({required this.measurements});

  @override
  void paint(Canvas canvas, Size size) {
    if (measurements.isEmpty) return;

    double maxFlow =
        measurements.map((m) => m.flowRate).reduce((a, b) => a > b ? a : b);
    double maxVolume =
        measurements.map((m) => m.volume.abs()).reduce((a, b) => a > b ? a : b);
    double maxTime =
        measurements.map((m) => m.time).reduce((a, b) => a > b ? a : b);

    // Adjust scaling factors if necessary
    double flowScale = maxFlow != 0 ? size.height / maxFlow : 1;
    double volumeScale = maxVolume != 0 ? size.height / maxVolume : 1;

    Paint flowPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Paint volumePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    Path flowPath = Path();
    Path volumePath = Path();

    for (int i = 0; i < measurements.length; i++) {
      double x = (measurements[i].time / maxTime) * size.width;
      double yFlow = size.height -
          (measurements[i].flowRate * flowScale); // Adjusted for scaling
      double yVolume = size.height -
          (measurements[i].volume.abs() * volumeScale); // Adjusted for scaling

      if (i == 0) {
        flowPath.moveTo(x, yFlow);
        volumePath.moveTo(x, yVolume);
      } else {
        flowPath.lineTo(x, yFlow);
        volumePath.lineTo(x, yVolume);
      }
    }

    // Draw the flow and volume paths
    canvas.drawPath(flowPath, flowPaint);
    canvas.drawPath(volumePath, volumePaint);
  }

  @override
  bool shouldRepaint(covariant FlowVolumePainter oldDelegate) {
    return oldDelegate.measurements != measurements;
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;

  MetricCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey[50],
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
