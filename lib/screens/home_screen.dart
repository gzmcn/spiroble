import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:spiroble/screens/testScreen.dart';
import 'package:spiroble/screens/asistanScreen.dart'; // Asistan ekranını import edin

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
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
                "Bugün harika bir gün olacak!",
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
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // Buton boyutu
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(30), // Yuvarlatılmış köşeler
                  ), // Buton metin rengi
                  elevation: 8, // Gölge efekti
                ),
                child: Text(
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
      // Sağ alt köşeye FloatingActionButton ekliyoruz
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AsistanScreen(), // Asistan ekranına yönlendirme
          ));
        },
        backgroundColor: Colors.white,
        child: const Icon(Icons.assistant, color: Colors.blue), // Asistan logosu
      ),
    );
  }
}
