import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spiroble/screens/InfoScreen1.dart';
import 'package:spiroble/screens/StartSplashScreen.dart';
import 'package:spiroble/screens/appScreen.dart';
import 'package:spiroble/screens/bluetoothScreen.dart';
import 'package:spiroble/screens/home_screen.dart';
import 'package:spiroble/screens/registerScreen.dart';
import 'package:spiroble/widgets/input_fields.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final _firebase = FirebaseAuth.instance;

  // Giriş yapma işlemi
  Future<void> _handleSignIn() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      final user = await _firebase.signInWithEmailAndPassword(
        email: email,
        password: password,
      ); // Firebase ile giriş işlemi
      print('User signed in: $user');

      // Başarılı giriş sonrası HomeScreen'e geçiş yap
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => InfoScreen1()),
      );
    } catch (error) {
      print('Sign-in error: ${error.toString()}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Hata'),
          content: Text(
              'Giriş işlemi başarısız. Lütfen bilgilerinizi kontrol edin.'),
          actions: <Widget>[
            TextButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Email Input Field
            InputFields(
              controller: _emailController,
              placeholder: 'E-Mail',
              icon: Icon(Icons.mail, color: Colors.black),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            // Password Input Field
            InputFields(
              controller: _passwordController,
              placeholder: 'Şifre',
              icon: Icon(Icons.lock, color: Colors.black),
              secureTextEntry: !_isPasswordVisible,
              onTapSuffixIcon: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
            SizedBox(height: 45),
            // Sign In Button
            ElevatedButton(
              onPressed: _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA0BAFD),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16), // Butonun iç boşlukları
                textStyle: const TextStyle(
                  fontSize: 15, // Yazı boyutu
                  fontWeight: FontWeight.bold, // Yazı kalınlığı
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(30), // Köşeleri yuvarlak yapmak
                ),
              ),
              child: Text('Giriş Yap'),
            ),

            // Register Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => RegisterScreen()));
              },
              child: const Text('Üye ol'),
            ),
          ],
        ),
      ),
    );
  }
}
