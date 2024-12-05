import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spiroble/screens/appScreen.dart';
import 'package:spiroble/screens/hosgeldiniz.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StartSplashScreen extends StatefulWidget {
  @override
  _StartSplashScreenState createState() => _StartSplashScreenState();
}

class _StartSplashScreenState extends State<StartSplashScreen> {
  bool _isTransitioning = false;

  @override
  Widget build(BuildContext context) {
    if (!_isTransitioning) {
      Future.delayed(Duration(seconds: 3), () async {
        setState(() {
          _isTransitioning = true;
        });

        User? user = FirebaseAuth.instance.currentUser;

        await Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
            user != null ? AppScreen() : WelcomeScreen(), // Correct class name
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);
              return FadeTransition(opacity: fadeAnimation, child: child);
            },
            transitionDuration: Duration(seconds: 1),
          ),
        );
      });
    }

    return Scaffold(
      body: Center(
        child: ClipOval(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
            ),
            child: SvgPicture.asset(
              'assets/spiroiconnew.svg',
              width: 180,
              height: 180,
            ),
          ),
        ),
      ),
    );
  }
}
