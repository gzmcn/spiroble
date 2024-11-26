import 'package:flutter/material.dart';
import 'package:spiroble/bluetooth/ble_controller.dart';
import 'package:spiroble/screens/spiroScreen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreen();
}

class _TestScreen extends State<TestScreen>
    with SingleTickerProviderStateMixin {
  late final BleController _bleController; 
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _bleController = BleController();
    _bleController.initialize();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Sonsuz döngü ve geri sarma

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bleController.dispose();
    _controller.dispose();
    super.dispose();
  }

   Future<void> sendChar0() async {
    await _bleController.sendChar0(); // char 0'ı gönder
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
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value, // Büyüklük animasyonu
                child: ElevatedButton(
                  onPressed: () async {
                    await sendChar0();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => SpiroScreen(),
                    ));
                    print("Teste Başla butonuna tıklandı.");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    padding: const EdgeInsets.all(70), // Daha büyük boyut
                    shape: const CircleBorder(), // Tamamen yuvarlak buton
                    elevation: 10, // Hafif gölge efekti
                  ),
                  child: const Text(
                    "Teste Basla",
                    style: TextStyle(
                      fontSize: 28, // Daha büyük font boyutu
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TestScreen(),
  ));
}
