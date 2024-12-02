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

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _bleManager.startScan();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Cihazlar'),
      ),
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
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ListTile(
                title: Text(device.name.isNotEmpty ? device.name : 'Cihaz: ${device.id.substring(0, 5)}'),
                subtitle: Text('ID: ${device.id} - RSSI: ${device.rssi ?? "Bilinmiyor"}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    //global bir değişkende tutulmalı dinamik olsun
                    if(_bleManager.checkConnection()){
                      _bleManager.disconnectToDevice(device.id);
                    }else{
                      _bleManager.connectToDevice(device.id);
                      print("bağlı");

                      String serviceUuid = BleUuids.Uuid3Services;
                      String characteristicUuid = BleUuids.Uuid3Characteristic;
                      _bleManager.sendChar1(serviceUuid, characteristicUuid, device.id);
                      // _bleController.notify(device.id);

                      _bleManager.notifyAsDoubles(device.id).listen((doubles) {
                          print("Bildirim alındı: ${doubles[0]}, ${doubles[1]}, ${doubles[2]}");
                        },
                        onError: (error) {
                          print("Hata: $error");
                        },
                      );
                    }

                  },
                  child:  Text( _bleManager.checkConnection() ? 'Bağlantıyı Kes' : 'Bağlan',),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
