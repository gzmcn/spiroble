import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:spiroble/function/bla.dart';
import 'package:spiroble/screens/LoginScreen.dart';
import 'package:spiroble/widgets/CircularProgressBar.dart';
import 'package:spiroble/widgets/input_fields.dart';
import 'package:fancy_button_flutter/fancy_button_flutter.dart';

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
  final FEV1Calculator fev1Calculator = FEV1Calculator();
  double? _fev1Value;
  String? _fev1Error;
  bool _isLoadingFEV1 = false;



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
    _fetchFEV1(10); // Fetch FEV1 on initialization
  }

  // Example async function to calculate FEV1
Future<void> _fetchFEV1(double age) async {
  setState(() {
    _isLoadingFEV1 = true;
    _fev1Error = null;
  });

  try {
    // Use class instance instead of creating new one
    print('Starting FEV1 calculation...'); // Debug print
    
    // Load data and print confirmation
    await fev1Calculator.loadIkincitablodata();
    print('Ikincitablo data loaded');
    
    await fev1Calculator.loadCSVData();
    print('CSV data loaded');

    // Print calculation parameters
    print('Calculating with parameters:');
    print('Index: 0');
    print('Age: 5.5');
    print('Height: 170.0');
    print('IsMale: true');

    double result = await fev1Calculator.calculateVariable(0, 5.5, 170.0, true);
    print('Calculated result: $result'); // Debug print

    setState(() {
      _fev1Value = result;
      _isLoadingFEV1 = false;
    });
  } catch (e) {
    print('Error during calculation: $e'); // Debug print
    setState(() {
      _fev1Error = e.toString();
      _isLoadingFEV1 = false;
    });
  }
}

  Future<void> fetchUserData() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        final snapshot =
            await database.child('users/${currentUser.uid}').get();
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
    double age = 12.7;

    try {
      // Corrected method call using existing fev1Calculator instance
      double fev1 =
          await fev1Calculator.calculateVariable(0, age, 170, true);

      // Sonucu yazdırıyoruz
      print('FEV1 for age $age is: $fev1');
    } catch (e) {
      print('Error calculating FEV1: $e');
      setState(() {
        _fev1Error = 'Error calculating FEV1: $e';
      });
      // Optionally, show a SnackBar to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: FEV1 hesaplanamadı.')),
      );
      return; // Exit the function if calculation fails
    }

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
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil güncellenirken hata oluştu.')));
    }
  }

  Future<String> fetchUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Reference to the users' data
      final database = FirebaseDatabase.instance.ref();
      final snapshot =
          await database.child('users/${currentUser.uid}').get();

      // Check if data exists
      if (snapshot.exists) {
        final userName = snapshot.child('ad').value;

        // Safely return the username as a string or a fallback if null
        return userName != null ? userName.toString() : "No name available";
      } else {
        print("No user data available");
        return "No name available";
      }
    } else {
      print("No current user found.");
      return "No name available";
    }
  }

  // Added _calculateProgress method
  double _calculateProgress(double fev1Value) {
    double maxValue = 55.0; // Define based on your application's logic
    if (maxValue == 0) return 0;
    double progress = (fev1Value / maxValue) * 100;
    return progress.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Profilim',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Updated Profile Section
            Container(
              padding: EdgeInsets.all(16),
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFA0BAFD),
                    Colors.deepOrange.shade700
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20), // Spacing between avatar and text
                  Expanded(
                    // Ensures the text gets enough space
                    child: FutureBuilder<String>(
                      future: fetchUserName(), // Call the async function here
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            // Center the loading indicator
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error loading name",
                            style:
                                TextStyle(color: Colors.white, fontSize: 22),
                          );
                        } else if (snapshot.hasData) {
                          return Text(
                            snapshot.data ??
                                "Unknown User", // Display the username once fetched
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          );
                        } else {
                          return Text(
                            "No name available",
                            style:
                                TextStyle(color: Colors.white, fontSize: 22),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Input Fields
            InputFields(
              controller: adController,
              placeholder: 'Ad',
              icon: Icon(
                Icons.person,
                color: Color(0xFFA0BAFD),
              ),
            ),
            SizedBox(height: 16),
            InputFields(
              controller: soyadController,
              placeholder: 'Soyad',
              icon: Icon(
                Icons.person_outline,
                color: Color(0xFFA0BAFD),
              ),
            ),
            SizedBox(height: 16),
            InputFields(
              controller: dogumTarihiController,
              placeholder: 'Doğum Tarihi (YYYY-MM-DD)',
              icon: Icon(
                Icons.calendar_today,
                color: Color(0xFFA0BAFD),
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: kiloController,
              placeholder: 'Kilo (kg)',
              icon: Icon(
                Icons.monitor_weight,
                color: Color(0xFFA0BAFD),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: boyController,
              placeholder: 'Boy (cm)',
              icon: Icon(
                Icons.height,
                color: Color(0xFFA0BAFD),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: uyrukController,
              placeholder: 'Uyruk',
              icon: Icon(
                Icons.flag,
                color: Color(0xFFA0BAFD),
              ),
            ),
            SizedBox(height: 16),
            InputFields(
              controller: emailController,
              placeholder: 'E-posta',
              icon: Icon(
                Icons.mail,
                color: Color(0xFFA0BAFD),
              ),
            ),
            SizedBox(height: 16),
            InputFields(
              controller: passwordController,
              placeholder: 'Sifre',
              icon: Icon(
                Icons.lock,
                color: Color(0xFFA0BAFD),
              ),
              secureTextEntry: true,
            ),
            SizedBox(height: 24),

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: FancyButton(
                onClick: saveUserData,
                button_text: "Kaydet",
                button_height: 50,
                button_width: 300,
                button_radius: 50,
                button_outline_width: 0,
                button_outline_color: Colors.pink[50],
                button_text_size: 22,
                button_color: Color(0xFFA0BAFD),
              ),
            ),
            SizedBox(height: 24),

            // FEV1 Circular Progress Bar
            Center(
              child: _isLoadingFEV1
                  ? CircularProgressIndicator()
                  : _fev1Error != null
                      ? Text(
                          _fev1Error!,
                          style: TextStyle(color: Colors.red),
                        )
                      : CustomCircularProgressBar(
                          progress: _calculateProgress(_fev1Value!),
                          maxValue: 55,
                          minValue: 1,
                          text: _fev1Value != null
                              ? _fev1Value!.toStringAsFixed(2)
                              : "N/A",
                        ),
            ),
          ],
        ),
      ),
    );
  }
}