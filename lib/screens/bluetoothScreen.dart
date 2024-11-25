import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spiroble/bluetooth/ble_controller.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final BleController _bleController = BleController();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _bleController.startScan();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location
    ].request();
  }

  @override
  void dispose() {
    _bleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Cihazlar'),
      ),
      body: StreamBuilder<List<DiscoveredDevice>>(
        stream: _bleController.deviceStream,
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
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ListTile(
                title: Text(device.name.isNotEmpty ? device.name : 'Bilinmeyen Cihaz'),
                subtitle: Text('ID: ${device.id} - RSSI: ${device.rssi ?? "Bilinmiyor"}'), // RSSI ekledik
                trailing: ElevatedButton(
                  onPressed: () {
                    _bleController.connectToDevice(device.id);
                  },
                  child: const Text('Bağlan'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
