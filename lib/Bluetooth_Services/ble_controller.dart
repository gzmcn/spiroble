import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class BleController extends ChangeNotifier {
// İzin kontrolü
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
}
