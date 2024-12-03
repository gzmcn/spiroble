import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spiroble/screens/hosgeldiniz.dart';  // Make sure WelcomeScreen is imported

class StartSplashScreen extends StatefulWidget {
  const StartSplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<StartSplashScreen> {
  @override
  void initState() {
    super.initState();
    // 3 seconds after splash screen, navigate to WelcomeScreen
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(110), // Round corner radius
          child: SvgPicture.asset(
            'assets/spiroicons.svg',  // Icon asset path
            width: 225,  // Icon size
            height: 225,  // Icon size
          ),
        ),
      ),
    );
  }
}
