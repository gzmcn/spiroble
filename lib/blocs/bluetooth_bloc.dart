import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// Bluetooth durumu için state tanımlıyoruz.
abstract class BluetoothState {}

class BluetoothInitial extends BluetoothState {}

class BluetoothConnected extends BluetoothState {
  final DiscoveredDevice device;
  BluetoothConnected(this.device);
}

class BluetoothDisconnected extends BluetoothState {}

class BluetoothError extends BluetoothState {
  final String message;
  BluetoothError(this.message);
}

// Bluetooth durumu değiştirmek için Event tanımlıyoruz.
abstract class BluetoothEvent {}

class BluetoothConnect extends BluetoothEvent {
  final DiscoveredDevice device;
  BluetoothConnect(this.device);
}

class BluetoothDisconnect extends BluetoothEvent {}

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription? _connectionSubscription;
  DiscoveredDevice? _connectedDevice; // Bağlantılı cihazı saklamak için değişken

  BluetoothBloc() : super(BluetoothInitial());

  @override
  Stream<BluetoothState> mapEventToState(BluetoothEvent event) async* {
    if (event is BluetoothConnect) {
      yield* _mapBluetoothConnectToState(event.device);
    } else if (event is BluetoothDisconnect) {
      yield* _mapBluetoothDisconnectToState();
    }
  }

  Stream<BluetoothState> _mapBluetoothConnectToState(DiscoveredDevice device) async* {
    try {
      _connectionSubscription = _ble.connectToDevice(id: device.id).listen(
        (connectionState) {
          if (connectionState.connectionState == DeviceConnectionState.connected) {
            // Bağlantı başarılı
            _connectedDevice = device; // Bağlantılı cihazı sakla
            add(BluetoothConnect(device)); // Cihaz bağlandıktan sonra event gönder
          } else if (connectionState.connectionState == DeviceConnectionState.disconnected) {
            add(BluetoothDisconnect()); // Bağlantı kesildiğinde event gönder
          }
        },
        onError: (e) {
          add(BluetoothError('Bluetooth bağlantı hatası: $e') as BluetoothEvent);
        },
      );
      yield BluetoothConnected(device); // Bağlantı sağlandığında state'i güncelle
    } catch (e) {
      yield BluetoothError('Bluetooth bağlantısı sırasında hata: $e');
    }
  }

  Stream<BluetoothState> _mapBluetoothDisconnectToState() async* {
    await _connectionSubscription?.cancel(); // Bağlantıyı iptal et
    _connectedDevice = null; // Cihaz bağlantısı kesildiğinde cihazı null yap
    yield BluetoothDisconnected(); // Bağlantı kesildiğinde state'i güncelle
  }

  @override
  Future<void> close() {
    _connectionSubscription?.cancel(); // BLoC kapanırken bağlantıyı iptal et
    return super.close();
  }
}
