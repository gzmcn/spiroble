import 'package:flutter/material.dart';
import 'package:spiroble/bluetooth/ble_controller.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
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
    _initializePermissions();
    _bleController.initialize();
  }

  Future<void> _initializePermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.location.request().isGranted) {
      print('All required permissions granted!');
    } else {
      print('Permissions not granted. Scanning will not work.');
    }
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
        title: const Text('Bluetooth Low Energy'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _bleController.startScan,
              child: const Text('Start Scanning'),
            ),
            ElevatedButton(
              onPressed: _bleController.stopScan,
              child: const Text('Stop Scanning'),
            ),
            StreamBuilder<List<DiscoveredDevice>>(
              stream: _bleController.deviceStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No devices found');
                }
                final devices = snapshot.data!;
                return Column(
                  children: devices.map((device) {
                    return ListTile(
                      title: Text(device.name ?? 'Unknown'),
                      subtitle: Text(device.id.toString()),
                      onTap: () {
                        _bleController.connectToDevice(device.id);
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
