import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:spiroble/screens/testResultsScreen.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Access BluetoothConnectionManager from the provider
    final bluetoothManager = Provider.of<BluetoothConnectionManager>(context, listen: false);

    // Checking the connection status
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
      return "günaydın!";
    } else if (hour < 18) {
      return "iyi günler!";
    } else {
      return "iyi akşamlar!";
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
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    bluetoothManager.checkConnection()
                        ? "Cihaza bağlı: ${bluetoothManager.connectedDeviceId}"
                        : "Cihaza bağlı değil",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => TestScreen(),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                      backgroundColor: const Color.fromARGB(255, 251, 251, 251),
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                    child: Text(
                      "Teste Basla",
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
