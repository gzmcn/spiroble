import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spiroble/screens/InfoScreen3.dart';
import 'package:spiroble/screens/appScreen.dart';
import 'package:spiroble/screens/home_screen.dart';

class InfoScreen2 extends StatelessWidget {
  const InfoScreen2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient arka plan
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade500],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1], // Geçiş sayfa ortasında başlasın
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SVG ikonu kullanma
                SvgPicture.asset(
                  'assets/lungs.svg', // SVG dosyasının yolu
                  width: 130.0,
                  height: 130.0,
                ),
                SizedBox(height: 100), // İkon ile yazı arası
                Text(
                  "Spirometri testi kişinin nefes alıp verme kapasitesini değerlendirir. KOAH gibi hastalıkların teşhisinde önemli rol oynar.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Atla butonu ile HomeScreen'e geçiş
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Atla"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Geç butonu ile 3. sayfaya geçiş
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfoScreen3(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text("Geç"),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
