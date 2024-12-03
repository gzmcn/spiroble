import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spiroble/Bluetooth_Services/bluetooth_constant.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'package:spiroble/screens/MatematikSayfa.dart';
import 'package:spiroble/screens/TestDetailScreen.dart';
import 'package:provider/provider.dart';

class BluetoothScreen extends StatefulWidget {
  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  late BluetoothConnectionManager _bleManager;

  @override
  void initState() {
    super.initState();
    _bleManager =
        Provider.of<BluetoothConnectionManager>(context, listen: false);
    _requestPermissions();
    _bleManager.startScan();
    _loadConnectionState();
  }

  // Bluetooth izinlerini istemek için
  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
  }

  final List<double> akisHizi = [];
  final List<double> toplamVolum = [];
  final List<double> miliSaniye = [];
  // Bluetooth bağlantı durumunu yükle
  Future<void> _loadConnectionState() async {
    await _bleManager.loadConnectionState();
    Future.delayed(Duration(seconds: 1), () {
      print("Bağlantı durumu: ${_bleManager.checkConnection()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Cihazlar'),
      ),
      body: StreamBuilder<List<DiscoveredDevice>>(
        stream: _bleManager.DiscoveredDeviceStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          final devices = snapshot.data ?? [];
          if (devices.isEmpty) {
            return const Center(child: Text('Cihaz bulunamadı.'));
          }
          return ListView.builder(
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ListTile(
                title: Text(device.name.isNotEmpty
                    ? device.name
                    : 'Cihaz: ${device.id.substring(0, 5)}'),
                subtitle: Text(
                    'ID: ${device.id} - RSSI: ${device.rssi ?? "Bilinmiyor"}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    if (_bleManager.checkConnection()) {
                      _bleManager.disconnectToDevice(device.id);
                    } else {
                      _bleManager.connectToDevice(device.id);
                      print("bağlı");

                      String serviceUuid = BleUuids.Uuid3Services;
                      String characteristicUuid = BleUuids.Uuid3Characteristic;
                      _bleManager.sendChar1(
                          serviceUuid, characteristicUuid, device.id);

                      // Verilerin alınıp toplandığı süreyi belirtmek için
                      List<double> akisHizi = [];
                      List<double> toplamVolum = [];
                      List<double> miliSaniye = [];

                      // Notify as doubles and collect data for 10 seconds
                      var subscription =
                          _bleManager.notifyAsDoubles(device.id).listen(
                        (doubles) {
                          akisHizi.add(doubles[0]);
                          toplamVolum.add(doubles[1]);
                          miliSaniye.add(doubles[2]);

                          print(
                              "Bildirim alındı: ${doubles[0]}, ${doubles[1]}, ${doubles[2]}");
                        },
                        onError: (error) {
                          print("Hata: $error");
                        },
                      );

                      // Otomatik olarak 10 saniye sonra verilerin toplanmasını durdur
                      Future.delayed(Duration(seconds: 10), () {
                        subscription.cancel();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (ctx) => MatematikSayfasi(
                                akisHizi: akisHizi,
                                toplamVolum: toplamVolum,
                                miliSaniye: miliSaniye)));

                        print("Veri toplama tamamlandı.");
                        print("akisHizi: $akisHizi");
                        print("toplamVolum: $toplamVolum");
                        print("miliSaniye: $miliSaniye");
                      });
                    }
                  },
                  child: Text(
                    _bleManager.checkConnection() ? 'Bağlantıyı Kes' : 'Bağlan',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
