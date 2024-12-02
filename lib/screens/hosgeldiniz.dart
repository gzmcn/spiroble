import 'package:flutter/material.dart';
import 'package:spiroble/screens/LoginScreen.dart';
import 'package:spiroble/screens/registerScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Base background color
      body: Stack(
        children: [
          // Upper Section with Background Color or Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff51A8FF), // Example color
                    Color(0xff123456), // Another color for gradient
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Lower Section with Border Radius
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity, // Make it full width
              height:
                  MediaQuery.of(context).size.height * 0.4, // Adjusted height
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
                    // Your lower section widgets go here
                    Text(
                      'SPIROMATIK\'E',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.red[400],
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Hoşgeldiniz',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.lightBlue[600],
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
                                MaterialPageRoute(
                                    builder: (ctx) => LoginScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFFFFF),
                            foregroundColor: Color(0xff51A8FF),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Giriş Yap',
                            textAlign: TextAlign.center, // ✅ Correct placement
                            style: TextStyle(
                              color: Colors.lightBlue[600],
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (ctx) => RegisterScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFFFFF),
                            foregroundColor: Color(0xff51A8FF),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 20),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Kayıt Ol',
                            textAlign: TextAlign.center, // ✅ Correct placement
                            style: TextStyle(
                              color: Colors.lightBlue[600],
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

          // Positioned BouncingHeart at the Middle of the Upper Section
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25, // Adjust as needed
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

class _BouncingHeartState extends State<BouncingHeart>
    with SingleTickerProviderStateMixin {
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
