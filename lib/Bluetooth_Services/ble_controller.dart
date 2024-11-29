import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';

class BleController extends ChangeNotifier {
  final FlutterBluePlus _flutterBlue = FlutterBluePlus();
  final StreamController<List<BluetoothDevice>> _deviceStreamController =
  StreamController.broadcast();

  Stream<List<BluetoothDevice>> get deviceStream =>
      _deviceStreamController.stream;

  final List<BluetoothDevice> _devices = [];
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;

  bool _isConnected = false;

  bool get isConnected => _isConnected;

  String deviceId = '';

  void setConnection(bool value) {
    _isConnected = value;
    notifyListeners();
  }

  Future<void> startScan() async {
    if (!await _checkPermissions()) {
      print("Gerekli izinler verilmedi!");
      return;
    }

    print("Tarama başlatılıyor...");
    _devices.clear();

    // Tarama başlatılır ve dinlenir
    FlutterBluePlus.scanResults.listen((results) {
      for (var scanResult in results) {
        if (!_devices.any((device) => device.id == scanResult.device.id)) {
          _devices.add(scanResult.device);
          _deviceStreamController.add(List.unmodifiable(_devices));
        }
      }
    }, onError: (error) {
      print("Tarama sırasında hata oluştu: $error");
    });

    // Tarama başlatılır
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
  }

  void stopScan() {
    print("Tarama durduruluyor...");
    FlutterBluePlus.stopScan();
  }

  // İzin kontrolü
  Future<bool> _checkPermissions() async {
    final permissions = [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ];

    for (var permission in permissions) {
      if (await permission
          .request()
          .isDenied) {
        print("${permission.value} izni verilmedi.");
        return false;
      }
    }
    print("Tüm izinler verildi.");
    return true;
  }

  Future<void> connectToDevice(String deviceId) async {
    try {
      print("Cihaza bağlanılıyor: $deviceId");
      final device = _devices.firstWhere((d) => d.id == deviceId);
      await device.connect();
      _connectedDevice = device;
      this.deviceId = deviceId;
      setConnection(true);

      print("Bağlantı başarılı: $deviceId");
      _discoverServices();
    } catch (error) {
      print("Bağlantı sırasında hata oluştu: $error");
      setConnection(false);
    }
  }

  Future<void> disconnectFromDevice() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
        print("Bağlantı kesildi: $deviceId");
        setConnection(false);
        _connectedDevice = null;
        deviceId = '';
      } catch (error) {
        print("Bağlantı kesilirken hata oluştu: $error");
      }
    }
  }

  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;

    print("Servisler keşfediliyor...");
    final services = await _connectedDevice!.discoverServices();

    for (var service in services) {
      for (var characteristic in service.characteristics) {
        print(
            "Bulunan karakteristik: ${characteristic.uuid}, Servis: ${service
                .uuid}");
        if (_isTargetCharacteristic(characteristic)) {
          _characteristic = characteristic;
          _startReceivingData();
          break;
        }
      }
    }
  }

  bool _isTargetCharacteristic(BluetoothCharacteristic characteristic) {
    // Belirli bir karakteristiği hedeflemek için kontrol ekleyin
    return characteristic.uuid.toString().toUpperCase() ==
        'BEB5483E-36E1-4688-B7F5-EA07361B26A8';
  }

  Future<void> sendChar1(String serviceUuid, String characteristicUuid,
      String deviceId, dynamic FlutterBlue) async {
    try {
      BluetoothDevice device = await FlutterBlue.instance.connect(deviceId);
      BluetoothService service = (await device.discoverServices()).firstWhere(
            (service) => service.uuid.toString() == serviceUuid,
        orElse: () => throw Exception('Service not found'),
      );

      BluetoothCharacteristic characteristic = service.characteristics
          .firstWhere(
            (characteristic) =>
        characteristic.uuid.toString() == characteristicUuid,
        orElse: () => throw Exception('Characteristic not found'),
      );

      print("Sending char '1' to characteristic: $characteristic");

      final valueToSend = utf8.encode('1'); // [49]

      // Write to the characteristic with response
      await characteristic.write(valueToSend, withoutResponse: false);

      print("Char '1' sent!");
    } catch (error) {
      print("Error sending char '1': $error");
    }
  }

  Future<void> uid3(String deviceId, dynamic FlutterBlue) async {
    BluetoothDevice device = await FlutterBlue.instance.connect(deviceId);
    BluetoothService service = (await device.discoverServices()).firstWhere(
          (service) =>
      service.uuid.toString() == '4FAFC201-1FB5-459E-8FCC-C5C9C331914B',
      orElse: () => throw Exception('Service not found'),
    );

    BluetoothCharacteristic characteristic = service.characteristics.firstWhere(
          (characteristic) =>
      characteristic.uuid.toString() == 'E3223119-9445-4E96-A4A1-85358C4046A2',
      orElse: () => throw Exception('Characteristic not found'),
    );

    try {
      final response = await characteristic.read();
      print('Third data: $response');

      if (response.isNotEmpty && response[0] == 1) {
        _startReceivingData();
      }
    } catch (error) {
      print("Error reading data: $error");
    }
  }

  Stream<List<double>> notifyAsDoubles(String deviceId,
      dynamic FlutterBlue) async* {
    BluetoothDevice device = await FlutterBlue.instance.connect(deviceId);
    BluetoothService service = (await device.discoverServices()).firstWhere(
          (service) =>
      service.uuid.toString() == '4FAFC201-1FB5-459E-8FCC-C5C9C331914B',
      orElse: () => throw Exception('Service not found'),
    );

    BluetoothCharacteristic characteristic = service.characteristics.firstWhere(
          (characteristic) =>
      characteristic.uuid.toString() == 'BEB5483E-36E1-4688-B7F5-EA07361B26A8',
      orElse: () => throw Exception('Characteristic not found'),
    );

    characteristic.setNotifyValue(true); // Subscribe to notifications

    await for (List<int> data in characteristic.value) {
      try {
        final rawString = utf8.decode(data);

        // Check if the data starts and ends with curly braces
        if (!rawString.startsWith("{") || !rawString.endsWith("}")) {
          throw Exception("Unexpected data format: $rawString");
        }

        // Trim curly braces and split by commas
        final trimmed = rawString.substring(1, rawString.length - 1);
        final values = trimmed.split(",").map((value) {
          return double.parse(value.trim());
        }).toList();

        // Expecting 3 values
        if (values.length != 3) {
          throw Exception("Unexpected data length: $values");
        }

        yield values;
      } catch (error) {
        throw Exception("Data parsing error: $error");
      }
    }


    void _startReceivingData() {
      if (_characteristic == null) return;

      _characteristic!.setNotifyValue(true);
      _characteristic!.value.listen((data) {
        print("Alınan veri: ${utf8.decode(data)}");
      }, onError: (error) {
        print("Veri alımı sırasında hata oluştu: $error");
      });
    }

    Future<bool> _checkPermissions() async {
      final permissions = [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ];

      for (var permission in permissions) {
        if (await permission
            .request()
            .isDenied) {
          print("${permission.value} izni verilmedi.");
          return false;
        }
      }
      print("Tüm izinler verildi.");
      return true;
    }

    @override
    void dispose() {
      print("Kaynaklar temizleniyor...");
      _deviceStreamController.close();
      disconnectFromDevice();
      super.dispose();
    }
  }
}