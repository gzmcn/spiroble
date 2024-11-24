import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:spiroble/screens/LoginScreen.dart';
import 'package:spiroble/widgets/input_fields.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool loading = true;
  Map<String, String> userData = {
    'ad': '',
    'soyad': '',
    'dogumTarihi': '',
    'kilo': '',
    'boy': '',
    'cinsiyet': '',
    'uyruk': '',
    'email': '',
    'password': '',
  };

  final TextEditingController adController = TextEditingController();
  final TextEditingController soyadController = TextEditingController();
  final TextEditingController dogumTarihiController = TextEditingController();
  final TextEditingController kiloController = TextEditingController();
  final TextEditingController boyController = TextEditingController();
  final TextEditingController uyrukController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        final snapshot = await database.child('users/${currentUser.uid}').get();
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);

          // Veri türü uyumsuzluğunu düzeltmek için 'toString' kullanıyoruz
          setState(() {
            adController.text = data['ad'] ?? '';
            soyadController.text = data['soyad'] ?? '';
            dogumTarihiController.text = data['dogumTarihi'] ?? '';

            // 'int' değerleri 'String'e dönüştürüyoruz
            kiloController.text = data['kilo']?.toString() ?? '';
            boyController.text = data['boy']?.toString() ?? '';
            uyrukController.text = data['uyruk'] ?? '';
            emailController.text = currentUser.email ?? '';
            loading = false;
          });
        }
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<void> saveUserData() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        await database.child('users/${currentUser.uid}').update({
          'ad': adController.text,
          'soyad': soyadController.text,
          'dogumTarihi': dogumTarihiController.text,
          'kilo': kiloController.text,
          'boy': boyController.text,
          'uyruk': uyrukController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profil başarıyla güncellendi!')));
      }
    } catch (error) {
      print('Error updating user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text('Profilim')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            InputFields(
              controller: adController,
              placeholder: 'Ad',
              icon: Icons.person,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: soyadController,
              placeholder: 'Soyad',
              icon: Icons.person_outline,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: dogumTarihiController,
              placeholder: 'Doğum Tarihi (YYYY-MM-DD)',
              icon: Icons.calendar_today,
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: kiloController,
              placeholder: 'Kilo (kg)',
              icon: Icons.monitor_weight,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: boyController,
              placeholder: 'Boy (cm)',
              icon: Icons.height,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: uyrukController,
              placeholder: 'Uyruk',
              icon: Icons.flag,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: emailController,
              placeholder: 'E-posta',
              icon: Icons.email,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: passwordController,
              placeholder: 'Şifre',
              icon: Icons.lock,
              secureTextEntry: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: saveUserData,
              child: Text('Kaydet'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await auth.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (ctx) => LoginScreen()),
                );
              },
              child: Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }
}
