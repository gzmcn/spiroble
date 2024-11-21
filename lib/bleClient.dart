import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleClient {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanSubscription;

  // Tarama başlatma ve cihazı bulma
  void startScan() {
    _scanSubscription = _ble.scanForDevices(withServices: []).listen((device) {
      if (device.name == 'My BLE Device') {  // Server cihazını adıyla bul
        print('Cihaz bulundu: ${device.name}');
        _connectToDevice(device.id);
      }
    });
  }

  // Cihaza bağlanma
  void _connectToDevice(String deviceId) {
    _ble.connectToDevice(id: deviceId).listen((connectionState) {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        print('Cihaza bağlanıldı!');
      }
    });
  }
}
