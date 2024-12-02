abstract class BluetoothEvent {}

class StartScan extends BluetoothEvent {}

class StopScan extends BluetoothEvent {}

class ConnectToDevice extends BluetoothEvent {
  final String deviceId;

  ConnectToDevice(this.deviceId);
}

class DisconnectFromDevice extends BluetoothEvent {
  final String deviceId;

  DisconnectFromDevice(this.deviceId);
}

class CheckConnectionStatus extends BluetoothEvent {}

class SendCharacteristicValue extends BluetoothEvent {
  final String serviceUuid;
  final String characteristicUuid;
  final String deviceId;
  final String value;

  SendCharacteristicValue({
    required this.serviceUuid,
    required this.characteristicUuid,
    required this.deviceId,
    required this.value,
  });
}
