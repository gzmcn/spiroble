import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'package:spiroble/screens/testScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // BluetoothConnectionManager'ı kontrol et
    final bluetoothManager =
        Provider.of<BluetoothConnectionManager>(context, listen: false);

    // Bağlantı durumunu kontrol et
    print(bluetoothManager.connectedDeviceId.toString());
    if (bluetoothManager.checkConnection()) {
      print('connected');
    } else {
      print('disconnected');
    }
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "Günaydın!";
    } else if (hour < 18) {
      return "İyi günler!";
    } else {
      return "İyi akşamlar!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BluetoothConnectionManager>(
      builder: (context, bluetoothManager, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFA0BAFD), Colors.deepOrange.shade700],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getGreetingMessage(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bluetooth bağlantı durumunu göstermek
                  Text(
                    bluetoothManager.checkConnection()
                        ? "Cihaza bağlı: ${bluetoothManager.connectedDeviceId}"
                        : "Cihaza bağlı değil",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Test widget'ına geçiş yapma
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            TestScreen(), // Test ekranına geçiş
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      backgroundColor: const Color.fromARGB(255, 251, 251, 251),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: const Text(
                      "Teste Başla",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
