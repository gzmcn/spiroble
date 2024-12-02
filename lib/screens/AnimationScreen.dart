import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spiroble/Bluetooth_Services/bluetooth_constant.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';

class AnimationScreen extends StatefulWidget {
  @override
  _AnimationScreenState createState() => _AnimationScreenState();
}

class _AnimationScreenState extends State<AnimationScreen>
    with SingleTickerProviderStateMixin {
  final BluetoothConnectionManager _bleManager = BluetoothConnectionManager();
  bool _isConnecting = false;
  bool _isConnected = false;

  // Measurement data
  List<Map<String, dynamic>> measurements = [
    {"flowRate": 1.03, "volume": -0.31, "time": 30713},
    {"flowRate": 1.03, "volume": -0.26, "time": 30764},
    {"flowRate": 1.03, "volume": -0.21, "time": 30815},
    {"flowRate": 0.82, "volume": -0.16, "time": 30866},
    {"flowRate": 0.82, "volume": -0.12, "time": 30917},
    {"flowRate": 0.82, "volume": -0.08, "time": 30968},
    {"flowRate": 0.62, "volume": -0.05, "time": 31019},
    {"flowRate": 0.62, "volume": -0.02, "time": 31070},
    {"flowRate": 0.41, "volume": 0.00, "time": 31121},
    {"flowRate": 0.62, "volume": 0.03, "time": 31172},
    {"flowRate": 0.41, "volume": 0.05, "time": 31223},
    {"flowRate": 0.41, "volume": 0.07, "time": 31274},
    {"flowRate": 0.41, "volume": 0.09, "time": 31325},
    // Add more data as needed
  ];

  double? FVC;
  double? FEV1;
  double? fev1FvcRatio;
  double? FEF2575;
  double? PEF;

  late AnimationController _controller;
  late Animation<double> _ballAnimation;
  int _timerCount = 5;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initializeAnimation();
    _calculateSpirometryMetrics();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);

    _ballAnimation = Tween<double>(begin: 0.3, end: -0.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerCount == 0) {
        _timer.cancel();
        _controller.stop();
        _connectToDevice();
      } else {
        setState(() {
          _timerCount--;
        });
      }
    });
  }

  void _connectToDevice() async {
    setState(() {
      _isConnecting = true;
    });

    bool connected = true;

    setState(() {
      _isConnecting = false;
      _isConnected = connected;
    });

    if (connected) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Spiromatike Bağlanıldı')),
          );
        });
      }
    } else {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bağlantı Başarısız')),
          );
        });
      }
    }
  }

  void _denyConnection() {
    _bleManager.stopScan();
    _timer.cancel();
    _controller.stop();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bağlantı İptal Edildi')),
        );
      });
    }
  }

  void _calculateSpirometryMetrics() {
    if (measurements.isEmpty) return;

    // Calculate FVC
    FVC = measurements.map((m) => m['volume'] as double).reduce((a, b) => a + b);

    // Calculate FEV1
    int fev1TimeLimit = 1000; // 1 second in ms
    double fev1Volume = measurements
        .where((m) => m['time'] <= fev1TimeLimit)
        .map((m) => m['volume'] as double)
        .fold(0.0, (a, b) => a + b);
    FEV1 = fev1Volume;

    // Calculate FEV1/FVC ratio
    fev1FvcRatio = (FEV1! / FVC!) * 100;

    // Calculate PEF
    PEF = measurements
            .map((m) => m['flowRate'] as double)
            .reduce((a, b) => a > b ? a : b) *
        60;

    // Calculate FEF25-75
    double fvc25 = 0.25 * FVC!;
    double fvc75 = 0.75 * FVC!;

    double? flow25;
    double? flow75;
    int? time25;
    int? time75;

    for (var m in measurements) {
      if (m['volume'] >= fvc25 && time25 == null) {
        flow25 = m['flowRate'] as double;
        time25 = m['time'] as int;
      }
      if (m['volume'] >= fvc75 && time75 == null) {
        flow75 = m['flowRate'] as double;
        time75 = m['time'] as int;
      }
      if (flow25 != null && flow75 != null) break;
    }

    if (flow25 != null && flow75 != null && time25 != null && time75 != null) {
      double timeDifference = (time75 - time25).toDouble();
      if (timeDifference != 0) {
        FEF2575 = (flow75 - flow25) / timeDifference;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[900],
      body: Column(
        children: [
          // Timer and title
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Timer
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
                  'Blow hard!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Ball animation
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Cylinder background
                Container(
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
                ),
                // Expiration text
                Positioned(
                  top: 40,
                  child: Text(
                    'EXPIRATION',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Inspiration text
                Positioned(
                  bottom: 40,
                  child: Text(
                    'INSPIRATION',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Animated ball
                AnimatedBuilder(
                  animation: _ballAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _ballAnimation.value * 200),
                      child: child,
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
          // Stop Trial button
          Expanded(
            flex: 1,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  _timer.cancel();
                  _controller.stop();
                  _denyConnection();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding:
                      EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Stop Trial',
                  style: TextStyle(
                    color: Colors.purple[900],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          // Spirometry Metrics Display
          if (_isConnected &&
              FVC != null &&
              FEV1 != null &&
              fev1FvcRatio != null &&
              FEF2575 != null &&
              PEF != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Spirometri Sonuçları",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  MetricCard(title: "FVC", value: "${FVC!.toStringAsFixed(2)} L"),
                  MetricCard(title: "FEV1", value: "${FEV1!.toStringAsFixed(2)} L"),
                  MetricCard(
                      title: "FEV1/FVC",
                      value: "${fev1FvcRatio!.toStringAsFixed(2)}%"),
                  MetricCard(
                      title: "FEF25-75",
                      value: "${FEF2575!.toStringAsFixed(2)} L/s"),
                  MetricCard(
                      title: "PEF", value: "${PEF!.toStringAsFixed(2)} L/min"),
                ],
              ),
            ),
          // Bottom Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Deny Button
                OutlinedButton(
                  onPressed: _isConnecting ? null : _denyConnection,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Text(
                      "Bağlanma",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                // Allow Button
                ElevatedButton(
                  onPressed:
                      _isConnecting || _isConnected ? null : _connectToDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Text(
                      "İzin Ver",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Bar
          Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    print("Test Butonuna Tıklandı");
                  },
                  icon: Icon(Icons.search,
                      color: Color.fromARGB(255, 182, 148, 0)),
                  iconSize: 32,
                ),
                IconButton(
                  onPressed: () {
                    print("Profil Butonuna Tıklandı");
                  },
                  icon: Icon(Icons.person,
                      color: Color.fromARGB(255, 182, 148, 0)),
                  iconSize: 32,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        trailing: Text(value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blueAccent,
            )),
      ),
    );
  }
}