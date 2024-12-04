import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spiroble/screens/hosgeldiniz.dart'; // Hoşgeldiniz ekranı
import 'package:spiroble/screens/home_screen.dart'; // HomeScreen ekranı
import 'package:flutter_svg/flutter_svg.dart'; // SVG desteğini dahil ettik

class StartSplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Splash ekran süresi ve geçiş
    Future.delayed(Duration(seconds: 0), () {
      // Kullanıcı giriş kontrolü
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Eğer kullanıcı giriş yapmışsa, HomeScreen'e geçiş
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => HomeScreen()),
        );
      } else {
        // Eğer kullanıcı giriş yapmamışsa, WelcomeScreen'e geçiş
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => WelcomeScreen()),
        );
      }
    });

    return Scaffold(
      body: Center(
        child: ClipOval(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), // Köşe yuvarlatma
            ),
            child: SvgPicture.asset(
              'assets/spiroiconnew.svg', // SVG dosyasının yolu
              width: 150,  // Genişlik
              height: 150, // Yükseklik
            ),
          ),
        ),
      ),
    );
  }
}