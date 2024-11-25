import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleController {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription<DiscoveredDevice>? _scanSubscription;
  StreamSubscription<ConnectionStateUpdate>? _connectionSubscription;
  StreamController<List<DiscoveredDevice>> _deviceStreamController = StreamController.broadcast();
  Stream<List<DiscoveredDevice>> get deviceStream => _deviceStreamController.stream;

  // Cihazları saklayacak bir liste
  final List<DiscoveredDevice> _devices = [];

  late QualifiedCharacteristic _characteristic;

  // BLE cihazlarını taramaya başlama
  void startScan() {
    _scanSubscription = _ble.scanForDevices(withServices: []).listen((device) {
      _addDeviceToStream(device);  // Her cihazı listeye ekliyoruz
    });
  }

  // BLE cihazlarını taramayı durdurma
  void stopScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  // Tarama sırasında bulunan cihazları listeye ekleme
  void _addDeviceToStream(DiscoveredDevice device) {
    if (!_devices.any((d) => d.id == device.id)) {  // Cihaz zaten listede mi?
      _devices.add(device);  // Eğer değilse, cihazı listeye ekliyoruz
      if (!_deviceStreamController.isClosed) {
        _deviceStreamController.add(_devices);  // Cihaz listemizi güncelliyoruz
      }
    }
  }

  // Bağlantı kurduğunda servis ve karakteristik UUID'yi yazdırma
  Future<void> connectToDevice(String deviceId) async {
    _connectionSubscription = _ble.connectToDevice(id: deviceId).listen((connectionState) async {
      if (connectionState.connectionState == DeviceConnectionState.connected) {
        print('Cihaza bağlanıldı: $deviceId');
        await _initializeCommunication(deviceId);
      } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
        print('Cihaz bağlantısı kesildi: $deviceId');
      }
    });
  }

  // Bağlantı sonrası karakteristik hazırlıkları ve UUID'yi yazdırma
  Future<void> _initializeCommunication(String deviceId) async {
    // Servis ve karakteristik UUID'yi buraya ekliyoruz
    Uuid serviceUuid = Uuid.parse('0000180f-0000-1000-8000-00805f9b34fb'); // Değiştirmeniz gerekebilir
    Uuid characteristicUuid = Uuid.parse('00002a19-0000-1000-8000-00805f9b34fb');
    print('Servis UUID: $serviceUuid');
    print('Karakteristik UUID: $characteristicUuid');

    _characteristic = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: deviceId,
    );

    // Aygıttan veri almak için ayar yapıyoruz
    final response = await _ble.readCharacteristic(_characteristic);
    print('İlk veri: $response');

    if (response[0] == 1) {
      _startReceivingData();
    }
  }

  // Cihazdan veri okuma işlemini başlatma
  void _startReceivingData() {
    _ble.subscribeToCharacteristic(_characteristic).listen((data) {
      print('Alınan veri: $data');
    });
  }

  // Kaynakları temizleme
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _deviceStreamController.close();
  }
}
