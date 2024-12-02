import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spiroble/screens/InfoScreen1.dart'; // İlk bilgilendirme ekranını import edin

class StartSplashScreen extends StatefulWidget {
  const StartSplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<StartSplashScreen> {
  @override
  void initState() {
    super.initState();
    // 2 saniye sonra InfoScreen1'e geçiş
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InfoScreen1()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(110), // Yuvarlak köşe radius
          child: SvgPicture.asset(
            'assets/spiroicons.svg',  // Yeni ikon dosyasının yolu
            width: 225,  // İkon boyutu
            height: 225,  // İkon boyutu
          ),
        ),
      ),
    );
  }
}
