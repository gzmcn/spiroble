import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spiroble/screens/appScreen.dart';
import 'package:spiroble/screens/InfoScreen3.dart';

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
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Color(0xFF3A2A6B)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.3, 1], // Geçiş sayfa ortasında başlasın
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
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                SizedBox(height: 100), // İkon ile yazı arası
                Text(
                  "Spirometri testi kişinin nefes alıp verme kapasitesini değerlendirir. KOAH gibi hastalıkların teşhisinde önemli rol oynar.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
                      // Geç butonu ile sağa kayarak 3. sayfaya geçiş
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const InfoScreen3(),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            // Sayfa geçişi sırasında sağa kayma animasyonu
                            const begin = Offset(1.0, 0.0); // Sağdan giriş
                            const end = Offset.zero;
                            const curve = Curves.easeInOut;

                            var tween = Tween(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var offsetAnimation = animation.drive(tween);

                            return SlideTransition(
                                position: offsetAnimation, child: child);
                          },
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
