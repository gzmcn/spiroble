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
      });

      _dataSubscription = _bleManager
          .notifyAsDoubles(_bleManager.connectedDeviceId!)
          .listen((data) {
        // Debug: Print received data
        print(
            'Received Data - Flow Rate: ${data[0]}, Volume: ${data[1]}, Time: ${data[2]}');

        setState(() {
          measurements.add(Measurement(
            flowRate: data[0],
            volume: data[1],
            time: data[2],
          ));
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

    // Calculate FVC as the last volume measurement
    fvc = measurements.last.volume;

    // Calculate FEV1 using linear interpolation at 1000 ms
    fev1 = _interpolateVolume(1000);

    // Calculate FEV6 using linear interpolation at 6000 ms
    fev6 = _interpolateVolume(6000);

    // Calculate PEF as the maximum flow rate
    pef = measurements.map((m) => m.flowRate).reduce((a, b) => a > b ? a : b);

    // Calculate FEF25-75
    double fef25 = 0.25 * fvc;
    double fef75 = 0.75 * fvc;

    double t25 = _interpolateTimeForVolume(fef25);
    double t75 = _interpolateTimeForVolume(fef75);

    // Get flow rates at t25 and t75
    double flowAt25 = _interpolateFlowRate(t25);
    double flowAt75 = _interpolateFlowRate(t75);

    // Calculate FEF25-75 as the average of flow rates at 25% and 75% FVC
    fev2575 = (flowAt25 + flowAt75) / 2;

    // Calculate FEV1/FVC ratio
    fev1Fvc = fvc != 0.0 ? (fev1 / fvc) * 100 : 0.0;

    // Debug: Print calculated metrics
    print('Calculating Metrics...');
    print('FVC: $fvc');
    print('FEV1: $fev1');
    print('FEV6: $fev6');
    print('PEF: $pef');
    print('FEF25-75: $fev2575');
    print('FEV1/FVC: $fev1Fvc%');
  }

  /// Helper method to interpolate volume at a specific time
  double _interpolateVolume(double targetTime) {
    for (int i = 0; i < measurements.length - 1; i++) {
      Measurement current = measurements[i];
      Measurement next = measurements[i + 1];

      if (current.time <= targetTime && next.time >= targetTime) {
        double timeDiff = next.time - current.time;
        if (timeDiff == 0) return current.volume;
        double volumeDiff = next.volume - current.volume;
        double fraction = (targetTime - current.time) / timeDiff;
        return current.volume + (volumeDiff * fraction);
      }
    }
    // If targetTime is beyond the measurements, return the last volume
    return measurements.last.volume;
  }

  /// Helper method to interpolate time for a specific volume
  double _interpolateTimeForVolume(double targetVolume) {
    for (int i = 0; i < measurements.length - 1; i++) {
      Measurement current = measurements[i];
      Measurement next = measurements[i + 1];

      if (current.volume <= targetVolume && next.volume >= targetVolume) {
        double volumeDiff = next.volume - current.volume;
        if (volumeDiff == 0) return current.time;
        double fraction = (targetVolume - current.volume) / volumeDiff;
        return current.time + ((next.time - current.time) * fraction);
      }
    }
    // If targetVolume is beyond the measurements, return the last time
    return measurements.last.time;
  }

  /// Helper method to interpolate flow rate at a specific time
  double _interpolateFlowRate(double targetTime) {
    for (int i = 0; i < measurements.length - 1; i++) {
      Measurement current = measurements[i];
      Measurement next = measurements[i + 1];

      if (current.time <= targetTime && next.time >= targetTime) {
        double timeDiff = next.time - current.time;
        if (timeDiff == 0) return current.flowRate;
        double flowDiff = next.flowRate - current.flowRate;
        double fraction = (targetTime - current.time) / timeDiff;
        return current.flowRate + (flowDiff * fraction);
      }
    }
    // If targetTime is beyond the measurements, return the last flow rate
    return measurements.last.flowRate;
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
          height: 300, // Increase the height for better visibility
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
