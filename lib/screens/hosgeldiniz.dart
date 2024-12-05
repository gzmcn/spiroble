import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spiroble/screens/appScreen.dart';
import 'package:spiroble/screens/LoginScreen.dart';
import 'package:spiroble/screens/registerScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _checkUserSession(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Eğer kullanıcı giriş yapmışsa, AppScreen'e geçiş
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => AppScreen()),
      );
    }
    // Eğer kullanıcı giriş yapmamışsa, InfoScreen1 yönlendirmesini kaldırıyoruz
    // Kullanıcı doğrudan giriş yapabilir ya da kayıt olabilir
  }

  @override
  Widget build(BuildContext context) {
    // Kullanıcı giriş durumunu kontrol etme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserSession(context);
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Arka planda gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3A2A6B),
                    Color(0xff123456),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Alt kısmı beyaz alan, butonlar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SPIROMATIK\'E',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A2A6B),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Hoşgeldiniz',
                      style: TextStyle(
                        fontSize: 24,
                        color: Color(0xFF3A2A6B),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (ctx) => LoginScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFFFFF),
                            foregroundColor: Color(0xff51A8FF),
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Giriş Yap',
                            style: TextStyle(
                              color: Color(0xFF3A2A6B),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (ctx) => RegisterScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFFFFF),
                            foregroundColor: Color(0xff51A8FF),
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Kayıt Ol',
                            style: TextStyle(
                              color: Color(0xFF3A2A6B),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: Center(
              child: BouncingHeart(),
            ),
          ),
        ],
      ),
    );
  }
}

class BouncingHeart extends StatefulWidget {
  @override
  _BouncingHeartState createState() => _BouncingHeartState();
}

class _BouncingHeartState extends State<BouncingHeart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Icon(
        Icons.favorite,
        color: Colors.red,
        size: 170,
      ),
    );
  }
}
