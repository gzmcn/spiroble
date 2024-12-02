import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';

// Test widget'ı
class TestProviderWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // BluetoothConnectionManager'ı provider'dan alıyoruz
    final bluetoothManager = ref.watch(bluetoothConnectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Provider Test")),
      body: Center(
        child: Text(
          bluetoothManager.connectedDeviceId ?? "No Device Connected",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
