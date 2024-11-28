import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spiroble/Bluetooth_Services/ble_controller.dart';

class BluetoothProvider extends ChangeNotifier {
  final BleController _bleController = BleController();
}
