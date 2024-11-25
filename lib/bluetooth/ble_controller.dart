import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class BleController {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  final StreamController<List<DiscoveredDevice>> _deviceStreamController =
  StreamController.broadcast();
  Stream<List<DiscoveredDevice>> get deviceStream =>
      _deviceStreamController.stream;

  final List<DiscoveredDevice> _devices = [];
  late QualifiedCharacteristic _characteristic;

  // BLE cihazlarını taramaya başlama
  Future<void> startScan() async {
    // İzinleri kontrol et
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

  // BLE cihazlarını taramayı durdurma
  void stopScan() {
    print("Tarama durduruluyor...");
    _scanSubscription?.cancel();
    _scanSubscription = null;
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
    while (true) {
      try {
        print("Cihaza bağlanılıyor: $deviceId");
        _connectionSubscription = _ble.connectToDevice(
          id: deviceId,
          connectionTimeout: const Duration(seconds: 30), // Kısa bir timeout
        ).listen(
              (connectionState) async {
            print("Bağlantı durumu: ${connectionState.connectionState}");
            if (connectionState.connectionState == DeviceConnectionState.connected) {
              print("Bağlantı başarılı: $deviceId");
              await _initializeCommunication(deviceId);
              return; // Bağlantı başarılı olursa döngüden çık
            }
          },
          onError: (error) {
            print("Bağlantı sırasında hata oluştu: $error");
          },
        );

        await Future.delayed(Duration(seconds: 5)); // Gecikme ekleyerek yeniden deneme
      } catch (e) {
        print("Bağlantı hatası: $e");
      }
    }
  }



  // Bağlantı sonrası karakteristik hazırlıkları ve UUID'yi yazdırma
  Future<void> _initializeCommunication(String deviceId) async {
    Uuid serviceUuid = Uuid.parse('0000180f-0000-1000-8000-00805f9b34fb');
    Uuid characteristicUuid = Uuid.parse('00002a19-0000-1000-8000-00805f9b34fb');

    print('Servis UUID: $serviceUuid');
    print('Karakteristik UUID: $characteristicUuid');

    _characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: deviceId,
    );

    try {
      final response = await _ble.readCharacteristic(_characteristic);
      print('İlk veri: $response');

      if (response.isNotEmpty && response[0] == 1) {
        _startReceivingData();
      }
    } catch (error) {
      print("Veri okuma sırasında hata oluştu: $error");
    }
  }

  // Cihazdan veri okuma işlemini başlatma
  void _startReceivingData() {
    print("Veri alımı başlatılıyor...");
    _ble.subscribeToCharacteristic(_characteristic).listen(
          (data) {
        print('Alınan veri: $data');
      },
      onError: (error) {
        print("Veri alımı sırasında hata oluştu: $error");
      },
    );
  }

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

  // Kaynakları temizleme
  void dispose() {
    print("Kaynaklar temizleniyor...");
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _deviceStreamController.close();
  }
}
