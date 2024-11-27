import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class BleController extends ChangeNotifier{
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;


  final StreamController<List<DiscoveredDevice>> _deviceStreamController =
      StreamController.broadcast();

  Stream<List<DiscoveredDevice>> get deviceStream =>
      _deviceStreamController.stream;

  final List<DiscoveredDevice> _devices = [];
  late QualifiedCharacteristic _characteristic;

  // dinamik veri kontrolü
  bool _connection = false;
  bool get connection => _connection;

  String deviceId = '';

  void setConnection(bool value) {
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
          this.deviceId = deviceId;
          setConnection(true);
          await Future.delayed(Duration(seconds: 1)); // Gecikme ekleyin
          await initializeCommunication(deviceId);
          await notify(deviceId);
          await uid3(deviceId);
        } else if (connectionState.connectionState ==
            DeviceConnectionState.disconnected) {
          print("Cihaz bağlantısı kesildi: $deviceId");
          setConnection(false);
        }
      },
      onError: (error) {
        print("Bağlantı sırasında hata oluştu: $error");
      },
    );
  }

  Future<void> disconnectToDevice(String deviceId) async {
    try {
      await _connectionSubscription?.cancel();
      _connectionSubscription = null;
      print("Cihaz bağlantısı başarıyla kesildi: $deviceId");
      setConnection(false); // Bağlantı durumu güncellendi
      deviceId = '';
    } catch (error) {
      print("Cihaz bağlantısı kesilirken hata oluştu: $error");
      setConnection(true);
    }
  }

  Future<void> initializeCharacteristic(String deviceId, String serviceUuid, String characteristicUuid) async {
    try {
      // Attempt to parse the UUIDs
      Uuid serviceUuidParsed = Uuid.parse(serviceUuid);
      Uuid characteristicUuidParsed = Uuid.parse(characteristicUuid);

      // Initialize the characteristic
      _characteristic = QualifiedCharacteristic(
        deviceId: deviceId,
        serviceId: serviceUuidParsed,
        characteristicId: characteristicUuidParsed,
      );
      print("Characteristic initialized successfully.");
    } catch (e) {
      print("Error parsing UUIDs: $e");
    }
  }

  // Bağlantı sonrası karakteristik hazırlıkları ve UUID'yi yazdırma
  Future<void> initializeCommunication(String deviceId) async {
    Uuid serviceUuid = Uuid.parse('00002A00-0000-1000-8000-00805F9B34FB');
    Uuid characteristicUuid = Uuid.parse('00002A00-0000-1000-8000-00805F9B34FB');

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

  // Bağlantı sonrası karakteristik hazırlıkları ve UUID'yi yazdırma
  Future<void> notify(String deviceId) async {
    Uuid serviceUuid = Uuid.parse('4FAFC201-1FB5-459E-8FCC-C5C9C331914B'); // B6B22132-0DD2-4480-82C5-F8783DFA6C42
    Uuid characteristicUuid = Uuid.parse('BEB5483E-36E1-4688-B7F5-EA07361B26A8'); // E23A9EDE-3257-4AAA-BF53-8FAC3289726F

    print('Servis UUID: $serviceUuid');
    print('Karakteristik UUID: $characteristicUuid');

    _characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: deviceId,
    );

    try {
      final response = await _ble.readCharacteristic(_characteristic);
      print('İkinci veri: $response');

      if (response.isNotEmpty && response[0] == 1) {
        _startReceivingData();
      }
    } catch (error) {
      print("Veri okuma sırasında hata oluştu: $error");
    }
  }

  Future<void> uid3(String deviceId) async {
    Uuid serviceUuid = Uuid.parse('4FAFC201-1FB5-459E-8FCC-C5C9C331914B'); // D72FDD71-D631-4381-841B-B695DA002032
    Uuid characteristicUuid = Uuid.parse('E3223119-9445-4E96-A4A1-85358C4046A2'); // F8C87645-5A2E-40CF-9B22-30D72089DF2B

    print('Servis UUID: $serviceUuid');
    print('Karakteristik UUID: $characteristicUuid');

    _characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: deviceId,
    );

    try {
      final response = await _ble.readCharacteristic(_characteristic);
      print('Üçüncü veri: $response');

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
      print("Characteristic is not initialized.");
      return;
    }

    try {
      // Log the characteristic's UUID and the data being sent for debugging purposes
      print("Sending char 1 to characteristic: $_characteristic");

      // Send the char1 value to the characteristic
      await _ble.writeCharacteristicWithResponse(
        _characteristic,
        value: [1], // Sending `char 1`
      );
      print("char 1 gönderildi!");
    } catch (error) {
      print("Error sending char 1: $error");
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
