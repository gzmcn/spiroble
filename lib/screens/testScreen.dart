import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'dart:typed_data';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'AnimationScreen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreen();
}

class _TestScreen extends State<TestScreen>
    with SingleTickerProviderStateMixin {
  final BluetoothConnectionManager _bleManager = BluetoothConnectionManager();

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Infinite loop with reverse effect

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Start scanning for devices
    _bleManager.startScan();

    // Check the connection status
    if (BluetoothConnectionManager().checkConnection()) {
      // The device is already connected
      print(
          "Already connected to device: ${BluetoothConnectionManager().connectedDeviceId}");
    } else {
      // Device is not connected, show "Bağlan" button
      print("No device connected. Show 'Bağlan' button.");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<DiscoveredDevice>>(
        stream: _bleManager.DiscoveredDeviceStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final devices = snapshot.data ?? [];
          if (devices.isEmpty) {
            return const Center(child: Text('Cihaz bulunamadı.'));
          }

          // Find the device with the name "Blank"
          final deviceToConnect = devices.firstWhere(
            (device) => device.name == "",
            orElse: () => DiscoveredDevice(
              id: "",
              name: "",
              manufacturerData: Uint8List(0),
              serviceData: {},
              rssi: 0,
              serviceUuids: [],
            ),
          );

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFA0BAFD), Colors.deepOrange.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _animation.value, // Scaling animation
                    child: ElevatedButton(
                      onPressed: () async {
                        // Check if the BluetoothController is already connected
                        if (_bleManager.checkConnection()) {
                          // If already connected, navigate to the test screen
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AnimationScreen(),
                          ));
                        } else {
                          // If not connected, attempt to connect to the "Blank" device
                          try {
                            await _bleManager
                                .connectToDevice(deviceToConnect.id);

                            // After successful connection, update the UI state
                            setState(
                                () {}); // This triggers the UI to reflect the connection change
                            print("BAGLANDI");

                            // Now navigate to the SpiroScreen
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AnimationScreen(),
                            ));
                          } catch (e) {
                            print("Failed to connect to the device: $e");
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                        padding: const EdgeInsets.all(70), // Larger button size
                        shape: const CircleBorder(),
                        elevation: 10,
                      ),
                      child: Text(
                        _bleManager.checkConnection()
                            ? 'Teste Başla'
                            : 'Bağlan',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TestScreen(),
  ));
}
