import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';


class BleController extends ChangeNotifier{
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;

  Stream<DeviceConnectionState>? _connectionStateStream;
  late StreamSubscription<DeviceConnectionState> _connectionStateSubscription;

  final StreamController<List<DiscoveredDevice>> _deviceStreamController = StreamController.broadcast();

  Stream<List<DiscoveredDevice>> get deviceStream => _deviceStreamController.stream;

  final List<DiscoveredDevice> _devices = [];
  late QualifiedCharacteristic _characteristic;

  // dinamik veri kontrolü
  bool _connection = false;
  bool get connection => _connection;


  String? connectedDeviceId;

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

  void setConnection(String? deviceId, bool value) {
    connectedDeviceId = deviceId;
    _connection = value;
    notifyListeners(); // Durum değişikliğini bildir
  }

  // BLE bağlantısını başlatmak için initialize metodu
  void initialize() {
    print("BLE bağlantısı başlatılıyor...");
    // Gerekli başlangıç işlemleri burada yapılabilir.
  }

  // BLE cihazlarını taramaya başlama
  Future<void> startScan() async {
    if (!await _checkPermissions()) {
      print("Gerekli izinler verilmedi!");
      return;
    }

    print("Tarama başlatılıyor...");
    _scanSubscription = _ble.scanForDevices(withServices: []).listen(
          (device) {
        _addDeviceToStream(device);
      },
      onError: (error) {
        print("Tarama sırasında hata oluştu: $error");
      },
      onDone: () {
        print("Tarama tamamlandı.");
      },
    );
  }

  // Tarama sırasında bulunan cihazları listeye ekleme
  void _addDeviceToStream(DiscoveredDevice device) {
    if (!_devices.any((d) => d.id == device.id)) {
      _devices.add(device);
      _deviceStreamController.add(List.unmodifiable(_devices));
    }
  }

  // Bağlantı kurma
  Future<void> connectToDevice(String deviceId) async {
    print("Cihaza bağlanılıyor: $deviceId");
    _connectionSubscription = _ble.connectToDevice(id: deviceId).listen((connectionState) async {
        print("Bağlantı durumu: ${connectionState.connectionState}");
        if (connectionState.connectionState == DeviceConnectionState.connected) {
            print("Bağlantı başarılı: $deviceId");

            setConnection(deviceId ,true);
            await Future.delayed(Duration(seconds: 1)); // Gecikme ekleyin

            await initializeCommunication(deviceId);
            await notify(deviceId);
            await uid3(deviceId);

        } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
          print("Cihaz bağlantısı kesildi: $deviceId");
          setConnection(deviceId, false);
        }
      },
      onError: (error) {
        print("Bağlantı sırasında hata oluştu: $error");
      },
    );
  }

  void startConnectionStateListener(String deviceId) {
    // Bağlantı durumunu sürekli dinlemek için stream başlat
    _connectionStateStream = _ble.connectToDevice(id: deviceId);

    // Stream'e abone ol
    _connectionStateSubscription = _connectionStateStream!.listen((connectionState) {
      // Bağlantı durumu güncellenince yapılacak işlemler
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        connectedDeviceId = deviceId;
        _connection = true; // Bağlantı başarılı
        print("Cihaz bağlı: $deviceId");
      } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
        connectedDeviceId = null;
        _connection = false; // Bağlantı kesildi
        print("Cihaz bağlantısı kesildi: $deviceId");
      }
    }, onError: (error) {
      print("Bağlantı hatası: $error");
      connectedDeviceId = null;
      _connection = false; // Hata durumunda bağlantıyı kesilmiş olarak kabul et
    });
  }


}



















