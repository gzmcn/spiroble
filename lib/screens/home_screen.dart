import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spiroble/screens/LoginScreen.dart';
import 'package:spiroble/screens/testScreen.dart';
import 'package:spiroble/screens/asistanScreen.dart'; // Asistan ekranını import edin
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
    print(BluetoothConnectionManager().connectedDeviceId.toString());
    if (BluetoothConnectionManager().checkConnection()) {
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFFFFFFF), Color(0xFF3A2A6B)],
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
                "Bugün harika bir gün olacak!",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  backgroundColor: const Color.fromARGB(255, 251, 251, 251),
                  padding: EdgeInsets.symmetric(
                      horizontal: 28, vertical: 14), // Buton boyutu
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(30), // Yuvarlatılmış köşeler
                  ), // Buton metin rengi
                  elevation: 8, // Gölge efekti
                ),
                child: Text(
                  "Teste Başla",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Sağ alt köşeye FloatingActionButton ekliyoruz
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                AsistanScreen(), // Asistan ekranına yönlendirme
          ));
        },
        backgroundColor: Colors.white,
        child:
        const Icon(Icons.assistant, color: Colors.blue), // Asistan logosu
      ),
    );
  }
}
