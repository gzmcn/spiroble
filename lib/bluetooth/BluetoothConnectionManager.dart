class BluetoothConnectionManager {
  static BluetoothConnectionManager _instance = BluetoothConnectionManager._internal();

  // Store the deviceId and connection state globally
  String? connectedDeviceId;
  bool isConnected = false;

  factory BluetoothConnectionManager() {
    return _instance;
  }

  BluetoothConnectionManager._internal();

  // Method to set the connection state
  void setConnectionState(String? deviceId, bool connected) {
    connectedDeviceId = deviceId;
    isConnected = connected;
  }

  // Method to check if a device is connected
  bool checkConnection() {
    return isConnected;
  }

  String? getDeviceId() {
    return connectedDeviceId;
  }
}
