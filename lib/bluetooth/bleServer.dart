import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';

class BleServer {
  final FlutterBlePeripheral blePeripheral = FlutterBlePeripheral();

  void startAdvertising() {
    final advertiseData = AdvertiseData(
      includeDeviceName: true,
      localName: "My BLE Device", // Cihaz adı
      manufacturerId: 1234,

    );

    blePeripheral.start(advertiseData: advertiseData);
    print("BLE Advertising başlatıldı.");
  }

  void stopAdvertising() {
    blePeripheral.stop();
    print("BLE Advertising durduruldu.");
  }
}
