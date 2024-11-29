import 'dart:async';
import 'dart:convert';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:spiroble/Bluetooth_Services/bluetooth_constant.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'dart:typed_data';

class BleController extends ChangeNotifier {
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
    notifyListeners();
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

  void _addDeviceToStream(DiscoveredDevice device) {
    if (!_devices.any((d) => d.id == device.id)) {
      _devices.add(device);
      _deviceStreamController.add(List.unmodifiable(_devices));
    }
  }

  // BLE cihazlarını taramayı durdurma
  void stopScan() {
    print("Tarama durduruluyor...");
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  // Tarama sırasında bulunan cihazları listeye ekleme

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

          await Future.delayed(Duration(seconds: 1)); // Gecikme ekleyin
          await initializeCommunication(deviceId);
          await notify(deviceId);
          await uid3(deviceId);
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

  Future<void> initializeCharacteristic(
      String deviceId, String serviceUuid, String characteristicUuid) async {
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
    Uuid serviceUuid =
        Uuid.parse(BleUuids.initializeCommunicationServiceCharacteristicUuid);
    Uuid characteristicUuid =
        Uuid.parse(BleUuids.initializeCommunicationServiceCharacteristicUuid);

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
    Uuid serviceUuid = Uuid.parse(
        BleUuids.notifyServiceUuid); // B6B22132-0DD2-4480-82C5-F8783DFA6C42
    Uuid characteristicUuid = Uuid.parse(BleUuids
        .notifycharacteristicUuid); // E23A9EDE-3257-4AAA-BF53-8FAC3289726F

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

  Stream<List<double>> notifyAsDoubles(String deviceId) {
    Uuid serviceUuid = Uuid.parse(BleUuids.notifyServiceUuid);
    Uuid characteristicUuid = Uuid.parse(BleUuids.notifycharacteristicUuid);

    final characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: deviceId,
    );

    // Karakteristikten gelen bildirimleri dinle ve özel formatı çözümle
    return _ble.subscribeToCharacteristic(characteristic).map((data) {
      try {
        // Veriyi string olarak çöz
        final rawString = utf8.decode(data);

        // Süslü parantez kontrolü
        if (!rawString.startsWith("{") || !rawString.endsWith("}")) {
          throw Exception("Beklenmeyen veri formatı: $rawString");
        }

        // Süslü parantezleri temizle
        final trimmed = rawString.substring(1, rawString.length - 1);

        // Boşluklara dikkat ederek ayrıştırma
        final values = trimmed.split(",").map((value) {
          return double.parse(value.trim());
        }).toList();

        // Üç değer bekleniyor, hata kontrolü
        if (values.length != 3) {
          throw Exception("Beklenmeyen veri uzunluğu: $values");
        }

        return values;
      } catch (error) {
        throw Exception("Veri ayrıştırma hatası: $error");
      }
    });
  }

  Future<void> uid3(String deviceId) async {
    Uuid serviceUuid = Uuid.parse(
        BleUuids.Uuid3Services); // D72FDD71-D631-4381-841B-B695DA002032
    Uuid characteristicUuid = Uuid.parse(
        BleUuids.Uuid3Characteristic); // F8C87645-5A2E-40CF-9B22-30D72089DF2B

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

  Future<void> sendChar1(
      String serviceUuid, String characteristicUuid, String deviceId) async {
    try {
      // UUID'leri Uuid formatına çevir
      Uuid parsedServiceUuid = Uuid.parse(serviceUuid);
      Uuid parsedCharacteristicUuid = Uuid.parse(characteristicUuid);

      // Karakteristiği tanımla
      _characteristic = QualifiedCharacteristic(
        serviceId: parsedServiceUuid,
        characteristicId: parsedCharacteristicUuid,
        deviceId: deviceId, // Daha önce bağlanılan cihaz ID'si
      );

      print("Sending char '1' to characteristic: $_characteristic");

      // UTF-8 formatında '1' karakterini byte array olarak hazırla
      final valueToSend = utf8.encode('1'); // [49]

      // Karakteristiğe yaz
      await _ble.writeCharacteristicWithResponse(
        _characteristic,
        value: valueToSend,
      );

      print("Char '1' gönderildi!");
    } catch (error) {
      print("Error sending char '1': $error");
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
  @override
  void dispose() {
    super.dispose();
    print("Kaynaklar temizleniyor...");
    _scanSubscription?.cancel();
    _deviceStreamController.close();
  }
}
