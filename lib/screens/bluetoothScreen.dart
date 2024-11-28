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
        title: const Text('Bluetooth_Services Cihazlar'),
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
                title: Text(device.name.isNotEmpty ? device.name : 'Cihaz: ${device.id.substring(0, 5)}'),
                subtitle: Text('ID: ${device.id} - RSSI: ${device.rssi ?? "Bilinmiyor"}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    if(_bleController.connection){
                      _bleController.disconnectToDevice(device.id);
                    }else{
                      _bleController.connectToDevice(device.id);
                      print("bağlı");

                      String serviceUuid = "4FAFC201-1FB5-459E-8FCC-C5C9C331914B";
                      String characteristicUuid = "E3223119-9445-4E96-A4A1-85358C4046A2";
                      _bleController.sendChar1(serviceUuid, characteristicUuid, device.id);
                      // _bleController.notify(device.id);

                      _bleController.notifyAsDoubles(device.id).listen((doubles) {
                          print("Bildirim alındı: ${doubles[0]}, ${doubles[1]}, ${doubles[2]}");
                        },
                        onError: (error) {
                          print("Hata: $error");
                        },
                      );
                    }

                  },
                  child:  Text( _bleController.connection ? 'Bağlantıyı Kes' : 'Bağlan',),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
