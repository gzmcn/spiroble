import 'package:flutter/material.dart';
import '../Bluetooth_Services/ble_controller.dart';
import 'package:permission_handler/permission_handler.dart';

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
      Permission.location,
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
      body: AnimatedBuilder(
        animation: _bleController,
        builder: (context, _) {
          final devices = _bleController.scannedDevices;
          if (devices.isEmpty) {
            return const Center(child: Text('Cihaz bulunamadı.'));
          }
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ListTile(
                title: Text(
                  device.name.isNotEmpty
                      ? device.name
                      : 'Cihaz: ${device.id.toString().substring(0, 5)}',
                ),
                subtitle: Text('ID: ${device.id}'),
                trailing: ElevatedButton(
                  onPressed: () async {
                    if (_bleController.isConnected &&
                        _bleController.connectedDevice?.id == device.id) {
                      await _bleController.disconnectFromDevice();
                    } else {
                      await _bleController.connectToDevice(device);

                      // Servisleri keşfetme örneği
                      final services = await _bleController.discoverServices();
                      for (var service in services) {
                        print('Service UUID: ${service.uuid}');
                        for (var characteristic in service.characteristics) {
                          print('Characteristic UUID: ${characteristic.uuid}');

                          // Bildirimlere abone ol
                          _bleController
                              .subscribeToNotifications(characteristic);
                        }
                      }
                    }
                  },
                  child: Text(_bleController.isConnected &&
                          _bleController.connectedDevice?.id == device.id
                      ? 'Bağlantıyı Kes'
                      : 'Bağlan'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
