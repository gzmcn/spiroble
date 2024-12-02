import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'package:spiroble/bluetooth/bloc/BluetoothEvent.dart';
import 'package:spiroble/bluetooth/bloc/BluetoothState.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final BluetoothConnectionManager _connectionManager;

  BluetoothBloc(this._connectionManager) : super(BluetoothInitial()) {
    // Event Handlers
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
    on<CheckConnectionStatus>(_onCheckConnectionStatus);
    on<SendCharacteristicValue>(_onSendCharacteristicValue);
  }

  // Handle Scan Event
  Future<void> _onStartScan(StartScan event, Emitter<BluetoothState> emit) async {
    emit(BluetoothScanning(devices: [])); // Pass an empty list as the initial state
    _connectionManager.startScan();
    _connectionManager.DiscoveredDeviceStream.listen(
          (devices) {
        emit(BluetoothScanResults(devices)); // Emit the list of discovered devices
      },
      onError: (error) {
        emit(BluetoothError("Scan failed: $error"));
      },
    );
  }


  // Handle Stop Scan Event
  void _onStopScan(StopScan event, Emitter<BluetoothState> emit) {
    _connectionManager.stopScan();
  }

  // Handle Connect to Device Event
  Future<void> _onConnectToDevice(
      ConnectToDevice event, Emitter<BluetoothState> emit) async {
    try {
      await _connectionManager.connectToDevice(event.deviceId);
      emit(BluetoothConnected(event.deviceId));
    } catch (error) {
      emit(BluetoothError("Failed to connect: $error"));
    }
  }

  // Handle Disconnect from Device Event
  Future<void> _onDisconnectFromDevice(
      DisconnectFromDevice event, Emitter<BluetoothState> emit) async {
    try {
      await _connectionManager.disconnectToDevice(event.deviceId);
      emit(BluetoothDisconnected());
    } catch (error) {
      emit(BluetoothError("Failed to disconnect: $error"));
    }
  }

  // Handle Check Connection Status Event
  void _onCheckConnectionStatus(
      CheckConnectionStatus event, Emitter<BluetoothState> emit) {
    final isConnected = _connectionManager.checkConnection();
    final deviceId = _connectionManager.connectedDeviceId;

    if (isConnected && deviceId != null) {
      emit(BluetoothConnected(deviceId));
    } else {
      emit(BluetoothDisconnected());
    }
  }

  // Handle Send Characteristic Value Event
  Future<void> _onSendCharacteristicValue(
      SendCharacteristicValue event, Emitter<BluetoothState> emit) async {
    try {
      await _connectionManager.sendChar1(
        event.serviceUuid,
        event.characteristicUuid,
        event.deviceId,
      );
    } catch (error) {
      emit(BluetoothError("Failed to send data: $error"));
    }
  }
}