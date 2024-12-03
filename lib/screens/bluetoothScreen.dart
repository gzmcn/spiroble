import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spiroble/Bluetooth_Services/bluetooth_constant.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final BluetoothConnectionManager _bleManager = BluetoothConnectionManager();
  bool _isConnecting = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    // _bleManager.startScan(); // Start scanning if needed
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  void _connectToDevice1() async {
    setState(() {
      _isConnecting = true;
    });

    bool connected = false;//await _bleManager.connectToDevice();

    setState(() {
      _isConnecting = false;
      _isConnected = connected;
    });

    if (connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Spiromatike Bağlanıldı')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bağlantı Başarısız')),
      );
    }
  }

  void _denyConnection() {
    // Implement deny functionality, e.g., stop scanning or navigate back
    _bleManager.stopScan();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bağlantı İptal Edildi')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: EdgeInsets.only(top: 50, bottom: 20),
            color: Colors.blueAccent,
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Cihazınızı Bağlayın",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Cihaz bağlama ekranı",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Spacer
          SizedBox(height: 30),

          // Main Content
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustration Section
                Image.asset(
                  'assets/images/bluetooth_connected.jpg', // Ensure this asset is added in pubspec.yaml
                  width: 200,
                  height: 200,
                ),

                SizedBox(height: 20),

                // Connecting Text
                Column(
                  children: [
                    Text(
                      _isConnected
                          ? "Spiromatike Bağlantı Kuruldu"
                          : _isConnecting
                              ? "Spiromatike Bağlanılıyor"
                              : "Spiromatike Bağlanmayı Bekliyor",
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _isConnected
                          ? "Bağlantı başarılı!"
                          : _isConnecting
                              ? "Lütfen bekleyin..."
                              : "Lütfen izin vererek bağlantıyı başlatın.",
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Loading Animation (Circular Progress Indicator)
                if (_isConnecting)
                  CircularProgressIndicator(
                    color: Colors.blueAccent,
                    strokeWidth: 3,
                  ),

                SizedBox(height: 40),

                // Connection Permission Request
                Text(
                  "Spiromatike cihazı Bluetooth üzerinden bağlamak istiyor.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                  ),
                ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                  onPressed: _isConnecting || _isConnected
                      ? null
                      : _connectToDevice1,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
        ],
      ),
    );
  }
}