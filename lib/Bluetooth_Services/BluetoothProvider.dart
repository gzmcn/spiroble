import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spiroble/Bluetooth_Services/ble_controller.dart';

class BluetoothProvider extends ChangeNotifier{
  final BleController _bleController = BleController();

  bool get isConnected => _bleController.connection;

  void startListening(String deviceId) {
    _bleController.startConnectionStateListener(deviceId);
    notifyListeners();
  }

  void stopListening() {
    _bleController.stopConnectionStateListener();
    notifyListeners();
  }

}