import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spiroble/Screens/LoginScreen.dart';
import 'package:spiroble/Screens/user_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Başarılı!'),
          content:
              Text('Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tamam'),
            ),
          ],
        ),
      );
    } catch (error) {
      print('Reset email error: ${error.toString()}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Hata'),
          content:
              Text('Şifre sıfırlama işlemi başarısız. Lütfen tekrar deneyin.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tamam'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Şifre Sıfırla'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'E-Mail',
                prefixIcon: Icon(Icons.mail),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendResetEmail,
              child: Text('Şifre Sıfırlama E-postası Gönder'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => {
                if (_firebaseAuth.currentUser?.uid == null)
                  {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (ctx) => LoginScreen()),
                    )
                  }
                else
                  {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (ctx) => ProfileScreen()),
                    )
                  }
              },
              child: Text("Vazgeç"),
            )
          ],
        ),
      ),
    );
  }
}
