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
    print("Cihaza bağlanılıyor: $deviceId");
    _connectionSubscription = _ble.connectToDevice(id: deviceId).listen(
      (connectionState) async {
        print("Bağlantı durumu: ${connectionState.connectionState}");
        if (connectionState.connectionState ==
            DeviceConnectionState.connected) {
          print("Bağlantı başarılı: $deviceId");
          await Future.delayed(Duration(seconds: 5)); // Gecikme ekleyin
          await initializeCommunication(deviceId);
        } else if (connectionState.connectionState ==
            DeviceConnectionState.disconnected) {
          print("Cihaz bağlantısı kesildi: $deviceId");
        }
      },
      onError: (error) {
        print("Bağlantı sırasında hata oluştu: $error");
      },
    );
  }

  // Initialize _characteristic properly
  Future<void> initializeCharacteristic(
      String deviceId, String serviceUuid, String characteristicUuid) async {
    Uuid serviceUuidParsed = Uuid.parse(serviceUuid);
    Uuid characteristicUuidParsed = Uuid.parse(characteristicUuid);

    _characteristic = QualifiedCharacteristic(
      deviceId: deviceId,
      serviceId: serviceUuidParsed,
      characteristicId: characteristicUuidParsed,
    );
  }

  // Bağlantı sonrası karakteristik hazırlıkları ve UUID'yi yazdırma
  Future<void> initializeCommunication(String deviceId) async {
    Uuid serviceUuid = Uuid.parse('CF3970D0-9A76-4C78-AD8D-4F429F3B2408');
    Uuid characteristicUuid =
        Uuid.parse('19F54122-33AF-4E8F-9F3A-D5CD075EFD49');

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

  Future<void> sendChar1() async {
    // Ensure the characteristic is initialized before use.
    if (_characteristic == null) {
      print("Characterisitc is not initialized.");
      return;
    }

    try {
      await _ble.writeCharacteristicWithResponse(
        _characteristic,
        value: [1], // Sending `char 1`
      );
      print("char 1 gönderildi!");
    } catch (error) {
      print("char 1 gönderilirken hata oluştu: $error");
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

  // Kaynakları temizlemek için dispose metodu
  void dispose() {
    print("Kaynaklar temizleniyor...");
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _deviceStreamController.close();
  }
}
