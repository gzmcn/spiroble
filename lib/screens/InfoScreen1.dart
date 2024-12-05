import 'package:flutter/material.dart';
import 'package:spiroble/screens/InfoScreen2.dart';
import 'package:spiroble/screens/appScreen.dart';
import 'package:spiroble/screens/home_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoScreen1 extends StatelessWidget {
  const InfoScreen1({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient arka plan
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFF3A2A6B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.6, 1], // Geçiş en alttan başlasın
              ),
            ),
          ),
          // Breath SVG ikonu
          Positioned(
            top: 140, // İkonun üst kısımdan ne kadar uzak olacağı
            left: 40,
            right: 0,
            child: SvgPicture.asset(
              'assets/spirometer.svg', // breath.svg dosyasının yolu
              width: 125.0,
              height: 125.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // İkon ve yazı arasına daha fazla boşluk eklemek için SizedBox
                const SizedBox(height: 220), // Bu satır ile boşluğu artırdık
                Text(
                  "Spirometri akciğer kapasitesini ve solunum fonksiyonlarını ölçmek için kullanılan bir cihazdır. Solunum hastalıklarının tanı ve takibinde yaygın olarak kullanılır.",
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
                      // Geç butonu ile 2. sayfaya geçiş
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InfoScreen2(),
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

