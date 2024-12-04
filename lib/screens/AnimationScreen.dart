import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spiroble/bluetooth/bluetooth_constant.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';

class AnimationScreen extends StatefulWidget {
  @override
  _AnimationScreenState createState() => _AnimationScreenState();
}

class Measurement 
{
  final double flowRate;
  final double volume;
  final double time;

  Measurement({
    required this.flowRate,
    required this.volume,
    required this.time,
  });
}

class _AnimationScreenState extends State<AnimationScreen>
    with SingleTickerProviderStateMixin {
    late BluetoothConnectionManager _bleManager;
    StreamSubscription<List<double>>? _dataSubscription;

    DiscoveredDevice? deviceToConnect;

    // Measurement data
    List<Measurement> measurements = [];
    bool isAnimating = false;

    double fvc = 0.0;
    double fev1 = 0.0;
    double pef = 0.0;
    double fev6 = 0.0;
    double fev2575 = 0.0;
    double fev1Fvc = 0.0;

    late AnimationController _controller;
    late Animation<double> _ballAnimation;
    int _timerCount = 10;
    late Timer _timer;

    @override
    void initState() {
      super.initState();
      _bleManager =
          Provider.of<BluetoothConnectionManager>(context, listen: false);
      
      _controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 500),
        lowerBound: 0.0,
        upperBound: 1.0
      );

      _ballAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
    }

    @override
    void dispose() {
      _dataSubscription?.cancel();
      _controller.dispose(); // Dispose AnimationController if initialized
      _timer.cancel(); // Cancel Timer if initialized
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

        _dataSubscription =
            _bleManager.notifyAsDoubles(_bleManager.connectedDeviceId!).listen(
          (data) {
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
          },
          onError: (error) {
            print('Error receiving data $error');
          },
        );
      } else {
        print('No device connected');
      }
  }

  void _stopAnimation()
  {
    _dataSubscription?.cancel();
    _bleManager.stopScan();

    setState((){
      isAnimating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bağlantı iptal edildi')),
    );
  }

  void _startTimer() {

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerCount == 0) {
        _timer.cancel();
        _controller.stop();
        _bleManager.connectToDevice(deviceToConnect!.id);
      } else {
        setState(() {
          _timerCount--;
        });
      }
    });
  }

  void _calculateMetrics() {
    if (measurements.isEmpty) return;

    // Extract flow rates, volumes, and times from measurements
    List<double> akisHizi = measurements.map((m) => m.flowRate).toList();
    List<double> toplamVolum = measurements.map((m) => m.volume).toList();
    List<double> miliSaniye = measurements.map((m) => m.time).toList();

    // Calculate FVC
    fvc = _hesaplaFVC(toplamVolum);

    // Calculate FEV1
    fev1 = _hesaplaFEV1(akisHizi, miliSaniye);

    // Calculate PEF
    pef = _hesaplaPEF(akisHizi);

    // Calculate FEV6
    fev6 = _hesaplaFEV6(akisHizi, miliSaniye);

    // Calculate FEF25-75
    fev2575 = _hesaplaFEF2575(akisHizi, toplamVolum);

    // Calculate FEV1/FVC ratio
    fev1Fvc = fvc != 0.0 ? (fev1 / fvc) * 100 : 0.0;

    double fvcPercentage = (fvc / 20.0).clamp(0.0, 1.0);
    _controller.animateTo(
      fvcPercentage,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // Debug: Print calculated metrics
    print('Calculating Metrics...');
    print('FVC: $fvc');
    print('FEV1: $fev1');
    print('PEF: $pef');
    print('FEV6: $fev6');
    print('FEF25-75: $fev2575');
    print('FEV1/FVC: $fev1Fvc%');
  }

  /// Calculates Forced Vital Capacity (FVC)
  double _hesaplaFVC(List<double> toplamVolum) {
      if (toplamVolum.isEmpty) return 0.0;
      double maxVolume = toplamVolum.reduce(max);
      double minVolume = toplamVolum.reduce(min);
      return maxVolume - minVolume;
    }

  /// Calculates Forced Expiratory Volume in 1 Second (FEV1)
  double _hesaplaFEV1(List<double> akisHizi, List<double> zaman) {
    if (akisHizi.isEmpty || zaman.isEmpty || akisHizi.length != zaman.length) return 0.0;
    
    double startTime = zaman.first;
    double endTime = startTime + 1000.0; // 1 second in milliseconds
    double totalVolume = 0.0;

    for (int i = 0; i < akisHizi.length - 1; i++) {
      double currentTime = zaman[i];
      double nextTime = zaman[i + 1];
      
      if (currentTime >= endTime) break;
      
      double deltaTime = (nextTime - currentTime) / 1000.0; // Convert ms to seconds
      
      if (nextTime > endTime) {
        deltaTime = (endTime - currentTime) / 1000.0;
      }
      
      totalVolume += akisHizi[i] * deltaTime;
    }
    
    return totalVolume;
  }

  /// Calculates Forced Expiratory Volume in 6 Seconds (FEV6)
  double _hesaplaFEV6(List<double> akisHizi, List<double> zaman) {
    if (akisHizi.isEmpty || zaman.isEmpty || akisHizi.length != zaman.length) return 0.0;
    
    double startTime = zaman.first;
    double endTime = startTime + 6000.0; // 6 seconds in milliseconds
    double totalVolume = 0.0;

    for (int i = 0; i < akisHizi.length - 1; i++) {
      double currentTime = zaman[i];
      double nextTime = zaman[i + 1];
      
      if (currentTime >= endTime) break;
      
      double deltaTime = (nextTime - currentTime) / 1000.0; // Convert ms to seconds
      
      if (nextTime > endTime) {
        deltaTime = (endTime - currentTime) / 1000.0;
      }
      
      totalVolume += akisHizi[i] * deltaTime;
    }
    
    return totalVolume;
  }

  /// Calculates Peak Expiratory Flow (PEF)
  double _hesaplaPEF(List<double> akisHizi) {
    return akisHizi.isNotEmpty
        ? akisHizi.reduce((value, element) => value > element ? value : element)
        : 0.0;
  }

  /// Calculates Forced Expiratory Flow at 25–75% (FEF25-75)
  double _hesaplaFEF2575(List<double> akisHizi, List<double> toplamVolum) {
    double fvc = _hesaplaFVC(toplamVolum);
    if (fvc == 0.0) return 0.0;

    double fef25 = 0.0;
    double fef75 = 0.0;
    double volume25 = fvc * 0.25;
    double volume75 = fvc * 0.75;

    for (int i = 0; i < toplamVolum.length; i++) {
      if (toplamVolum[i] >= volume25 && fef25 == 0.0) {
        fef25 = akisHizi[i];
      }
      if (toplamVolum[i] >= volume75 && fef75 == 0.0) {
        fef75 = akisHizi[i];
        break;
      }
    }

    if (fef25 == 0.0 || fef75 == 0.0) return 0.0;

    return (fef25 + fef75) / 2;
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.purple[900],
    body: Column(
      children: [
        // Timer and Title
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Timer Display
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 3),
                ),
                padding: EdgeInsets.all(15),
                child: Text(
                  '$_timerCount\nSEC',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Title
              Text(
                'Blow Hard!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Animated Ball within Tube
        Expanded(
          flex: 3,
          child: Center(
            child: Container(
              width: 80,
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[700]!, Colors.purple[900]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Animated Ball
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Positioned(
                        bottom: _controller.value * 250, // Adjust multiplier as needed
                        child: child!,
                      );
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent,
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Control Buttons
        Expanded(
          flex: 1,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isAnimating ? null : _startAnimation,
                  child: Text('Animasyonu Başlat'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: isAnimating ? _stopAnimation : null,
                  child: Text('Animasyonu Durdur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Additional Widgets (e.g., Metrics Display) can be added here
      ],
    ),
  );
}
}