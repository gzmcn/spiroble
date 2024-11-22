import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleController {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription? _scanSubscription;
  final _deviceStreamController = StreamController<List<DiscoveredDevice>>.broadcast();
  Stream<List<DiscoveredDevice>> get deviceStream => _deviceStreamController.stream;

  BleController();
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  // Initialize the BLE controller
  void initialize() {
    _ble.statusStream.listen((status) {
      print('BLE status: $status');
    });
  }

  // Start scanning for BLE devices
  void startScan() {
    _scanSubscription = _ble.scanForDevices(
      withServices: [], // Optionally, you can filter by services here
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      _updateDeviceList(device);
    });
  }

  // Stop scanning for BLE devices
  void stopScan() {
    _scanSubscription?.cancel();
  }

  // Update device list
  void _updateDeviceList(DiscoveredDevice device) {
    // If the device is not already in the list, add it
    if (!_deviceStreamController.hasListener) return; // Check if stream is closed
    _deviceStreamController.add([device]);
  }

  // Connect to a BLE device
  void connectToDevice(String deviceId) async {
    try {
      final connectionStream = _ble.connectToDevice(id: deviceId);
      _connectionSubscription = connectionStream.listen((connectionState) {
        print('Connection state: ${connectionState.connectionState}');
      });
      print('Attempting to connect to $deviceId');
    } catch (e) {
      print('Failed to connect: $e');
    }
  }

  // Dispose of resources
  void dispose() {
    _scanSubscription?.cancel();
    _deviceStreamController.close();
    _connectionSubscription?.cancel();
  }
}
