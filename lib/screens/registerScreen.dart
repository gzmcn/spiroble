import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spiroble/screens/home_screen.dart';

class RegisterScreen extends StatelessWidget {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Controller'lar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _dogumTarihiController = TextEditingController();
  final TextEditingController _kiloController = TextEditingController();
  final TextEditingController _boyController = TextEditingController();

  // Cinsiyet ve uyruk seçenekleri
  String _cinsiyet = 'Cinsiyet Seçin';
  String _uyruk = 'Uyruk Seçin';

  // Hata kontrolü
  String? _errorMessage;
  bool _isLoading = false;

  // Email doğrulama fonksiyonu
  bool isValidEmail(String email) {
    final emailPattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    final regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  // Kayıt işlemi
  Future<void> _register(BuildContext context) async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String ad = _adController.text.trim();
    final String soyad = _soyadController.text.trim();
    final String dogumTarihi = _dogumTarihiController.text.trim();
    final String kilo = _kiloController.text.trim();
    final String boy = _boyController.text.trim();

    // Hatalar için liste
    List<String> errors = [];

    // Form validasyonu
    if (ad.isEmpty) errors.add('Ad alanı boş bırakılamaz');
    if (soyad.isEmpty) errors.add('Soyad alanı boş bırakılamaz');
    if (password.length < 6) errors.add('Şifre en az 6 haneden oluşmalıdır');
    if (!isValidEmail(email)) errors.add('Geçerli bir email adresi giriniz');
    if (double.tryParse(boy) == null || double.parse(boy) <= 0)
      errors.add('Geçerli bir boy giriniz');
    if (double.tryParse(kilo) == null || double.parse(kilo) <= 0)
      errors.add('Geçerli bir kilo giriniz');
    if (_cinsiyet == 'Cinsiyet Seçin') errors.add('Cinsiyet seçiniz');
    if (_uyruk == 'Uyruk Seçin') errors.add('Uyruk seçiniz');

    if (errors.isNotEmpty) {
      // Hata mesajlarını kullanıcıya göster
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Hata'),
          content: Text(errors.join('\n')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tamam'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      // Firebase Authentication ile kullanıcı kaydı
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'a kullanıcı verilerini kaydetme
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'ad': ad,
        'soyad': soyad,
        'dogumTarihi': dogumTarihi,
        'kilo': double.parse(kilo),
        'boy': double.parse(boy),
        'cinsiyet': _cinsiyet,
        'uyruk': _uyruk,
      });

      // Kayıt başarılı
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      // Kayıt sırasında hata mesajı göster
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Hata'),
          content: Text('Bir hata oluştu: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
      appBar: AppBar(title: Text('Kayıt Ol')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _adController,
              decoration: InputDecoration(labelText: 'Ad'),
            ),
            TextField(
              controller: _soyadController,
              decoration: InputDecoration(labelText: 'Soyad'),
            ),
            TextField(
              controller: _dogumTarihiController,
              decoration:
                  InputDecoration(labelText: 'Doğum Tarihi (YYYY-MM-DD)'),
            ),
            TextField(
              controller: _kiloController,
              decoration: InputDecoration(labelText: 'Kilo (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _boyController,
              decoration: InputDecoration(labelText: 'Boy (cm)'),
              keyboardType: TextInputType.number,
            ),
            // Cinsiyet Seçimi
            DropdownButton<String>(
              value: _cinsiyet,
              onChanged: (String? newValue) {
                // Cinsiyet seçim işlemi
                _cinsiyet = newValue!;
              },
              items: <String>['Cinsiyet Seçin', 'Erkek', 'Kadın']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // Uyruk Seçimi
            DropdownButton<String>(
              value: _uyruk,
              onChanged: (String? newValue) {
                // Uyruk seçim işlemi
                _uyruk = newValue!;
              },
              items: <String>[
                'Uyruk Seçin',
                'Beyaz Tenli',
                'Afro-Amerikalı',
                'Kuzeydoğu-Asyalı',
                'Güneydoğu-Asyalı',
                'Diğer'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Şifre'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _register(context),
              child:
                  _isLoading ? CircularProgressIndicator() : Text('Kayıt Ol'),
            ),
          ],
        ),
      ),
    );
  }
}
