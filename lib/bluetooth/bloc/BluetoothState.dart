import 'package:flutter_reactive_ble/flutter_reactive_ble.dart'; // Import the required class

abstract class BluetoothState {}

class BluetoothInitial extends BluetoothState {}

class BluetoothScanning extends BluetoothState {
  final List<DiscoveredDevice> devices;  // Use DiscoveredDevice here, not BluetoothDevice

  BluetoothScanning({required this.devices});  // Constructor expecting devices list
}

class BluetoothScanResults extends BluetoothState {
  final List<DiscoveredDevice> devices;  // Use DiscoveredDevice here
  BluetoothScanResults(this.devices);
}

class BluetoothConnected extends BluetoothState {
  final String deviceId;
  BluetoothConnected(this.deviceId);
}

class BluetoothDisconnected extends BluetoothState {}

class BluetoothError extends BluetoothState {
  final String errorMessage;
  BluetoothError(this.errorMessage);
}
