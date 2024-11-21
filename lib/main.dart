import 'package:flutter/material.dart';
import 'ble_controller.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'bleServer.dart'; // Import your BLE server class
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  if (await Permission.bluetoothScan.request().isGranted &&
      await Permission.bluetoothConnect.request().isGranted &&
      await Permission.location.request().isGranted) {
    print('All required permissions granted!');
  } else {
    print('Permissions not granted. Scanning will not work.');
  }
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BLE Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BluetoothScreen(),
    );
  }
}

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  final BleController _bleController = BleController();

  @override
  void initState() {
    super.initState();
    _bleController.initialize();
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
        title: Text('Bluetooth Low Energy'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _bleController.startScan,
              child: Text('Start Scanning'),
            ),
            ElevatedButton(
              onPressed: _bleController.stopScan,
              child: Text('Stop Scanning'),
            ),
            StreamBuilder<List<DiscoveredDevice>>(
              stream: _bleController.deviceStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('No devices found');
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
