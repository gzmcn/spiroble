import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'package:spiroble/bluetooth/bluetooth_constant.dart';


class SpiroScreen extends StatefulWidget {
  const SpiroScreen({super.key});

  @override
  _SpiroScreenState createState() => _SpiroScreenState();
}

class _SpiroScreenState extends State<SpiroScreen> {
  late final BluetoothConnectionManager _bleManager;
  double progress = 0.0; // Sıvı seviyesi başlangıcı
  final double maxHeight = 10.0; // Maksimum sıvı yüksekliği
  final BleUuids _bleUuids = BleUuids();


  @override
  void initState() {
    super.initState();
    _bleManager = BluetoothConnectionManager(); // BLE bağlantısı için kontrolcü

  }

  @override
  void dispose() {
    super.dispose();
  }



  Future<void> incrementProgress() async {
    setState(() {
      if (progress < maxHeight) {
        progress += 1.0; // Increase progress
      }
    });

    // Start scanning for devices
    await _bleManager.startScan();

    String? deviceId;
    await for (List<DiscoveredDevice> devices in _bleManager.DiscoveredDeviceStream) {
      for (var device in devices) {
        if (device.name == "Spirometer") {
          print("Device 'Spirometer' found: ${device.id}");

          // Set the deviceId and stop the scan once the device is found
          deviceId = device.id;
          break;
        }
      }
      if (deviceId != null) {
        // If a device was found, break out of the loop
        break;
      }
    }

    if (deviceId != null) {
      String serviceUuid = "4FAFC201-1FB5-459E-8FCC-C5C9C331914B";
      String characteristicUuid = "E3223119-9445-4E96-A4A1-85358C4046A2";

      try {
        // Initialize the characteristic with the found deviceId
        await _bleManager.initializeCharacteristic(deviceId, serviceUuid, characteristicUuid);
        print("Characteristic initialized successfully.");

        // Send char1 after initializing the characteristic
        await _bleManager.sendChar1(serviceUuid,characteristicUuid, deviceId);

        // Update the Bluetooth connection state globally
        BluetoothConnectionManager().setConnectionState(deviceId, true);
      } catch (error) {
        print("Error while initializing characteristic or sending char1: $error");
      }
    } else {
      print("No device found to connect to.");
    }
  }








  @override
  Widget build(BuildContext context) {
    final deviceId = BluetoothConnectionManager().connectedDeviceId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('SpiroScreen'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFA0BAFD), Colors.deepOrange.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Üfleyin",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              CustomPaint(
                size: const Size(120, 300), // Borunun boyutu
                painter: SpirometerPainter(progress, maxHeight),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  incrementProgress(); // Butona basıldığında işlemleri başlat
                  if (deviceId != null) {
                    _bleManager.sendChar1(BleUuids.Uuid3Services, BleUuids.Uuid3Characteristic, deviceId);
                    _bleManager.notifyAsDoubles(deviceId); // null değilse çağır
                  } else {
                    print("Bağlı cihaz yok, işlem yapılamaz.");
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  backgroundColor: const Color.fromARGB(255, 251, 251, 251),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // Buton boyutu
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Yuvarlatılmış köşeler
                  ),
                  elevation: 8, // Gölge efekti
                ),
                child: const Text(
                  "Char 1 Verisi Gönder",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (progress == maxHeight) // Sıvı maksimum seviyeye ulaştıysa
                const Text(
                  "Sonuçlandı",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpirometerPainter extends CustomPainter {
  final double progress;
  final double maxHeight;

  SpirometerPainter(this.progress, this.maxHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blueAccent, Colors.purpleAccent],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final rect = Rect.fromLTWH(
      20,
      10,
      size.width - 40,
      size.height - 20,
    );
    final progressHeight = (size.height - 20) * (progress / maxHeight);

    // Boru (dış çerçeve)
    canvas.drawRect(rect, borderPaint);

    // Sıvının içi
    canvas.drawRect(
      Rect.fromLTWH(
        20,
        size.height - 10 - progressHeight,
        size.width - 40,
        progressHeight,
      ),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
