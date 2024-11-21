import 'package:flutter/material.dart';

class ConnectionWaitingScreen extends StatelessWidget {
  const ConnectionWaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(), // Yükleme göstergesi
            SizedBox(height: 20), // Boşluk
            Text(
              'Bağlantı Bekleniyor...',
              style: TextStyle(fontSize: 18),
            ), // Bekleme mesajı
          ],
        ),
      ),
    );
  }
}
