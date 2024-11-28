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
            "Bulunan karakteristik: ${characteristic.uuid}, Servis: ${service.uuid}");
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

  Future<void> sendChar1() async {
    if (_characteristic == null) return;

    try {
      final valueToSend = utf8.encode('1'); // '1' değerini gönder
      await _characteristic!.write(valueToSend);
      print("Char '1' gönderildi!");
    } catch (error) {
      print("Char '1' gönderilirken hata oluştu: $error");
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
      if (await permission.request().isDenied) {
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
