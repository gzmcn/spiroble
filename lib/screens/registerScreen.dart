import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spiroble/screens/InfoScreen1.dart';
import 'package:spiroble/screens/LoginScreen.dart';
import 'package:spiroble/widgets/input_fields.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _database = FirebaseDatabase.instance.ref();

  // Controller'lar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adController = TextEditingController();
  final TextEditingController _soyadController = TextEditingController();
  final TextEditingController _dogumTarihiController = TextEditingController();
  final TextEditingController _kiloController = TextEditingController();
  final TextEditingController _boyController = TextEditingController();

  // Değişkenler
  String _cinsiyet = 'Cinsiyet Seçin';
  String _uyruk = 'Uyruk Seçin';

  bool _isLoading = false;

  // Kullanıcı kaydetme fonksiyonu
  void _register(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Authentication işlemi
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Kullanıcı verilerini Firestore'a kaydetme
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'ad': _adController.text.trim(),
        'soyad': _soyadController.text.trim(),
        'dogumTarihi': _dogumTarihiController.text.trim(),
        'kilo': _kiloController.text.trim(),
        'boy': _boyController.text.trim(),
        'cinsiyet': _cinsiyet,
        'uyruk': _uyruk,
        'email': _emailController.text.trim(),
      });

      // Başarılı kayıt sonrası yönlendirme
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => InfoScreen1()), // İlk bilgilendirme ekranı
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt işlemi başarısız: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                // Ad ve Soyad için Column kullanıyoruz
                Column(
                  children: [
                    InputFields(
                      controller: _adController,
                      placeholder: 'Ad',
                      icon: Icon(Icons.person_2_rounded),
                    ),
                    SizedBox(height: 10),
                    InputFields(
                      controller: _soyadController,
                      placeholder: 'Soyad',
                      icon: Icon(Icons.person),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: InputFields(
                      controller: _dogumTarihiController,
                      placeholder: 'Doğum Tarihi',
                      icon: Icon(Icons.calendar_today),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // Boy ve Kilo için Row kullanıyoruz
                Row(
                  children: [
                    Expanded(
                      child: InputFields(
                        controller: _kiloController,
                        placeholder: 'Kilo (kg)',
                        icon: Icon(Icons.line_weight),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: InputFields(
                        controller: _boyController,
                        placeholder: 'Boy (cm)',
                        icon: Icon(Icons.height),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // Cinsiyet ve Uyruk için Row kullanıyoruz
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButton<String>(
                          value: _cinsiyet,
                          isExpanded: true,
                          onChanged: (value) => setState(() {
                            _cinsiyet = value!;
                          }),
                          items: ['Cinsiyet Seçin', 'Erkek', 'Kadın']
                              .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButton<String>(
                          value: _uyruk,
                          isExpanded: true,
                          onChanged: (value) => setState(() {
                            _uyruk = value!;
                          }),
                          items: [
                            'Uyruk Seçin',
                            'Beyaz Tenli',
                            'Afro-Amerikalı',
                            'Kuzeydoğu-Asyalı',
                            'Güneydoğu-Asyalı',
                            'Diğer'
                          ]
                              .map((value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // E-posta ve Şifre alanları
                InputFields(
                  controller: _emailController,
                  placeholder: 'E-posta',
                  icon: Icon(Icons.email),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 15),
                InputFields(
                  controller: _passwordController,
                  placeholder: 'Şifre',
                  icon: Icon(Icons.lock),
                  secureTextEntry: true,
                ),
                SizedBox(height: 65),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _register(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 34, vertical: 18),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                    'Kayıt Ol',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (ctx) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Zaten hesabınız var mı?',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tarih seçme fonksiyonu
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dogumTarihiController.text = '${picked.toLocal()}'.split(' ')[0];
      });
    }
  }
}
