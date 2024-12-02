import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spiroble/Bluetooth_Services/bluetooth_constant.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spiroble/bluetooth/bloc/BluetoothBloc.dart'; // Import BluetoothBloc
import 'package:spiroble/bluetooth/bloc/BluetoothEvent.dart'; // Import BluetoothEvent
import 'package:spiroble/bluetooth/bloc/BluetoothState.dart'; // Import BluetoothState


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
    return BlocProvider<BluetoothBloc>(
      create: (context) => BluetoothBloc(_bleManager), // Initialize the BluetoothBloc
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Bluetooth Cihazlar'),
        ),
        body: BlocBuilder<BluetoothBloc, BluetoothState>(
          builder: (context, state) {
            if (state is BluetoothInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is BluetoothError) {
              return Center(child: Text('Hata: ${state.errorMessage}'));
            }
            if (state is BluetoothScanning) {
              final devices = state.devices;
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
                        if (_bleManager.checkConnection()) {
                          _bleManager.disconnectToDevice(device.id);
                          context.read<BluetoothBloc>().add(DisconnectFromDevice(device.id));
                        } else {
                          _bleManager.connectToDevice(device.id);
                          context.read<BluetoothBloc>().add(ConnectToDevice(device.id));

                          String serviceUuid = BleUuids.Uuid3Services;
                          String characteristicUuid = BleUuids.Uuid3Characteristic;
                          _bleManager.sendChar1(serviceUuid, characteristicUuid, device.id);

                          _bleManager.notifyAsDoubles(device.id).listen((doubles) {
                            print("Bildirim alındı: ${doubles[0]}, ${doubles[1]}, ${doubles[2]}");
                          }, onError: (error) {
                            print("Hata: $error");
                          });
                        }
                      },
                      child: Text(_bleManager.checkConnection() ? 'Bağlantıyı Kes' : 'Bağlan'),
                    ),
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}