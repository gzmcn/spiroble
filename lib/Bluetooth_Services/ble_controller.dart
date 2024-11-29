import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleController extends ChangeNotifier {
  final FlutterBluePlus flutterBlue = FlutterBluePlus();
  BluetoothDevice? connectedDevice;
  final List<BluetoothDevice> _scannedDevices = [];
  Map<Guid, List<int>> readValues = {};
  bool isConnected = false;

  List<BluetoothDevice> get scannedDevices =>
      List.unmodifiable(_scannedDevices);

  // Cihazları tarama
  void startScan() {
    FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (!_scannedDevices.any((device) => device.id == result.device.id)) {
          _scannedDevices.add(result.device);
          notifyListeners();
        }
      }
    });
  }

  void stopScan() {
    FlutterBluePlus.stopScan();
  }

  // Bağlanma
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      connectedDevice = device;
      isConnected = true;
      notifyListeners();
    } catch (e) {
      print("Bağlantı hatası: $e");
    }
  }

  Future<void> disconnectFromDevice() async {
    if (connectedDevice != null) {
      await connectedDevice!.disconnect();
      connectedDevice = null;
      isConnected = false;
      notifyListeners();
    }
  }

  // Servisleri keşfetme
  Future<List<BluetoothService>> discoverServices() async {
    if (connectedDevice == null) {
      throw Exception("Cihaz bağlı değil.");
    }
    return await connectedDevice!.discoverServices();
  }

  // Veri okuma
  Future<void> readCharacteristic(
      BluetoothCharacteristic characteristic) async {
    if (connectedDevice == null) return;
    List<int> value = await characteristic.read();
    readValues[characteristic.uuid] = value;
    notifyListeners();
  }

  // Veri yazma
  Future<void> writeCharacteristic(
      BluetoothCharacteristic characteristic, String data) async {
    if (connectedDevice == null) return;
    await characteristic.write(utf8.encode(data));
  }

  // Bildirimlere abone olma
  void subscribeToNotifications(BluetoothCharacteristic characteristic) {
    characteristic.setNotifyValue(true);
    characteristic.value.listen((value) {
      print("Bildirim alındı: $value");
      readValues[characteristic.uuid] = value;
      notifyListeners();
    });
  }

  // Kaynakları temizleme
  @override
  void dispose() {
    stopScan();
    disconnectFromDevice();
    super.dispose();
  }
}
