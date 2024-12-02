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

  // Cinsiyet ve uyruk seçenekleri
  String _cinsiyet = 'Cinsiyet Seçin';
  String _uyruk = 'Uyruk Seçin';

  bool _isLoading = false;

  // Email doğrulama fonksiyonu
  bool isValidEmail(String email) {
    final emailPattern = r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$";
    return RegExp(emailPattern).hasMatch(email);
  }

  // Doğum tarihi seçimi
  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selectedDate != null) {
      setState(() {
        _dogumTarihiController.text =
            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}";
      });
    }
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

    List<String> errors = [];

    // Form validasyonu
    if (ad.isEmpty) errors.add('Ad alanı boş bırakılamaz.');
    if (soyad.isEmpty) errors.add('Soyad alanı boş bırakılamaz.');
    if (!isValidEmail(email)) errors.add('Geçerli bir e-posta adresi giriniz.');
    if (password.length < 6) errors.add('Şifre en az 6 karakter olmalıdır.');
    if (double.tryParse(boy) == null || double.parse(boy) <= 0) {
      errors.add('Geçerli bir boy giriniz.');
    }
    if (double.tryParse(boy)! >= 250) {
      errors.add('lütfen geçerli bir boy giriniz');
    }
    if (double.tryParse(kilo) == null || double.parse(kilo) <= 0) {
      errors.add('Geçerli bir kilo giriniz.');
    }
    if (_cinsiyet == 'Cinsiyet Seçin') errors.add('Cinsiyet seçiniz.');
    if (_uyruk == 'Uyruk Seçin') errors.add('Uyruk seçiniz.');

    // Hataları göster
    if (errors.isNotEmpty) {
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Firebase Authentication ile kayıt
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Firestore'a kullanıcı verilerini kaydetme
      await _database.child('users').child(userCredential.user!.uid).set({
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
        MaterialPageRoute(builder: (context) => InfoScreen1()),
      );
    } catch (e) {
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
                Row(
                  children: [
                    Expanded(
                      child: InputFields(
                        controller: _adController,
                        placeholder: 'Ad',
                        icon: Icon(Icons.person_2_rounded),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: InputFields(
                        controller: _soyadController,
                        placeholder: 'Soyad',
                        icon: Icon(Icons.person),
                      ),
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
                InputFields(
                  controller: _kiloController,
                  placeholder: 'Kilo (kg)',
                  icon: Icon(Icons.line_weight),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 15),
                InputFields(
                  controller: _boyController,
                  placeholder: 'Boy (cm)',
                  icon: Icon(Icons.height),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 15),
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _register(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 15,
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
                    'Zaten hesabınız var mı',
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
}
